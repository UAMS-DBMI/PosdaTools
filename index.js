"use strict";
exports.__esModule = true;
var request = require('request');
var Canvas = require('canvas');
// Function found at https://gist.github.com/miguelmota/5b06ae5698877322d0ca
// This is kind of bull, but it's how you have to do it...
function toArrayBuffer(buffer) {
    var ab = new ArrayBuffer(buffer.length);
    var view = new Uint8Array(ab);
    for (var i = 0; i < buffer.length; ++i) {
        view[i] = buffer[i];
    }
    return ab;
}
var K = (function () {
    function K() {
        this.CImage = Canvas.Image;
        this.canvas = new Canvas();
        this.c = this.canvas.getContext('2d');
        this.context = this.c;
    }
    K.prototype.processHeaders = function (headers) {
        var img = {
            height: Number(headers['q-dicom-rows']),
            width: Number(headers['q-dicom-cols']),
            window_width: Number(headers['q-dicom-window-width']) || 2000,
            window_center: Number(headers['q-dicom-window-center']) || 300,
            slope: Number(headers['q-dicom-slope']) || 1,
            intercept: Number(headers['q-dicom-intercept']) || 0,
            pixel_pad: Number(headers['q-dicom-pixel-pad']),
            samples_per_pixel: Number(headers['q-dicom-samples-per-pixel']),
            pixel_representation: Number(headers['q-dicom-pixelrep']),
            photometric_interpretation: headers['q-dicom-photorep'],
            planar_configuration: headers['q-dicom-planar-config']
        };
        return img;
    };
    K.prototype.applySlopeInterceptWinLev = function () {
        var data = this.current_image.pixel_data;
        // In order to convert the data into a proper Uint16Array (with
        // two bytes per element) we have to force it into an ArrayBuffer first
        var source = new Uint16Array(toArrayBuffer(data)); // load bytes in array
        var image = new Uint8Array(source.length);
        var slope = this.current_image.slope;
        var intercept = this.current_image.intercept;
        var w_width = this.current_image.window_width;
        var w_center = this.current_image.window_center;
        var ppad = this.current_image.pixel_pad;
        // console.log(source);
        // console.log(this.current_image);
        // console.log(slope);
        // console.log(intercept);
        // console.log(w_width);
        // console.log(w_center);
        var w_bottom = w_center - (w_width / 2);
        var w_top = w_center + (w_width / 2);
        // console.log(w_bottom);
        // console.log(w_top);
        // window/level into 8bit array
        for (var i = 0; i < source.length; i++) {
            var val = (source[i] * slope) + intercept;
            if (val <= w_bottom) {
                image[i] = 0;
            }
            else if (val > w_top) {
                image[i] = 255;
            }
            else {
                image[i] = ((val - (w_center - w_width / 2)) / w_width) * 255;
            }
        }
        return image;
    };
    K.prototype.draw = function () {
        if (this.canvas.width == 0) {
            this.canvas.width = this.current_image.width;
            this.canvas.height = this.current_image.height;
        }
        try {
            if (this.current_image.photometric_interpretation == 'RGB') {
                // make an image without winlev
                var image = new Uint8Array(this.current_image.pixel_data);
                this.drawRGB(image);
            }
            else {
                var image = this.applySlopeInterceptWinLev();
                this.drawMono(image);
            }
        }
        catch (e) {
            console.log(e);
            console.log(this.current_image);
        }
    };
    K.prototype.main = function () {
        var _this = this;
        var options = {
            url: 'http://localhost:4200/vapi/details/3899094',
            encoding: null // magic param to get binary back (as a Buffer, supposedly)
        };
        request(options, function (error, response, body) {
            // console.log(response.arrayBuffer);
            // console.log(body);
            _this.current_image = _this.processHeaders(response.headers);
            _this.current_image.pixel_data = new Buffer(body);
            // apply slope/intercept if needed here
            // let image: Uint8Array = new Uint8Array(this.applySlopeInterceptWinLev());
            // let image: Uint8Array = new Uint8Array(new Buffer(body));
            // this.drawRGB(image);
            _this.draw();
        });
    };
    K.prototype.drawMono = function (image) {
        var c = this.context;
        var expected_length = this.current_image.width * this.current_image.height * 4;
        var output_image = new Uint8ClampedArray(expected_length); // length in bytes 
        for (var i = 0; i < expected_length; i++) {
            var j = i * 4;
            output_image[j] = image[i];
            output_image[j + 1] = image[i];
            output_image[j + 2] = image[i];
            output_image[j + 3] = 255; // alpha
        }
        this.drawFinalImage(output_image);
    };
    K.prototype.drawRGB = function (image) {
        var expected_length = this.current_image.width * this.current_image.height
            * 4; // 4 planes, RGBA
        var output_image = new Uint8ClampedArray(expected_length); // length in bytes 
        for (var i = 0; i < image.length; i += 3) {
            var j = (i / 3) * 4;
            output_image[j] = image[i];
            output_image[j + 1] = image[i + 1];
            output_image[j + 2] = image[i + 2];
            output_image[j + 3] = 255; // alpha
        }
        this.drawFinalImage(output_image);
    };
    K.prototype.drawFinalImage = function (image) {
        var newImageData = this.c.createImageData(this.current_image.width, this.current_image.height);
        newImageData.data.set(image);
        this.c.putImageData(newImageData, 0, 0);
        console.log('<img src="' + this.canvas.toDataURL() + '" />');
    };
    return K;
}());
var k = new K();
k.main();
