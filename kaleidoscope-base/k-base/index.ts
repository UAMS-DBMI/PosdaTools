const rp = require('request-promise-native');
const pg = require('pg-promise')();
const Canvas = require('canvas');
const fs = require('fs');
const winston = require('winston');
const cluster = require('cluster');

winston.level = 'error';
if (process.env.DEBUG == 1) {
  winston.level = 'debug';
}

/* 
  Force the pg-promise library to support postgress peer auth,
  by changing the default host to the local unix socket.
*/
pg.pg.defaults.host = '/var/run/postgresql';


// const API_URL = 'http://tcia-posda-rh-1/vapi';
const API_URL = 'http://quince:8088/vapi';

import { Image } from './image';

import { finishImage } from './finish';


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

function workerLog(message: any) {
  console.log("[" + process.pid + "] " + message);
}

class K {// {{{

  iec: number;
  files_to_get: number;
  files_got: number = 0;
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

      // temp fix for PET images with very small slopes
      // When applied, this small slope makes all pixels
      // go to 0, which isn't so good
      if (slope < 0.001) {
        slope = 1;
      }

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
      workerLog(e);
      workerLog(this.current_image);
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

  // This actually prepares a canvas and writes the images into it
  // then calls writeCanvasToFile
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

    winston.log('debug', 'about to await writeCanvasToFile');
    await this.writeCanvasToFile(canvas, name);
  }

  // Async code to actually write a PNG file
  async writeCanvasToFile(canvas: any, name: string): Promise<any> {
    winston.log('debug', 'test1 executing');
    let stream: any = canvas.pngStream();
    let out: any = fs.createWriteStream(name, { autoClose: true });
    stream.on('data', (chunk: any) => out.write(chunk));
    stream.on('end', () => { out.end() });
    // There is no way to await a stream, so we have
    // to use a quick Promise directly
    await new Promise((accept, reject) => {
      out.on('finish', () => { accept() });
    });
  }

  async main(iec: number): Promise<any> {
    this.iec = iec;
    try {
      workerLog('IEC: ' + iec);
      winston.log('debug', iec);
      let url = API_URL + '/iec_info/' + iec;
      let detail_url = API_URL + '/details/';

      winston.log('debug', 'About to request url');
      let body: string = await rp(url);
      let json_body: any = JSON.parse(body);
      let file_ids = json_body.file_ids;

      winston.log('info', 'Images in this IEC: ' + file_ids.length);
      this.files_to_get = file_ids.length;

      for (let i = 0; i < file_ids.length; i++) {
        await this.getAnImage(file_ids[i]);
      }
      winston.log('debug', 'All files downloaded, writing pngs');
      let filename = 'out_' + iec + '.png';
      await this.writePng(this.maximum_projection,
                          this.minimum_projection,
                          this.mean_projection,
                          filename);
      await finishImage(this.db, filename, iec);
    } catch (e) {
      workerLog("Something went wrong with this IEC: " + e);
      flag_as_error(iec);
    }
  }

  async getAnImage(file_id: number): Promise<any> {
    let url = API_URL + '/details/' + file_id;
    let options: any = {
      url: url,
      encoding: null, // magic param to get binary back (as a Buffer, supposedly)
      resolveWithFullResponse: true
    };
    winston.log('debug', 'About to get file ' + file_id);
    let response: any = await rp(options);
    winston.log('debug', 'About to process file ' + file_id);
    this.current_image = this.processHeaders(response.headers);
    this.current_image.pixel_data = toArrayBuffer(response.body);
    this.file_id = file_id;
    this.draw();

    winston.log('debug', 'Finished processing image: ' + file_id);

    this.files_got += 1;
    this.reportProgress();
  }

  reportProgress() {
    if (this.files_got % 10 == 0) {
      workerLog("IEC " + this.iec + " " + this.files_got + "/" + this.files_to_get);
    }
  }

}// }}}


let client: any = pg("postgres://@/posda_files");

async function flag_as_error(iec: number) {
  workerLog("Flagging as error: " + iec);
  await client.query(`
    update image_equivalence_class
    set processing_status = 'error'
    where image_equivalence_class_id = ${iec}
  `);
}

async function error(err: any) {
  // set error state on the IEC here
  workerLog("an error" + err);
}

// Promise-ify setTimeout
function timeout(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function doOne() {
  let query = `
    update image_equivalence_class i
    set processing_status = 'in-progress'
    where i.image_equivalence_class_id in (
      select image_equivalence_class_id
      from image_equivalence_class
      where processing_status = 'ReadyToProcess'
      limit 1
      for update skip locked
    )
    returning i.*
  `;

  let result = await client.query(query);

  if (result.length < 1) {
    winston.log('debug', 'No work to do, sleeping for 5 seconds...');
    await timeout(10000);
  } else {
    workerLog("Generating images for " + result.length + " IECs...");
  }
  let jobs = result.map((element: any) => {
    return (new K(client)).main(element.image_equivalence_class_id);
  });

  Promise.all(jobs)
    .catch((err) => error(err))
    .then(() => pg.end());
}

async function runForever() {
  while (true) {
    try {
      await doOne();
    } catch (e) {
      workerLog(e);
      workerLog("Aborting this worker because of the above error!");
      process.exit(1);
    }
  }
}

if (cluster.isMaster) {
  let worker_count = process.env.WORKERS || 4;
  console.log(`Starting ${worker_count} worker processes...`);

	for (let i = 0; i < worker_count; i++) {
		cluster.fork();
	}

	cluster.on('exit', (worker: any, code: any, signal: any) => {
		console.log("Worker " + worker.process.pid + " has died.");
	});
} else {
  // Looks like I'm a child, time to work!
  workerLog("Worker starting up...");
  runForever();
}

// vim: ts=2 sw=2 expandtab foldmethod=marker
