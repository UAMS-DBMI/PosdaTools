/*
 * Functions related to masking
 */

// TODO experiment for singleton value
export let loaded = { loaded: false };

export async function getUsername() {
	const response = await fetch(`/papi/v1/other/testme`);
	const details = await response.json();

	return details.username;
}

export async function getDetails(file_id) {

	const response = await fetch(`/papi/v1/nifti/${file_id}`);
	const details = await response.json();

	return details;
}

export async function setStatus(file_id, status) {

	const response = await fetch(
		`/papi/v1/nifti/${file_id}/set_status/${status}`,
		{
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
		}
	);
	const details = await response.json();

	return details;
}


//export async function getNiftiGroupFiles(file_id) {
//	// console.log("getNiftiFiles", iec);
//	const response = await fetch(`/papi/v1/iecs/${iec}/files`);
//	const details = await response.json();

//	return details.file_ids;
//}
