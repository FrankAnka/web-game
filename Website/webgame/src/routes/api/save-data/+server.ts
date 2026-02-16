import { json } from '@sveltejs/kit';
import { prisma } from '$lib';
import { getUser } from '$lib/auth';



export async function POST({ request, cookies }) {
    const user = await getUser(cookies);
    const { score } = await request.json();

    const newEntry = await prisma.saveFiles.upsert({
        where: { userId: user.id },
        update: { saveData: { score } },
        create: { userId: user.id, saveData: { score } }
    });
    console.log(`Updated user ${user.id} with new score: ${score}`);
    return json({ success: true, entry: newEntry });
}   