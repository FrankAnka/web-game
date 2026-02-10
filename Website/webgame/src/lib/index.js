// place files you want to import through the `$lib` alias in this folder.
import { env } from '$env/dynamic/private';
import { PrismaClient } from '../generated/prisma/client.ts';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

const databaseUrl = env.DATABASE_URL;
if (!databaseUrl) {
	throw new Error('DATABASE_URL is not set. Configure it in your environment or .env file.');
}

const pool = new Pool({
	connectionString: databaseUrl
});

const adapter = new PrismaPg(pool);

export const prisma = new PrismaClient({ adapter });
