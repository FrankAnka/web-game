import { json } from '@sveltejs/kit';
import { prisma } from '$lib';
import {getUser} from '$lib/auth';



export async function GET({ url,cookies }) {
	const user = await getUser(cookies);
    const userid = user?.id;

	const save = await prisma.saveFiles.findFirst({
		where: { userId:userid  }
	});

	if (!save) {
		return json({ error: "No save found" }, { status: 404 });
	}

	// session.farmData is the JSON object stored in Postgres
	return json(save.saveData);
}