import { json } from '@sveltejs/kit';
import { prisma } from '$lib';
import { requireAuth } from '$lib/auth';



export async function POST({ request, cookies }) {
    const user = await requireAuth(cookies);
    const { score } = await request.json();

    const newEntry = await prisma.user.update({
        where: { id: user.id },
        data: { maxScore: score }
    });
    console.log(`Updated user ${user.id} with new score: ${score}`);
    return json({ success: true, entry: newEntry });
}   