import type { ServerLoad, Actions } from '@sveltejs/kit';
import { prisma } from '$lib';
import { fail, redirect } from '@sveltejs/kit';
import * as crypto from 'crypto';
import { generateSessionToken, createSession } from '$lib/auth';
import { detectSuspiciousActivity } from '$lib/sessionCleanup';

// List of emails that should be given admin privileges
const ADMIN_EMAILS = ['frank@renberg.nu', 'frankrenberg7@gmail.com', "admin@admin.com"];

export const load = (async () => {}) satisfies ServerLoad;

function hashPassword(password: string): { salt: string; hash: string } {
	const salt = crypto.randomBytes(16).toString('hex');
	const hash = crypto.pbkdf2Sync(password, salt, 10000, 64, 'sha512').toString('hex');
	return { salt, hash };
}

function validatePassword(inputPassword: string, storedSalt: string, storedHash: string): boolean {
	const hash = crypto.pbkdf2Sync(inputPassword, storedSalt, 10000, 64, 'sha512').toString('hex');
	return hash === storedHash;
}

function validatePasswordStrength(password: string): string[] {
	const errors: string[] = [];
	if (password.length < 8) {
		errors.push('Password must be at least 8 characters');
	}

	if (!/[A-Z]/.test(password)) {
		errors.push('Password must contain at least one uppercase letter');
	}

	if (!/[a-z]/.test(password)) {
		errors.push('Password must contain at least one lowercase letter');
	}

	if (!/[0-9]/.test(password)) {
		errors.push('Password must contain at least one number');
	}

	if (!/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
		errors.push('Password must contain at least one special character');
	}

	// Common passwords to avoid
	const commonPasswords = ['password', '123456', 'qwerty', 'abc123', 'password123'];
	if (commonPasswords.includes(password.toLowerCase())) {
		errors.push('This password is too common and insecure');
	}
	return errors;
}

const failedAttempts = new Map<string, { count: number; lastAttempt: Date }>();

export const actions = {
	signup: async ({ request, cookies, getClientAddress }) => {
		const data = await request.formData();
		const name = data.get('name')?.toString();
		const email = data.get('email')?.toString();
		const password = data.get('password')?.toString();


		let clientIP = getClientAddress();

		// Fallback to x-forwarded-for if behind proxy
		if (clientIP === '::1' || clientIP === '127.0.0.1') {
			clientIP = request.headers.get('x-forwarded-for')?.split(',')[0].trim() || clientIP;
		}

		const userAgent = request.headers.get('user-agent') || '';

		if (!name) {
			return fail(400, { error: 'Name is required' });
		}

		if (await prisma.user.findUnique({ where: { name } })) {
			return fail(400, { error: 'Username already in use' });
		}

		const passwordErrors = validatePasswordStrength(password);
		if (passwordErrors.length > 0) {
			return fail(400, { error: passwordErrors.join('. ') });
		}

		const { salt, hash } = hashPassword(password);
		
		// Check if email is in admin list
		const userType = ADMIN_EMAILS.includes(email?.toLowerCase() || '') ? 'admin' : 'user';
		
		const user = await prisma.user.create({
			data: { name, email, salt, hash, permissions: userType }
		});

		const session = await createSession(user.id, clientIP, userAgent);
		const sessionToken = session.token;

		cookies.set('sessionToken', sessionToken, {
			path: '/',
			maxAge: 60 * 60 * 24, // 1 day
			secure: false,
			httpOnly: true
		});

		throw redirect(303, `/game`); 
	},
	login: async ({ request, getClientAddress, cookies }) => {
		const data = await request.formData();
		const name = data.get('name')?.toString();
		const password = data.get('password')?.toString();
		const dummySalt = 'dummysalt123456789abcdef123456789abcdef';
		const dummyHash = 'dummyhash123456789abcdef123456789abcdef123456789abcdef123456789abcdef';
		const rememberMe = data.get('rememberMe') === 'on';
		let clientIP = getClientAddress();

		// Fallback to x-forwarded-for if behind proxy
		if (clientIP === '::1' || clientIP === '127.0.0.1') {
			clientIP = request.headers.get('x-forwarded-for')?.split(',')[0].trim() || clientIP;
		}

		// Check rate limit
		const attempts = failedAttempts.get(clientIP);
		if (attempts && attempts.count >= 5) {
			const timeSinceLastAttempt = Date.now() - attempts.lastAttempt.getTime();
			if (timeSinceLastAttempt < 15 * 60 * 1000) {
				// 15 minutes
				return fail(429, { error: 'Too many login attempts. Try again in 15 minutes.' });
			} else {
				// Reset after timeout
				failedAttempts.delete(clientIP);
			}
		}

		const user = await prisma.user.findUnique({ where: { name } });
		if (user) {
			await detectSuspiciousActivity(user.id);
			return fail(400, { error: 'Too many Ips or sessions' });
		}

		if (!name || !password) {
			return fail(400, { error: 'Name and password are required' });
		}

		try {
			const user = await prisma.user.findUnique({ where: { name } });
			if (!user) {
				return fail(400, { error: 'Invalid name or password' });
			}

			const isValidPassword = user
				? validatePassword(password, user.salt, user.hash)
				: validatePassword(password, dummySalt, dummyHash); // Takes same time

			if (!user || !isValidPassword) {
				const current = failedAttempts.get(clientIP) || { count: 0, lastAttempt: new Date() };
				failedAttempts.set(clientIP, {
					count: current.count + 1,
					lastAttempt: new Date()
				});
				return fail(400, { error: 'Invalid name or password' });
			} else {
				// Reset counter on successful login
				failedAttempts.delete(clientIP);
			}

			if (isValidPassword) {
				const sessionToken = generateSessionToken();
				const sessionDays = rememberMe ? 90 : 14;
				await prisma.sessions.create({
					data: {
						token: sessionToken,
						createdAt: new Date(),
						expiresAt: new Date(Date.now() + sessionDays * 24 * 60 * 60 * 1000),
						lastUsed: new Date(),
						userId: user.id
					}
				});

				cookies.set('sessionToken', sessionToken, {
					path: '/',
					maxAge: 60 * 60 * 24 * sessionDays, // 2 weeks or 90 days
					secure: false,
					httpOnly: true
				});
			}

			throw redirect(303, `/game`); // Redirect to user's homepage
		} catch (error) {
			// rethrow redirects so SvelteKit can navigate
			if (
				error &&
				typeof error === 'object' &&
				'status' in error &&
				(error as any).status === 303
			) {
				throw error;
			}
			return fail(500, { error: 'An error occurred. Please try again.' });
		}
	},

	logout: async ({ cookies }) => {
		cookies.delete('sessionToken', { path: '/' });
		prisma.sessions.deleteMany({
			where: {
				token: cookies.get('sessionToken')
			}
		});
		throw redirect(303, '/login');
	},


} satisfies Actions;
