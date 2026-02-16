import { json } from '@sveltejs/kit';
import { prisma } from '$lib';
import {getUser} from '$lib/auth';



export async function GET({ cookies }) {
	const user = await getUser(cookies);
	if (!user) return json({ error: "Not logged in" }, { status: 401 });

	const save = await prisma.saveFiles.findFirst({
		where: { userId: user.id }
	});

	// Instead of a 404 error, return an empty object with a 200 status
	if (!save) {
		return json({ new_game: true, saveData: { score: 0, plants: [] } });
	}

	return json(save.saveData);
}