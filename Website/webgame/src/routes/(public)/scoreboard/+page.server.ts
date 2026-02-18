import { prisma } from '$lib';
import type { Server } from 'http';
import type { ServerLoad } from '@sveltejs/kit';

export const load = (async () => {
	const leaderboard = await prisma.user.findMany({
		select: {
			name: true,
			maxScore: true
		},
		orderBy: {
			maxScore: 'desc'
		},
		where: {
			maxScore: {
				gt: 0
			}
		},  
		take: 100
	});

	return {
		leaderboard
	};
}) satisfies ServerLoad;
