import { v2 as cloudinary } from 'cloudinary';
import {
	CLOUDINARY_API_KEY,
	CLOUDINARY_API_SECRET,
	CLOUDINARY_CLOUD_NAME,
	CLOUDINARY_FOLDER
} from '$env/static/private';

const baseFolder = CLOUDINARY_FOLDER || 'market-app';

if (!CLOUDINARY_CLOUD_NAME || !CLOUDINARY_API_KEY || !CLOUDINARY_API_SECRET) {
	throw new Error('Cloudinary environment variables are missing.');
}

cloudinary.config({
	cloud_name: CLOUDINARY_CLOUD_NAME,
	api_key: CLOUDINARY_API_KEY,
	api_secret: CLOUDINARY_API_SECRET,
	secure: true
});

export const cloudinaryBaseFolder = baseFolder;

export async function uploadImage(file: File, folder = baseFolder): Promise<string> {
	const buffer = Buffer.from(await file.arrayBuffer());

	return new Promise((resolve, reject) => {
		const uploadStream = cloudinary.uploader.upload_stream(
			{ folder, resource_type: 'image' },
			(error, result) => {
				if (error || !result?.secure_url) {
					reject(error || new Error('Cloudinary did not return a secure URL.'));
					return;
				}

				resolve(result.secure_url);
			}
		);

		uploadStream.end(buffer);
	});
}
