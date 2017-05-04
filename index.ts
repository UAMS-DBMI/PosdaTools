const request = require('request');
const Canvas = require('canvas');

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

  CImage: any = Canvas.Image;
  canvas: any = new Canvas();
  c: any = this.canvas.getContext('2d');
  context: any = this.c;

  current_image: Image;

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
    if (this.canvas.width == 0) {
      this.canvas.width = this.current_image.width;
      this.canvas.height = this.current_image.height;
    }

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

  drawMono(image: Uint8Array) {
    let c = this.context;
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
    let newImageData = this.c.createImageData(
      this.current_image.width, this.current_image.height);
    newImageData.data.set(image);

    this.c.putImageData(newImageData, 0, 0);

    console.log('<img src="' + this.canvas.toDataURL() + '" />');
  }
}


let k = new K();
k.main();
