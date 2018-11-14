export interface Image {
    height: number;
    width: number;
    window_width: number;
    window_center: number;
    slope: number;
    intercept: number;
    pixel_pad: number;
    samples_per_pixel: number;
    pixel_representation: number;
    photometric_interpretation: string;
    planar_configuration: number;
    bits_allocated: number;
    bits_stored: number;
    pixel_data?: ArrayBuffer;
}
