import { json } from '@sveltejs/kit';
import { prisma } from '$lib';
import { getUser } from '$lib/auth';



export async function POST({ request, cookies }) {
    console.log("saved")

    const user = await getUser(cookies);
    if (!user) return json({ error: "Unauthorized" }, { status: 401 });

	const gameState = await request.json();

	// Upsert: Update if exists, create if not
	await prisma.saveFiles.upsert({
		where: { userId: user.id },
		update: { saveData: gameState },
		create: {
			userId: user.id,
			saveData: gameState
		}
	});
	return json({ success: true });
}   