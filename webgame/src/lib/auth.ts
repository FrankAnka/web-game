import { prisma } from '$lib';
import { redirect } from '@sveltejs/kit';
import crypto from 'node:crypto';

export async function requireAuth(cookies: any) {
	const sessionToken = cookies.get('sessionToken');
	if (!sessionToken) {
		throw redirect(303, '/login');
	}

	const expiredDays = 14;
	const session = await prisma.sessions.findUnique({
		where: {
			token: sessionToken
		},
		include: {
			user: true
		}
	});

	if (!session) {
		cookies.delete('sessionToken', { path: '/' });
		throw redirect(303, '/login');
	}
	if (isTokenExpired(session.createdAt, session.lastUsed, expiredDays)) {
		await prisma.sessions.delete({
			where: {
				token: sessionToken
			}
		});
		cookies.delete('sessionToken', { path: '/' });
		throw redirect(303, '/login');
	}

	await prisma.sessions.update({
		where: {
			token: sessionToken
		},
		data: {
			lastUsed: new Date()
		}
	});

	return session.user;
}

export async function getUser(cookies: any) {
	const sessionToken = cookies.get('sessionToken');

	if (!sessionToken) return null;

	const session = await prisma.sessions.findUnique({
		where: { token: sessionToken }
	});
	const user = await prisma.user.findUnique({
		where: { id: session?.userId }
	});

	if (!user) {
		cookies.delete('sessionToken', { path: '/' });
		return null;
	}

	if (user) return user;
}

export function generateSessionToken(): string {
	return crypto.randomBytes(32).toString('base64url');
}
export function isTokenExpired(
	createdAt: Date,
	lastUsed: Date,
	maxAgeInDays: number = 14
): boolean {
	const now = new Date();
	if (!createdAt) return true;
	else {
		if (
			now.getTime() - lastUsed.getTime() > maxAgeInDays * 24 * 60 * 60 * 1000 ||
			now.getTime() - createdAt.getTime() > maxAgeInDays * 24 * 60 * 60 * 1000
		) {
			return true;
		} else {
			return false;
		}
	}
}

export async function createSession(userId: string, ipAddress?: string, userAgent?: string) {
	const token = generateSessionToken();
	const expiresAt = new Date();
	expiresAt.setDate(expiresAt.getDate() + 14); // 14 days expiry

	const session = await prisma.sessions.create({
		data: {
			token,
			userId,
			expiresAt,
			userAgent,
			ipAddress
		}
	});
	return session;
}

export async function validateSession(token: string) {
	const session = await prisma.sessions.findUnique({
		where: { token },
		include: { user: true }
	});

	if (!session) {
		return null;
	}

	if (session.expiresAt < new Date()) {
		await prisma.sessions.delete({ where: { id: session.id } });
		return null;
	}

	await prisma.sessions.update({
		where: { id: session.id },
		data: { lastUsed: new Date() }
	});

	return session;

}
