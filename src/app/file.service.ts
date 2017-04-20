import { Injectable } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';
import { Image } from './image';
import { Observable } from 'rxjs';

@Injectable()
export class FileService {
  private map: { [file_id: number]: Observable<Image>; } = {};

  constructor(private http: Http) {}


  getFile(file_id: number): Observable<Image> {
    // console.log("getFile called");
    if (undefined == this.map[file_id]) {
      this.map[file_id] = this.http.get("/vapi/details/" + file_id, 
                    { responseType: ResponseContentType.ArrayBuffer }).map(
        data => { 
          let img = this.processHeaders(data.headers);
          img.pixel_data = data.arrayBuffer();
          return img;
        }
      ).publishReplay(1).refCount();
    }
    return this.map[file_id];
  }

  processHeaders(headers: any): Image {
    let img = {
      height : Number(headers.get('q-dicom-rows')),
      width : Number(headers.get('q-dicom-cols')),
      window_width : Number(headers.get('q-dicom-window-width')) || 2000,
      window_center : Number(headers.get('q-dicom-window-center')) || 300,
      slope : Number(headers.get('q-dicom-slope')) || 1, 
      intercept : Number(headers.get('q-dicom-intercept')) || 0,
      pixel_pad : Number(headers.get('q-dicom-pixel-pad'))
    };

    return img;
  }
}
