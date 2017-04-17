import { Component, OnInit, ElementRef, ViewChild, Input } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';

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

  private w_width: number = 400;
  private w_center: number = 40;
  private slope: number = 1;
  private intercept: number = -1024;
  private pixel_pad: number = -1024;

  private mouse_down: boolean = false;
  private init_mouse_coords: number[] = [0, 0];

  private file_id: number;
  private last_file_id: number = -1;


  // private width: number = 512;
  // private height: number = 512;

  private canvas: any;
  private zoom_state: boolean = false;


  constructor(private http: Http) { 
  }

  ngOnInit() {
  }
  ngAfterViewInit() {
    this.canvas = this.canvasRef.nativeElement;
  }

  ngOnChanges(changes) {
    if (this.file_id == this.last_file_id || this.file_id == undefined)
      return;

    this.last_file_id = this.file_id;
    console.log("ngOnChanges called, file_id is", this.file_id);
    this.http.get("/api/details/" + this.file_id, { responseType: ResponseContentType.ArrayBuffer }).subscribe(
      data => { 
        this.image = data.arrayBuffer();
        this.processHeaders(data.headers);
        this.draw();
      }
      );
    }

  processHeaders(headers: any) {
    // see if we can get all the correct info from the headers
    this.height = Number(headers.get('q-dicom-rows'));
    this.width = Number(headers.get('q-dicom-cols'));
    this.w_width = Number(headers.get('q-dicom-window-width')); 
    this.w_center = Number(headers.get('q-dicom-window-center')); 
    this.slope = Number(headers.get('q-dicom-slope')); 
    this.intercept = Number(headers.get('q-dicom-intercept')); 
    this.pixel_pad = Number(headers.get('q-dicom-pixel-pad')); 

    console.log(headers);
  }

  draw(): void {



    // console.log("drawing");
    let data = this.image;
    let source = new Uint16Array(data); // load bytes in array
    let image = new Uint8Array(source.length);

  // test values ---------
  let slope = this.slope;
  let intercept = this.intercept;
  let w_width = this.w_width;
  let w_center = this.w_center;
  let ppad = this.pixel_pad;
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

    c.putImageData(newImageData, 0, 0);
  }

  reset(): void {
    // TODO: hardcoded, fix this!!
    this.w_width = 400;
    this.w_center = 40;
    this.draw();
  }

  winlev(preset: string): void {
    if (preset == 'bone') {
      this.w_width = 2000;
      this.w_center = 300;
    } else if (preset == 'soft-tissue') {
      this.w_width = 470;
      this.w_center = 20;
    }

    this.draw();
  }

  onChangeCenter(event: any) {
    this.w_center = event.value;
    this.draw();
  }
  onChangeWidth(event: any) {
    this.w_width = event.value;
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
      let delta_x = event.screenX - this.init_mouse_coords[0];
      let delta_y = event.screenY - this.init_mouse_coords[1];
      
      this.init_mouse_coords = [event.screenX, event.screenY];

      this.w_center += (delta_x * 2);
      this.w_width -= (delta_y * 2);
      this.draw();
    }
  }
}
