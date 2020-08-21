export interface Roi {
    name: string;
    color: number[];
    points: number[][];
}
export interface Contour {
  name: string;
  enabled: boolean;
  color: string;
}
export interface ContourSet {
  roi_num: number;
  name: string;
  color: number[];
  file_ids: number[];
}

export interface StructFile {
  rois_set: Roi[];
}
