import { prisma } from '$lib';

export async function cleanupExpiredSessions() {
	const deleted = await prisma.sessions.deleteMany({
		where: {
			expiresAt: { lt: new Date() }
		}
	});

}

// Run daily (in a real app, use a cron job)
if (typeof window === 'undefined') {
	setInterval(cleanupExpiredSessions, 24 * 60 * 60 * 1000);
}

export async function detectSuspiciousActivity(userId: string) {
	const sessions = await prisma.sessions.findMany({
		where: { userId },
		orderBy: { createdAt: 'desc' }
	});

	// Check for unusual patterns
	const ipAddresses = new Set(sessions.map((s) => s.ipAddress));
	const recentSessions = sessions.filter(
		(s) => s.createdAt > new Date(Date.now() - 24 * 60 * 60 * 1000)
	);

	// Alerts for:
	// - Too many IP addresses
	// - Too many new sessions
	// - Sessions from different countries

	if (ipAddresses.size > 5) {
		console.warn(`User ${userId} has sessions from ${ipAddresses.size} different IPs`);
	}

	if (recentSessions.length > 10) {
		console.warn(`User ${userId} created ${recentSessions.length} sessions in 24h`);
	}
}
