import { Component, OnInit, ElementRef, ViewChild, Input } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';
import { FileService } from '../file.service';
import { Image } from '../image';


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
  private zoom_level: number = 1;
  private offset: Point = { x: 0, y: 0 };


  constructor(private http: Http, private service: FileService) { }

  ngOnInit() { }

  ngAfterViewInit() {
    this.canvas = this.canvasRef.nativeElement;
  }

  ngOnChanges(changes) {
    if (this.file_id == this.last_file_id || this.file_id == undefined)
      return;

    this.last_file_id = this.file_id;

    this.service.getFile(this.file_id).subscribe(
      res => {
        this.current_image = res;
        this.draw();
      }
    );
  }

  draw(): void {

    this.height = this.current_image.height;
    this.width = this.current_image.width;

    // console.log("drawing");
    let data = this.current_image.pixel_data;
    let source = new Uint16Array(data); // load bytes in array
    let image = new Uint8Array(source.length);

    // test values ---------
    let slope = this.current_image.slope;
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
    for (var i = 0; i < source.length; i++) {
      let val = (source[i] * slope) + intercept;
      if (val <= w_bottom) {
        image[i] = 0;
      } else if (val > w_top) {
        image[i] = 255;
      } else {
        image[i] = ((val - (w_center - w_width / 2)) / w_width) * 255;
      }
    }

    // width and height should be passed back from the REST endpoint
    this.drawMono(image);
  }

  drawMono(image: any) {
    const c = this.canvas.getContext('2d');
    c.imageSmoothingEnabled = false;
    var test8 = new Uint8ClampedArray(image.length * 4); // length in bytes 

    for (var i = 0; i < image.length; i++) {
      let j = i * 4;
      test8[j] = image[i];
      test8[j+1] = image[i];
      test8[j+2] = image[i];
      test8[j+3] = 255; // alpha
    }

    var newImageData = c.createImageData(this.width, this.height);
    newImageData.data.set(test8);

    createImageBitmap(newImageData).then(img => {
      if (this.zoom_level > 1) {
        c.clearRect(0, 0, this.width, this.height);
      }
      c.drawImage(img, this.offset.x, this.offset.y, 
                  this.current_image.width * this.zoom_level, 
                  this.current_image.height * this.zoom_level);
    });

    // c.putImageData(newImageData, 0, 0);
  }

  reset(): void {
    this.w_width_override = undefined;
    this.w_center_override = undefined;
    this.draw();
  }

  winlev(preset: string): void {
    if (preset == 'bone') {
      this.w_width_override = 2000;
      this.w_center_override = 300;
    } else if (preset == 'soft-tissue') {
      this.w_width_override = 470;
      this.w_center_override = 20;
    }

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
    if (this.mouse_down) {


      if (this.w_center_override == undefined) {
        this.w_center_override = this.w_center;
      }
      if (this.w_width_override == undefined) {
        this.w_width_override = this.w_width;
      }


      let delta_x = event.screenX - this.init_mouse_coords[0];
      let delta_y = event.screenY - this.init_mouse_coords[1];

      this.init_mouse_coords = [event.screenX, event.screenY];


      if (this.zoom_level > 1) {
        this.offset.x += delta_x;
        this.offset.y += delta_y;
        this.draw();
        return;
      }

      this.w_center_override += (delta_x * 2);
      this.w_width_override -= (delta_y * 2);
      this.draw();
    }
  }

  testButton() {
  this.service.getFile(3410753).subscribe(
    res => {
      console.log("called");
      console.log(res);
    }
  );
  }

  zoomIn(): void {
    this.zoom_level += 1;
    this.draw();
  }

  zoomOut(): void {
    this.zoom_level -= 1;
    if (this.zoom_level < 1) {
      this.zoom_level = 1;
    }
    this.offset = { x: 0, y: 0 };
    this.draw();

  }
}
