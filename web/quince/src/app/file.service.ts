import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Image } from './image';
import { Roi } from './roi';
import { Observable } from 'rxjs';
import { ImageDetails } from './image-details';

import { map, publishReplay, refCount } from 'rxjs/operators';


@Injectable()
export class FileService {
  private map: { [file_id: number]: Observable<Image>; } = {};
  private roi_map: { [file_id: number]: Observable<Roi[]>; } = {};

  constructor(private http: HttpClient) {}


  getFile(file_id: number): Observable<Image> {
    // console.log("getFile called");
    if (undefined == this.map[file_id]) {
		this.map[file_id] = this.http.get("/papi/v1/files/" + file_id + "/pixels",
        { observe: 'response', responseType: 'arraybuffer' }).pipe(
        map(
          response => {
            let img = this.processHeaders(response.headers);
            img.pixel_data = response.body;
            return img;
          }),
        publishReplay(1),
        refCount()
      );
    }
    return this.map[file_id];
  }


  getDetails(file_id: number): Observable<ImageDetails> {
	  return this.http.get<ImageDetails>("/papi/v1/files/" + file_id + "/details");
  }

  getRois(file_id: number):Observable<Roi[]> {
    if (undefined == this.roi_map[file_id]) {
      this.roi_map[file_id] = this.http.get<Roi[]>("/papi/v1/rois/file/" + file_id)
        .pipe(
          publishReplay(1),
          refCount());
    }
    return this.roi_map[file_id];
  }

  getDump(file_id: number): Observable<any> {
    return this.http.get("/papi/v1/dump/" + file_id, {responseType: 'text'});
  }

  processHeaders(headers: any): Image {
    let img = {
      height : Number(headers.get('q-dicom-rows')),
      width : Number(headers.get('q-dicom-cols')),
      window_width : Number(headers.get('q-dicom-window-width')) || 2000,
      window_center : Number(headers.get('q-dicom-window-center')) || 300,
      slope : Number(headers.get('q-dicom-slope')) || 1,
      intercept : Number(headers.get('q-dicom-intercept')) || 0,
      pixel_pad : Number(headers.get('q-dicom-pixel-pad')),
      samples_per_pixel: Number(headers.get('q-dicom-samples-per-pixel')),
      pixel_representation: Number(headers.get('q-dicom-pixelrep')),
      photometric_interpretation: headers.get('q-dicom-photorep'),
      planar_configuration: headers.get('q-dicom-planar-config'),
      bits_stored: headers.get('q-dicom-bits-stored'),
      bits_allocated: headers.get('q-dicom-bits-allocated'),
    };

    return img;
  }
}
