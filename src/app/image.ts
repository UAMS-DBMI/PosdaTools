export interface Image {
    height: number;
    width: number;
    window_width: number;
    window_center: number;
    slope: number;
    intercept: number;
    pixel_pad: number;
    pixel_data?: ArrayBuffer;
}
