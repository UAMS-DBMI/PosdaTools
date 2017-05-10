"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const rp = require('request-promise-native');
const pg = require('pg-promise')();
const Canvas = require('canvas');
const fs = require('fs');
const winston = require('winston');
const promiseLimit = require('promise-limit');
const ProgressBar = require('progress');
winston.level = 'error';
const API_URL = 'http://tcia-utilities/vapi';
const finish_1 = require("./finish");
var images_to_get = 0;
var bar = new ProgressBar(':bar ETA :eta s', {
    total: 1,
    width: 70,
    head: '>'
});
;
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
class K {
    constructor(db) {
        this.db = db;
    }
    processHeaders(headers) {
        let img = {
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
            planar_configuration: headers['q-dicom-planar-config'],
        };
        return img;
    }
    applySlopeInterceptWinLev() {
        // In order to convert the data into a proper Uint16Array (with
        // two bytes per element) we have to force it into an ArrayBuffer first
        let source = new Uint16Array(
        // force to be only ArrayBuffer, rather than <ArrayBuffer | undefined>
        this.current_image.pixel_data);
        let image = new Uint8Array(source.length);
        let slope = this.current_image.slope;
        let intercept = this.current_image.intercept;
        let w_width = this.current_image.window_width;
        let w_center = this.current_image.window_center;
        let ppad = this.current_image.pixel_pad;
        let w_bottom = w_center - (w_width / 2);
        let w_top = w_center + (w_width / 2);
        // window/level into 8bit array
        for (let i = 0; i < source.length; i++) {
            let val = (source[i] * slope) + intercept;
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
    }
    draw() {
        try {
            if (this.current_image.photometric_interpretation == 'RGB') {
                // make an image without winlev
                let image = new Uint8Array(this.current_image.pixel_data);
                this.drawRGB(image);
            }
            else {
                let image = this.applySlopeInterceptWinLev();
                this.drawMono(image);
            }
        }
        catch (e) {
            console.log(e);
            console.log(this.current_image);
        }
    }
    drawMono(image) {
        let expected_length = this.current_image.width * this.current_image.height * 4;
        let output_image = new Uint8ClampedArray(expected_length); // length in bytes 
        for (let i = 0; i < expected_length; i++) {
            let j = i * 4;
            output_image[j] = image[i];
            output_image[j + 1] = image[i];
            output_image[j + 2] = image[i];
            output_image[j + 3] = 255; // alpha
        }
        this.drawFinalImage(output_image);
    }
    drawRGB(image) {
        if (this.current_image.planar_configuration == 1) {
            return this.drawRRGGBB(image);
        }
        let expected_length = this.current_image.width * this.current_image.height
            * 4; // 4 planes, RGBA
        let output_image = new Uint8ClampedArray(expected_length); // length in bytes 
        for (let i = 0; i < image.length; i += 3) {
            let j = (i / 3) * 4;
            output_image[j] = image[i];
            output_image[j + 1] = image[i + 1];
            output_image[j + 2] = image[i + 2];
            output_image[j + 3] = 255; // alpha
        }
        this.drawFinalImage(output_image);
    }
    drawRRGGBB(image) {
        let expected_length = this.current_image.width * this.current_image.height
            * 4; // 4 planes, RGBA
        let output_image = new Uint8ClampedArray(expected_length); // length in bytes 
        // offset of each plane
        let R = 0;
        let G = image.length / 3;
        let B = G * 2;
        for (let i = 0; i < image.length / 3; i++) {
            let j = i * 4;
            output_image[j] = image[R + i];
            output_image[j + 1] = image[G + i];
            output_image[j + 2] = image[B + i];
            output_image[j + 3] = 255; // alpha
        }
        this.drawFinalImage(output_image);
    }
    makeWhiteImage(width, height) {
        let img = new Uint8ClampedArray(width * height * 4);
        img.fill(255);
        return { pixels: img, count: 0 };
    }
    makeBlack(width, height) {
        let img = new Uint8ClampedArray(width * height * 4);
        img.fill(0);
        return { pixels: img, count: 0 };
    }
    drawFinalImage(image) {
        if (this.maximum_projection === undefined) {
            this.maximum_projection = this.makeBlack(this.current_image.width, this.current_image.height);
        }
        if (this.minimum_projection === undefined) {
            this.minimum_projection = this.makeWhiteImage(this.current_image.width, this.current_image.height);
        }
        if (this.mean_projection === undefined) {
            this.mean_projection = { pixels: image.slice(), count: 1 };
        }
        for (let i = 0; i < image.length; ++i) {
            if (image[i] > this.maximum_projection.pixels[i]) {
                this.maximum_projection.pixels[i] = image[i];
            }
            if (image[i] < this.minimum_projection.pixels[i]) {
                this.minimum_projection.pixels[i] = image[i];
            }
            this.mean_projection.pixels[i] = ((this.mean_projection.pixels[i] * (this.mean_projection.count - 1)) + image[i]) / this.mean_projection.count;
        }
        this.maximum_projection.count++;
        this.minimum_projection.count++;
        this.mean_projection.count++;
    }
    writePng(max, min, mean, name) {
        return __awaiter(this, void 0, void 0, function* () {
            let canvas = new Canvas();
            let c = canvas.getContext('2d');
            winston.log('debug', 'Setting canvas dim');
            canvas.width = this.current_image.width * 3;
            canvas.height = this.current_image.height;
            let maxImageData = c.createImageData(this.current_image.width, this.current_image.height);
            maxImageData.data.set(max.pixels);
            let minImageData = c.createImageData(this.current_image.width, this.current_image.height);
            minImageData.data.set(min.pixels);
            let meanImageData = c.createImageData(this.current_image.width, this.current_image.height);
            meanImageData.data.set(mean.pixels);
            c.putImageData(maxImageData, 0, 0);
            c.putImageData(meanImageData, this.current_image.width, 0);
            c.putImageData(minImageData, this.current_image.width * 2, 0);
            yield new Promise((accept, reject) => {
                let stream = canvas.pngStream();
                let out = fs.createWriteStream(name, { autoClose: true });
                stream.on('data', (chunk) => out.write(chunk));
                stream.on('end', () => { out.end(); });
                out.on('finish', () => { accept(); });
            });
        });
    }
    main(iec) {
        return __awaiter(this, void 0, void 0, function* () {
            console.log('IEC: ' + iec);
            let url = API_URL + '/iec_info/' + iec;
            let detail_url = API_URL + '/details/';
            return new Promise((accept, reject) => {
                rp(url).then((body) => {
                    let json_body = JSON.parse(body);
                    let file_ids = json_body.file_ids;
                    winston.log('info', 'Images in this IEC: ' + file_ids.length);
                    images_to_get += file_ids.length;
                    bar.total = images_to_get;
                    let limit = promiseLimit(5);
                    // let promises = file_ids.map(this.getAnImage, this);
                    let promises = file_ids.map((id) => {
                        return limit(() => this.getAnImage(id));
                    }, this);
                    Promise.all(promises).then((data) => __awaiter(this, void 0, void 0, function* () {
                        winston.log('debug', 'All files downloaded, writing pngs');
                        let filename = 'out_' + iec + '.png';
                        yield this.writePng(this.maximum_projection, this.minimum_projection, this.mean_projection, filename);
                        yield finish_1.finishImage(this.db, filename, iec);
                        accept();
                    }));
                });
            });
        });
    }
    getAnImage(file_id) {
        let url = API_URL + '/details/' + file_id;
        return new Promise((accept, reject) => {
            let options = {
                url: url,
                encoding: null,
                resolveWithFullResponse: true
            };
            winston.log('debug', 'About to get file ' + file_id);
            rp(options).then((response) => {
                winston.log('debug', 'About to process file ' + file_id);
                this.current_image = this.processHeaders(response.headers);
                this.current_image.pixel_data = toArrayBuffer(response.body);
                this.file_id = file_id;
                this.draw();
                winston.log('debug', 'Finished processing image: ' + file_id);
                bar.tick();
                accept();
            });
        });
    }
}
// let k = new K();
// k.main(2372);
let client = pg('postgres://tcia-utilities/N_posda_files');
function doOne() {
    return __awaiter(this, void 0, void 0, function* () {
        let query = `
    update image_equivalence_class i
    set processing_status = 'in-progress'
    where i.image_equivalence_class_id in (
      select image_equivalence_class_id
      from image_equivalence_class
      where processing_status = 'QTest1'
      limit 5
    )
    returning i.*
  `;
        let result = yield client.query(query);
        if (result.length < 1) {
            console.log('No work to do, sleeping for 5 seconds...');
            setTimeout(() => { }, 5000); // cause node to stay open
        }
        else {
            console.log("Generating images for " + result.length + " IECs...");
        }
        let jobs = result.map((element) => {
            return (new K(client)).main(element.image_equivalence_class_id);
        });
        Promise.all(jobs).then(() => pg.end());
    });
}
doOne();
