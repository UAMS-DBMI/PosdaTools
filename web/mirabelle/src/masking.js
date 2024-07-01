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

export async function getDetails(iec) {

	const response = await fetch(`/papi/v1/masking/${iec}`);
	const details = await response.json();

	return details;
}
export async function flagForMasking(iec) {
	const response = await fetch(
		`/papi/v1/masking/${iec}/mask`,
		{
			method: "POST",
		}
	);
	const details = await response.json();

	return details;
}
export async function setParameters(iec, { lr, pa, s, i, d }) {
	const response = await fetch(
		`/papi/v1/masking/${iec}/parameters`,
		{
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify({ lr, pa, s, i, d }),
		}
	);
	const details = await response.json();

	return details;
}
export async function getFiles(iec) {

	const response = await fetch(`/papi/v1/iecs/${iec}/files`);
	const details = await response.json();

	return details.file_ids;
}
export async function getReviewFiles(iec) {

	const response = await fetch(`/papi/v1/masking/${iec}/reviewfiles`);
	const details = await response.json();

	return details;
}
export async function getIECsForVR(visual_review_id) {

	const response = await fetch(
		`/papi/v1/masking/visualreview/${visual_review_id}`);
	const details = await response.json();

	return details;
}


export async function tests() {
	const iec = 3;

	console.log("getDetails");
	console.log(await getDetails(iec));

	console.log("flagForMasking");
	console.log(await flagForMasking(iec));

	console.log("setParameters");
	let lr = 212;
	let pa = 47;
	let s = 24;
	let i = 1;
	let d = 200;
	console.log(await setParameters(iec, { lr, pa, s, i, d }));

	console.log("getFiles");
	console.log(await getFiles(iec));

	console.log("getIECsForVR");
	console.log(await getIECsForVR(1));

}
