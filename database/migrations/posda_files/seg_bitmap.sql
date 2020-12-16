--
-- Name: seg_bitmap_file
--

CREATE TABLE public.seg_bitmap_file (
    seg_bitmap_file_id integer unique NOT NULL,
    number_segmentations integer NOT NULL,
    num_slices integer NOT NULL,
    rows integer NOT NULL,
    cols integer NOT NULL,
    frame_of_reference_uid text NOT NULL,
    patient_id text NOT NULL,
    study_instance_uid text NOT NULL,
    series_instance_uid text NOT NULL,
    sop_instance_uid text NOT NULL,
    pixel_offset integer NOT NULL
);



--
-- Name: seg_bitmap_related_sops
--

CREATE TABLE public.seg_bitmap_related_sops (
    seg_bitmap_file_id integer NOT NULL,
    series_instance_uid text,
    sop_instance_uid text
);


--
-- Name: seg_bitmap_segmentation
--

CREATE TABLE public.seg_bitmap_segmentation (
    seg_bitmap_file_id integer NOT NULL,
    segmentation_num integer,
    label text,
    description text,
    color text,
    algorithm_type text,
    algorithm_name text,
    segmented_category text,
    segmented_type text
);


--
-- Name: seg_slice_bitmap_bare_point
--

CREATE TABLE public.seg_slice_bitmap_bare_point (
    seg_bitmap_file_id integer NOT NULL,
    seg_bitmap_slice_no integer NOT NULL,
    point text NOT NULL
);


--
-- Name: seg_slice_bitmap_file
--

CREATE TABLE public.seg_slice_bitmap_file (
    seg_slice_bitmap_file_id integer NOT NULL,
    seg_bitmap_slice_no integer NOT NULL,
    seg_bitmap_file_id integer NOT NULL,
    segmentation_number integer NOT NULL,
    iop text NOT NULL,
    ipp text NOT NULL,
    total_one_bits integer NOT NULL,
    num_bare_points integer NOT NULL
);

--
-- Name: seg_slice_bitmap_file_related_image
--

CREATE TABLE public.seg_slice_bitmap_file_related_image (
    seg_bitmap_file_id integer NOT NULL,
    seg_bitmap_slice_no integer NOT NULL,
    sop_instance_uid text NOT NULL
);

--
-- Name: seg_slice_to_contour
--

CREATE TABLE public.seg_slice_to_contour (
    seg_slice_bitmap_file_id integer NOT NULL,
    rows integer NOT NULL,
    cols integer NOT NULL,
    num_contours integer NOT NULL,
    num_points integer NOT NULL,
    contour_slice_file_id integer NOT NULL
);


