const request = require('request');
const Canvas = require('canvas');
const fs = require('fs');
const winston = require('winston');
winston.level = 'debug';

import { Image } from './image';


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

  // canvas: any = new Canvas();
  // c: any = this.canvas.getContext('2d');
  // context: any = this.c;

  files_to_get: any;
  file_id: number;

  current_image: Image;

  maximum_projection: Uint8ClampedArray;
  minimum_projection: Uint8ClampedArray;


  constructor() {}

  processHeaders(headers: any): Image {
      let img = {
        height : Number(headers['q-dicom-rows']),
        width : Number(headers['q-dicom-cols']),
        window_width : Number(headers['q-dicom-window-width']) || 2000,
        window_center : Number(headers['q-dicom-window-center']) || 300,
        slope : Number(headers['q-dicom-slope']) || 1, 
        intercept : Number(headers['q-dicom-intercept']) || 0,
        pixel_pad : Number(headers['q-dicom-pixel-pad']),
        samples_per_pixel: Number(headers['q-dicom-samples-per-pixel']),
        pixel_representation: Number(headers['q-dicom-pixelrep']),
        photometric_interpretation: headers['q-dicom-photorep'],
        planar_configuration: headers['q-dicom-planar-config'],
      };

      return img;
    }


    applySlopeInterceptWinLev(): Uint8Array {
      let data = this.current_image.pixel_data;
      // In order to convert the data into a proper Uint16Array (with
      // two bytes per element) we have to force it into an ArrayBuffer first
      let source = new Uint16Array(toArrayBuffer(data)); // load bytes in array
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
        } else if (val > w_top) {
          image[i] = 255;
        } else {
          image[i] = ((val - (w_center - w_width / 2)) / w_width) * 255;
        }
      }

      return image;
    }

  draw(): void {

    try {
      if (this.current_image.photometric_interpretation == 'RGB') {
        // make an image without winlev
        let image = new Uint8Array(this.current_image.pixel_data);
        this.drawRGB(image);
      } else {
        let image = this.applySlopeInterceptWinLev();
        this.drawMono(image);
      }
    } catch (e) {
      console.log(e);
      console.log(this.current_image);
    }
  }


  drawMono(image: Uint8Array) {
    let expected_length = this.current_image.width * this.current_image.height * 4;

    let output_image = new Uint8ClampedArray(expected_length); // length in bytes 


    for (let i = 0; i < expected_length; i++) {
      let j = i * 4;
      output_image[j] = image[i];
      output_image[j+1] = image[i];
      output_image[j+2] = image[i];
      output_image[j+3] = 255; // alpha
    }

    this.drawFinalImage(output_image);
  }

  drawRGB(image: Uint8Array) {


    let expected_length =  // Expected output length in bytes
      this.current_image.width * this.current_image.height 
      * 4; // 4 planes, RGBA

    let output_image = new Uint8ClampedArray(expected_length); // length in bytes 

    for (let i = 0; i < image.length; i+=3) {
      let j = (i/3) * 4;
      output_image[j] = image[i];
      output_image[j+1] = image[i+1];
      output_image[j+2] = image[i+2];
      output_image[j+3] = 255; // alpha
    }

    this.drawFinalImage(output_image);
  }

  drawFinalImage(image: Uint8ClampedArray) {
    if (this.maximum_projection === undefined) {
      this.maximum_projection = image.slice();
    }
    if (this.minimum_projection === undefined) {
      this.minimum_projection = image.slice();
    }

    for (let i = 0; i < image.length; ++i) {
      if (image[i] > this.maximum_projection[i]) {
        this.maximum_projection[i] = image[i];
      }
      if (image[i] < this.minimum_projection[i]) {
        this.minimum_projection[i] = image[i];
      }
    }

  }

  drawFinalImage_orig(image: Uint8ClampedArray, name: string) {
    let canvas: any = new Canvas();
    let c: any = canvas.getContext('2d');

    winston.log('debug', 'Setting canvas dim');
    // TODO: this should not be global (current_image) in this case
    canvas.width = this.current_image.width;
    canvas.height = this.current_image.height;

    let newImageData = c.createImageData(
      this.current_image.width, this.current_image.height);
    newImageData.data.set(image);

    c.putImageData(newImageData, 0, 0);

    // console.log('<img src="' + this.canvas.toDataURL() + '" />');

    let stream: any = canvas.pngStream();
    let out: any = fs.createWriteStream(name);
    stream.on('data', (chunk) => out.write(chunk));
    stream.on('end', () => console.log('png written'));
  }
  main() {

    let options: any = {
      url: 'http://localhost:4200/vapi/details/3899094',
      encoding: null // magic param to get binary back (as a Buffer, supposedly)
    };

    request(options, (error, response, body) => {
      // console.log(response.arrayBuffer);
      // console.log(body);
      this.current_image = this.processHeaders(response.headers);
      this.current_image.pixel_data = new Buffer(body);

      // apply slope/intercept if needed here

      // let image: Uint8Array = new Uint8Array(this.applySlopeInterceptWinLev());
      // let image: Uint8Array = new Uint8Array(new Buffer(body));

      // this.drawRGB(image);
      this.draw();
    });
  }

  test() {
    // get a series
    request('http://localhost:4200/vapi/series_info/1.3.6.1.4.1.14519.5.2.1.7009.2401.339279835610748520609872183315', (error, response, body) => {
      let json_body: any = JSON.parse(body);
      this.files_to_get = json_body.file_ids;
      winston.log('info', 'Got list of files: ', this.files_to_get.length);

      this.getNextImage();
    });
  }

  getNextImage() {
    let id: number = this.files_to_get.pop();
    if (id === undefined) {
      this.drawFinalImage_orig(this.maximum_projection, 'max.png');
      this.drawFinalImage_orig(this.minimum_projection, 'min.png');
      return;
    }

    let options: any = {
      url: 'http://localhost:4200/vapi/details/' + id,
      encoding: null // magic param to get binary back (as a Buffer, supposedly)
    };

    request(options, (error, response, body) => {
      this.current_image = this.processHeaders(response.headers);
      this.current_image.pixel_data = new Buffer(body);
      this.file_id = id;
      this.draw();

      console.log('got an image: ' + id);
      this.getNextImage();
    });
  }
}


let k = new K();
// k.main();
k.test();
