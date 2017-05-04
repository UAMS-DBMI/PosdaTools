const request = require('request');

request('http://example.com', (error, response, body) => {
	console.log(response);
});
