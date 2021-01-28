
--
-- Name: struct_contours_to_slice
--

CREATE TABLE public.bad_struct_contours_to_slice (
    structure_set_file_id integer NOT NULL,
    image_file_id integer NOT NULL,
    roi_num integer NOT NULL,
    rows integer NOT NULL,
    cols integer NOT NULL,
    num_contours integer NOT NULL,
    num_points integer NOT NULL,
    total_one_bits integer NOT NULL,
    contour_slice_file_id integer NOT NULL,
    segmentation_slice_file_id integer NOT NULL,
    png_slice_file_id integer NOT NULL
);

