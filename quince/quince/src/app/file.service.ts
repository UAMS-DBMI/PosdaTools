import { Injectable } from '@angular/core';
import { ResponseContentType, Http, Response, RequestOptions, URLSearchParams } from '@angular/http';
import { Image } from './image';
import { Roi } from './roi';
import { Observable } from 'rxjs';
import { ImageDetails } from './image-details';

@Injectable()
export class FileService {
  private map: { [file_id: number]: Observable<Image>; } = {};
  private roi_map: { [file_id: number]: Observable<Roi[]>; } = {};

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


  getDetails(file_id: number): Observable<ImageDetails> {
    return this.http.get("/vapi/extra_details/" + file_id).map(
      res => res.json()
    );
  }



  getRois(file_id: number): Observable<any> {
    if (undefined == this.roi_map[file_id]) {
      this.roi_map[file_id] = this.http.get("/vapi/details/ROI/" + file_id).map(
        res => res.json()
      ).publishReplay(1).refCount();
    }
    return this.roi_map[file_id];
  }


  getDump(file_id: number): Observable<any> {
    return this.http.get("/papi/v1/dump/" + file_id).map(
      res => res.text()
    );
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

/*  processRoiHeaders(headers: any): Roi {
    let roi = {
      roi_id: Number(headers.get('roi_id')),
      roi_name: Number(headers.get('roi_name')),
      roi_contour_id: Number(headers.get('roi_contour_id')),
      pixel_rows: Number(headers.get('pixel_rows')),
      pixel_columns: Number(headers.get('pixel_columns')),
      ipp: headers.get('ipp'),
      pixel_spacing: headers.get('pixel_spacing'),
      roi_color: headers.get('roi_color'),
      countour_data: headers.get('countour_data'),
    };

    return roi;
  }
  */
}
