export function validateImageFile(file: File) {
	// Check file type
	const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
	if (!allowedTypes.includes(file.type)) {
		return false; // Or throw an error
	}

	// Check file size (e.g. max 5MB)
	const maxSize = 5 * 1024 * 1024; // 5MB in bytes
	if (file.size > maxSize) {
		return false; // Or throw an error
	}

	// Check file name for safety
	// No ".." or "/" in the name
	if (file.name.includes('..') || file.name.includes('/')) {
		return false; // Or throw an error
	}

	return true;
	// Return true/false or throw error
}
