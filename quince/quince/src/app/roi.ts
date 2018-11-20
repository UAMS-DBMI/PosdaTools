export interface Roi {
    roi_id: number;
    roi_name: number;
    roi_contour_id: number;
    pixel_rows: number;
    pixel_columns: number;
    ipp: number[];
    pixel_spacing: number[];
    roi_color: number[];
    contour_data: number[][];
}
