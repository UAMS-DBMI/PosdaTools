const request = require('request');
const fs = require('fs');
const Canvas = require('canvas');

var Image = Canvas.Image;
var canvas = new Canvas(512, 512);
var ctx = canvas.getContext('2d');

request('http://localhost:4200/vapi/details/3901748', (error, response, body) => {
	console.log(response.headers);
	// let image = new Uint8Array(new Buffer(body));
	// // console.log(image);
	// let newImageData = ctx.createImageData(512, 512);
	// newImageData.data.set(image);

	// ctx.putImageData(newImageData, 0, 0);

	// console.log('<img src="' + canvas.toDataURL() + '" />');
});
