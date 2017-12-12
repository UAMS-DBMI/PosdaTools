const rp = require('request-promise-native');
const pg = require('pg-promise')();
const Canvas = require('canvas');
const fs = require('fs');
const winston = require('winston');
const promiseLimit = require('promise-limit');
const ProgressBar = require('progress');

winston.level = 'debug';

/* 
  Force the pg-promise library to support postgress peer auth,
  by changing the default host to the local unix socket.
*/
pg.pg.defaults.host = '/var/run/postgresql';


const API_URL = 'http://localhost/vapi';

import { Image } from './image';

import { finishImage } from './finish';

var images_to_get: number = 0;
var bar = new ProgressBar(':bar ETA :eta s', 
{ 
  total: 1, 
  width: 70,
  head: '>'
});


interface OutputImage {
  pixels: Uint8ClampedArray;
  count: number;
};

// Function found at https://gist.github.com/miguelmota/5b06ae5698877322d0ca
// This is kind of bull, but it's how you have to do it...
function toArrayBuffer(buffer: Buffer): ArrayBuffer {
    var ab: ArrayBuffer = new ArrayBuffer(buffer.length);
    var view: Uint8Array = new Uint8Array(ab);
    for (var i = 0; i < buffer.length; ++i) {
        view[i] = buffer[i];
    }
    return ab;
}

class K {

  files_to_get: any;
  file_id: number;

  current_image: Image;

  maximum_projection: OutputImage;
  minimum_projection: OutputImage;
  mean_projection: OutputImage;

  db: any;


  constructor(db: any) {
    this.db = db;
  }

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
      // In order to convert the data into a proper Uint16Array (with
      // two bytes per element) we have to force it into an ArrayBuffer first

      let source: Uint16Array = new Uint16Array(
        // force to be only ArrayBuffer, rather than <ArrayBuffer | undefined>
        <ArrayBuffer>this.current_image.pixel_data);
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
        let image = new Uint8Array(<ArrayBuffer>this.current_image.pixel_data);
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
    if (this.current_image.planar_configuration == 1) {
      return this.drawRRGGBB(image);
    }

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

  drawRRGGBB(image: Uint8Array) {
    let expected_length =  // Expected output length in bytes
      this.current_image.width * this.current_image.height 
      * 4; // 4 planes, RGBA

    let output_image = new Uint8ClampedArray(expected_length); // length in bytes 

    // offset of each plane
    let R = 0;
    let G = image.length / 3;
    let B = G * 2;

    for (let i = 0; i < image.length / 3; i++) {
      let j = i * 4;
      output_image[j] = image[R + i];
      output_image[j+1] = image[G + i];
      output_image[j+2] = image[B + i];
      output_image[j+3] = 255; // alpha
    }

    this.drawFinalImage(output_image);

  }

  makeWhiteImage(width: number, height: number): OutputImage {
    let img: Uint8ClampedArray = new Uint8ClampedArray(width * height * 4);
    img.fill(255);
    return { pixels: img, count: 0 };
  }
  makeBlack(width: number, height: number): OutputImage {
    let img: Uint8ClampedArray = new Uint8ClampedArray(width * height * 4);
    img.fill(0);
    return { pixels: img, count: 0 };
  }

  drawFinalImage(image: Uint8ClampedArray) {
    if (this.maximum_projection === undefined) {
      this.maximum_projection = this.makeBlack(this.current_image.width,
                                               this.current_image.height);
    }
    if (this.minimum_projection === undefined) {
      this.minimum_projection = this.makeWhiteImage(this.current_image.width,
                                                    this.current_image.height);
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

  async writePng(max: OutputImage, min: OutputImage, mean: OutputImage, name: string) {
    let canvas: any = new Canvas();
    let c: any = canvas.getContext('2d');

    winston.log('debug', 'Setting canvas dim');
    canvas.width = this.current_image.width * 3;
    canvas.height = this.current_image.height;

    let maxImageData = c.createImageData(
      this.current_image.width, this.current_image.height);
    maxImageData.data.set(max.pixels);

    let minImageData = c.createImageData(
      this.current_image.width, this.current_image.height);
    minImageData.data.set(min.pixels);

    let meanImageData = c.createImageData(
      this.current_image.width, this.current_image.height);
    meanImageData.data.set(mean.pixels);

    c.putImageData(maxImageData, 0, 0);
    c.putImageData(meanImageData, this.current_image.width, 0);
    c.putImageData(minImageData, this.current_image.width * 2, 0);

    await new Promise((accept, reject) => {
      let stream: any = canvas.pngStream();
      let out: any = fs.createWriteStream(name, { autoClose: true });
      stream.on('data', (chunk: any) => out.write(chunk));
      stream.on('end', () => { out.end();} );
      out.on('finish', () => { accept(); });
    });
  }

  async main(iec: number): Promise<any> {
    console.log('IEC: ' + iec);
    let url = API_URL + '/iec_info/' + iec;
    let detail_url = API_URL + '/details/';

    return new Promise((accept, reject) => {
      rp(url).then((body: string) => {
        let json_body: any = JSON.parse(body);
        let file_ids = json_body.file_ids;

        winston.log('info', 'Images in this IEC: ' + file_ids.length);
        images_to_get += file_ids.length;
        bar.total = images_to_get;


        let limit = promiseLimit(5);

        // let promises = file_ids.map(this.getAnImage, this);
        let promises = file_ids.map((id: number) => {
          return limit(() => this.getAnImage(id));
        }, this);

        Promise.all(promises).then(async (data) => {
          winston.log('debug', 'All files downloaded, writing pngs');
          let filename = 'out_' + iec + '.png';
          await this.writePng(this.maximum_projection, this.minimum_projection,
            this.mean_projection, filename);
          await finishImage(this.db, filename, iec);
          accept();
        });
      }).catch((error: any) => console.log("iec_info=", error));
    });
  }

  getAnImage(file_id: number) {
    let url = API_URL + '/details/' + file_id;
    return new Promise((accept, reject) => {
      let options: any = {
        url: url,
        encoding: null, // magic param to get binary back (as a Buffer, supposedly)
        resolveWithFullResponse: true
      };
      winston.log('debug', 'About to get file ' + file_id);
      rp(options).then((response: any) => {
        winston.log('debug', 'About to process file ' + file_id);
        this.current_image = this.processHeaders(response.headers);
        this.current_image.pixel_data = toArrayBuffer(response.body);
        this.file_id = file_id;
        this.draw();

        winston.log('debug', 'Finished processing image: ' + file_id);
        bar.tick();
        accept();
      }).catch((error: any) => process.exit(1));
    });
  }
}


// let k = new K();
// k.main(2372);

let client = pg("postgres://@/posda_files");

async function doOne() {
  let query = `
    update image_equivalence_class i
    set processing_status = 'in-progress'
    where i.image_equivalence_class_id in (
      select image_equivalence_class_id
      from image_equivalence_class
      where processing_status = 'ReadyToProcess'
      limit 1
    )
    returning i.*
  `;

  let result = await client.query(query);

  if (result.length < 1) {
    console.log('No work to do, sleeping for 5 seconds...');
    setTimeout(() => {}, 5000); // cause node to stay open
  } else {
    console.log("Generating images for " + result.length + " IECs...");
  }
  let jobs = result.map((element: any) => {
    return (new K(client)).main(element.image_equivalence_class_id);
  });
  Promise.all(jobs).then(() => pg.end());
}

doOne();
