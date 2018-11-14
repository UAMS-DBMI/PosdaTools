import { Component, OnInit, ElementRef, ViewChild, Input } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';
import { Router, ActivatedRoute, Params } from '@angular/router';
import { FileService } from '../file.service';
import { Image } from '../image';
import { DetailsComponent } from '../details/details.component';
import { MdDialog } from '@angular/material';
import { DumpComponent } from '../dump/dump.component';


// extern def of this built-in js func
declare function createImageBitmap(file: any): Promise<any>;


interface Point {
  x: number;
  y: number;
};

@Component({
  selector: 'app-image',
  templateUrl: './image.component.html',
  styleUrls: ['./image.component.css'],
  inputs: ['file_id']
})
export class ImageComponent implements OnInit {
  @ViewChild('canvas') canvasRef: ElementRef;
  @ViewChild('zoomdiv') zoomRef: ElementRef;
  @Input() image: ArrayBuffer;
  @Input() width: number;
  @Input() height: number;

  private current_image: Image;

  public w_width: number = 400;
  public w_center: number = 40;

  private w_width_override: number = undefined;
  private w_center_override: number = undefined;

  private slope: number = 1;
  private intercept: number = -1024;
  private pixel_pad: number = -1024;

  private mouse_down: boolean = false;
  private init_mouse_coords: number[] = [0, 0];

  private file_id: number;
  private last_file_id: number = -1;


  private canvas: any;
  private context: any;
  private zoom_level: number = 1;
  private offset: Point = { x: 0, y: 0 };

  private roi_display = false;


  constructor(
    private http: Http,
    private service: FileService,
    private route: ActivatedRoute,
    private router: Router,
    private dialog: MdDialog
  ) { }

  ngOnInit() {
    let file_id = this.route.snapshot.params['file_id'];
    if (file_id != undefined) {
      this.file_id = file_id;
      this.loadFile();
    }
  }

  ngAfterViewInit() {
    this.canvas = this.canvasRef.nativeElement;
    this.context = this.canvas.getContext('2d');
    // Do not smooth scaled images on the canvas
    this.context.imageSmoothingEnabled = true;
  }

  ngOnChanges(changes) {
    if (this.file_id == this.last_file_id || this.file_id == undefined)
      return;

    this.last_file_id = this.file_id;
    this.loadFile();
  }

  loadFile(): void {
    this.service.getFile(this.file_id).subscribe(
      res => {
        if (this.current_image == undefined) {
          this.current_image = res;
          this.resetZoom();
        } else {
          this.current_image = res;
          this.draw();
        }
      },
      error => {
        this.drawError();
      }
    );

  }

  drawError(type: number = 0): void {
    let c = this.context;
    c.font = '48px serif';
    c.fillStyle = 'red';
    c.clearRect(0, 0, this.canvas.width, this.canvas.height);
    // manually centered
    if (type == 0) {
      c.fillText('No Pixel Data', 100, 270);
    }
    if (type == 1) {
      c.fillText('Error drawing data', 90, 270);
    }
    if (type == 2) {
      c.fillText('Image too large', 90, 270);
      c.fillText('Check Details', 100, 370);
    }

  }


  applySlopeInterceptWinLev(): Uint8Array {
    this.height = this.current_image.height;
    this.width = this.current_image.width;

    // console.log("drawing");
    let data = this.current_image.pixel_data;
    let source: any = new Uint16Array(data); // load bytes in array
    if(this.current_image.bits_allocated == 8){
      source = new Uint8Array(data); // load bytes in array
    }
    let image = new Uint8Array(source.length);

    // test values ---------
    let slope = this.current_image.slope;

    //TODO: Temp fix for PET images with crazy small slopes
    if (slope < 0.001) {
      slope = 1;
    }

    let intercept = this.current_image.intercept;
    let w_width = this.current_image.window_width;
    let w_center = this.current_image.window_center;
    if (this.w_width_override != undefined) {
      w_width = this.w_width_override;
    }
    if (this.w_center_override != undefined) {
      w_center = this.w_center_override;
    }
    let ppad = this.current_image.pixel_pad;
    // ---------------------

    let w_bottom = w_center - (w_width / 2);
    let w_top = w_center + (w_width / 2);

    // window/level into 8bit array
    for (let i = 0; i < source.length; i++) {
      let val = (source[i] * slope) + intercept;
      // Apply window and level if more than 8 bits allocated
      if(this.current_image.bits_allocated > 8){
        if (val <= w_bottom) {
          image[i] = 0;
        } else if (val > w_top) {
          image[i] = 255;
        } else {
          image[i] = ((val - (w_center - w_width / 2)) / w_width) * 255;
        }
      } else {
        image[i] = val;
        // MONOCHROME2 has reversed colors
        if(this.current_image.photometric_interpretation == 'MONOCHROME2'){
          // javascript for bitwise not
          image[i] = ~image[i];
        }
      }
    }

    return image;
  }

  draw(): void {

    /*
    // width and height should be passed back from the REST endpoint
    if (this.current_image.width > 10000 || this.current_image.height > 10000) {
      this.drawError(2);
      return;
    }
    */
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
      this.drawError(1);
    }
  }

  drawRGB(image: Uint8Array) {
    // console.log(this.current_image.planar_configuration);
    if (this.current_image.planar_configuration == 1) {
      return this.drawRRGGBB(image);
    }

    let c = this.context;
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
    let c = this.context;
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

  drawMono(image: any) {
    let c = this.context;
    let expected_length = this.current_image.width * this.current_image.height * 4;

    let output_image = new Uint8ClampedArray(expected_length); // length in bytes


    for (let i = 0; i < image.length; i++) {
      let j = i * 4;
      output_image[j] = image[i];
      output_image[j+1] = image[i];
      output_image[j+2] = image[i];
      output_image[j+3] = 255; // alpha
    }

    this.drawFinalImage(output_image);
  }


  drawFinalImage(image: Uint8ClampedArray) {
    let c = this.context;
    let newImageData = c.createImageData(
      this.current_image.width, this.current_image.height);
    newImageData.data.set(image);

    /*
     * We could use c.putImageData here, however it does not
     * support scaling. By converting the ImageData into an
     * ImageBitmap (via the extern function createImageBitmap, see
     * definition at the top of this file), we can use c.drawImage
     * and do automatic scaling.
     */
    try {
      createImageBitmap(newImageData).then(img => { //built in js function
        c.clearRect(0, 0, this.canvas.width, this.canvas.height); //clear screen
        c.drawImage(img, this.offset.x, this.offset.y, //actual drawing
          this.current_image.width * this.zoom_level,
          this.current_image.height * this.zoom_level);
      });
    }
    catch (error){
      // Degrade somewhat gracefully for Safari and IE - which don't support createImageBitmap
      console.log("createImageBitmap error");
      c.clearRect(0, 0, this.canvas.width, this.canvas.height);
      c.putImageData(newImageData, 0, 0);
    }
  }

  reset(): void {
    this.w_width_override = undefined;
    this.w_center_override = undefined;
    this.draw();
  }

  winlev(width: number, center: number): void {
    this.w_width_override = width;
    this.w_center_override = center;

    this.draw();
  }

  onChangeCenter(event: any) {
    this.w_center_override = event.value;
    this.draw();
  }
  onChangeWidth(event: any) {
    this.w_width_override = event.value;
    this.draw();
  }

  onMouseDown(event: any): void {
    this.mouse_down = true;
    this.init_mouse_coords = [event.screenX, event.screenY];
  }
  onMouseUp(event: any): void {
    this.mouse_down = false;
  }
  onMouseMove(event: any): void {
    if (event.buttons > 0) {
      let delta_x = event.screenX - this.init_mouse_coords[0];
      let delta_y = event.screenY - this.init_mouse_coords[1];

      this.init_mouse_coords = [event.screenX, event.screenY];

      if (event.shiftKey) {
        // Adjust window/level when holding shift

        if (this.w_center_override == undefined) {
          this.w_center_override = this.w_center;
        }
        if (this.w_width_override == undefined) {
          this.w_width_override = this.w_width;
        }

        this.w_center_override += (delta_x * 2);
        this.w_width_override -= (delta_y * 2);
      } else {
        // pan otherwise
        this.offset.x += delta_x;
        this.offset.y += delta_y;
      }

      this.draw();
    }
  }

  onMouseWheel(event: any): void {
    if (event.deltaY < 0) {
      let old_zoom = this.zoom_level;
      this.zoom_level *= 1.2;

      let factor = 1 - this.zoom_level / old_zoom;
      this.offset.x += (event.offsetX - this.offset.x) * factor;
      this.offset.y += (event.offsetY - this.offset.y) * factor;
    } else {
      let old_zoom = this.zoom_level;
      this.zoom_level *= 0.8;

      let factor = 1 - this.zoom_level / old_zoom;
      this.offset.x += (event.offsetX - this.offset.x) * factor;
      this.offset.y += (event.offsetY - this.offset.y) * factor;
    }

    this.draw();
  }

  resetZoom(): void {
    this.zoom_level = 1;
    this.offset = { x: (512/2) - (this.current_image.width / 2),
                    y: (512/2) - (this.current_image.height / 2) };
    this.draw();
  }

  public getWindowCenter(): number {
    if (this.w_center_override != undefined) {
      return this.w_center_override;
    }
    if (this.current_image !== undefined) {
      return this.current_image.window_center;
    } else {
      return 0;
    }
  }

  public getWindowWidth(): number {
    if (this.w_width_override != undefined) {
      return this.w_width_override;
    }

    if (this.current_image !== undefined) {
      return this.current_image.window_width;
    } else {
      return 0;
    }
  }

  public openDetails(): void {
    let dialogRef = this.dialog.open(DetailsComponent, {
      data: this.file_id
    });
    dialogRef.afterClosed().subscribe(result => {
      console.log(result);
    });
  }
  public openDump(): void {
    let dialogRef = this.dialog.open(DumpComponent, {
      height: '90%',
      width: '75%',
      data: this.file_id
    });
  }
}
