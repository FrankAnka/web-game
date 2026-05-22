import { json } from '@sveltejs/kit';
import type { RequestEvent } from '@sveltejs/kit';
import { prisma } from '$lib';
import { getUser } from '$lib/auth';

export async function POST({ request, cookies }: RequestEvent) {
	console.log('saved');

	const user = await getUser(cookies);
	if (!user) return json({ error: 'Unauthorized' }, { status: 401 });

	const gameState = await request.json();
	const savedScore = Number(gameState?.money ?? gameState?.maxScore ?? 0);
	const shouldUpdateMaxScore = Number.isFinite(savedScore) && savedScore > user.maxScore;

	await prisma.$transaction([
		prisma.saveFiles.upsert({
			where: { userId: user.id },
			update: { saveData: gameState },
			create: {
				userId: user.id,
				saveData: gameState
			}
		}),
		...(shouldUpdateMaxScore
			? [
					prisma.user.update({
						where: { id: user.id },
						data: { maxScore: savedScore }
					})
				]
			: [])
	]);
	return json({ success: true });
}
