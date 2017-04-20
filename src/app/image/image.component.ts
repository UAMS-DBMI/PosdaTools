import { Component, OnInit, ElementRef, ViewChild, Input } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';
import { Router, ActivatedRoute, Params } from '@angular/router';
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
  private context: any;
  private zoom_level: number = 1;
  private offset: Point = { x: 0, y: 0 };


  constructor(
    private http: Http, 
    private service: FileService,
    private route: ActivatedRoute,
    private router: Router
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
    let c = this.context;
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

    /*
     * We could use c.putImageData here, however it does not 
     * support scaling. By converting the ImageData into an
     * ImageBitmap (via the extern function createImageBitmap, see 
     * definition at the top of this file), we can use c.drawImage
     * and do automatic scaling.
     */
    createImageBitmap(newImageData).then(img => {
      c.clearRect(0, 0, this.canvas.width, this.canvas.height);
      c.drawImage(img, this.offset.x, this.offset.y, 
                  this.current_image.width * this.zoom_level, 
                  this.current_image.height * this.zoom_level);

      // alternate method of applying the scale and translation
      // don't think this is any faster/slower
      // c.save();
      // c.scale(this.zoom_level, this.zoom_level);
      // c.translate(this.offset.x, this.offset.y);
      // c.drawImage(img, 0, 0);
      // c.restore();
    });
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
    console.log(event.deltaY);
    if (event.deltaY < 0) {
      this.zoom_level += 0.5;
      this.offset.x -= this.current_image.width * 0.25;
      this.offset.y -= this.current_image.height * 0.25;
    } else {
      this.zoom_level -= 0.5;
      if (this.zoom_level < 1) {
        this.zoom_level = 1;
      } else {
        this.offset.x += this.current_image.width * 0.25;
        this.offset.y += this.current_image.height * 0.25;
      }
    }


    this.draw();
  }

  resetZoom(): void {
    this.zoom_level = 1;
    this.offset = { x: (512/2) - (this.current_image.width / 2), 
                    y: (512/2) - (this.current_image.height / 2) };
    this.draw();
  }
}
