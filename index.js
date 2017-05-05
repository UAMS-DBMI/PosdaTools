"use strict";
exports.__esModule = true;
var request = require('request');
var Canvas = require('canvas');
var fs = require('fs');
var winston = require('winston');
winston.level = 'debug';
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
        var w_bottom = w_center - (w_width / 2);
        var w_top = w_center + (w_width / 2);
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
    K.prototype.drawMono = function (image) {
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
        if (this.maximum_projection === undefined) {
            this.maximum_projection = image.slice();
        }
        if (this.minimum_projection === undefined) {
            this.minimum_projection = image.slice();
        }
        for (var i = 0; i < image.length; ++i) {
            if (image[i] > this.maximum_projection[i]) {
                this.maximum_projection[i] = image[i];
            }
            if (image[i] < this.minimum_projection[i]) {
                this.minimum_projection[i] = image[i];
            }
        }
    };
    K.prototype.drawFinalImage_orig = function (image, name) {
        var canvas = new Canvas();
        var c = canvas.getContext('2d');
        winston.log('debug', 'Setting canvas dim');
        // TODO: this should not be global (current_image) in this case
        canvas.width = this.current_image.width;
        canvas.height = this.current_image.height;
        var newImageData = c.createImageData(this.current_image.width, this.current_image.height);
        newImageData.data.set(image);
        c.putImageData(newImageData, 0, 0);
        // console.log('<img src="' + this.canvas.toDataURL() + '" />');
        var stream = canvas.pngStream();
        var out = fs.createWriteStream(name);
        stream.on('data', function (chunk) { return out.write(chunk); });
        stream.on('end', function () { return console.log('png written'); });
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
    K.prototype.test = function () {
        var _this = this;
        // get a series
        request('http://localhost:4200/vapi/series_info/1.3.6.1.4.1.14519.5.2.1.7009.2401.339279835610748520609872183315', function (error, response, body) {
            var json_body = JSON.parse(body);
            _this.files_to_get = json_body.file_ids;
            winston.log('info', 'Got list of files: ', _this.files_to_get.length);
            _this.getNextImage();
        });
    };
    K.prototype.getNextImage = function () {
        var _this = this;
        var id = this.files_to_get.pop();
        if (id === undefined) {
            this.drawFinalImage_orig(this.maximum_projection, 'max.png');
            this.drawFinalImage_orig(this.minimum_projection, 'min.png');
            return;
        }
        var options = {
            url: 'http://localhost:4200/vapi/details/' + id,
            encoding: null // magic param to get binary back (as a Buffer, supposedly)
        };
        request(options, function (error, response, body) {
            _this.current_image = _this.processHeaders(response.headers);
            _this.current_image.pixel_data = new Buffer(body);
            _this.file_id = id;
            _this.draw();
            console.log('got an image: ' + id);
            _this.getNextImage();
        });
    };
    return K;
}());
var k = new K();
// k.main();
k.test();
