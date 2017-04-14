import { Component, OnInit, ElementRef, ViewChild, Input } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';

@Component({
  selector: 'app-image',
  templateUrl: './image.component.html',
  styleUrls: ['./image.component.css']
})
export class ImageComponent implements OnInit {
  @ViewChild('canvas') canvasRef: ElementRef;
  @ViewChild('zoomdiv') zoomRef: ElementRef;
  @Input() image: ArrayBuffer;
  @Input() width: number;
  @Input() height: number;

	private w_width: number = 400;
	private w_center: number = 40;


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
	this.http.get("data", { responseType: ResponseContentType.ArrayBuffer }).subscribe(
	data => { 
		this.image = data.arrayBuffer();
		this.draw();
	}
	);
  }

  draw(): void {
  	console.log("drawing");
  	let data = this.image;
	let source = new Uint16Array(data); // load bytes in array
	let image = new Uint8Array(source.length);

	// test values ---------
	let slope = 1;
	let intercept = -1024;
	let w_width = this.w_width;
	let w_center = this.w_center;
	let ppad = -1024;
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

	onChangeCenter(event: any) {
		this.w_center = event.value;
		this.draw();
	}
	onChangeWidth(event: any) {
		this.w_width = event.value;
		this.draw();
	}
}
