-- Name: IntakeCountsOld
-- Schema: intake
-- Columns: ['PID', 'Modality', 'Images', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions', 'ImageType', 'ReconstructionDiameter', 'KVP', 'SliceThickness']
-- Args: ['collection', 'site']
-- Tags: ['intake']
-- Description: List of all Files Images By Collection, Site
-- 

select
        p.patient_id as PID,
        i.image_type as ImageType,
        s.modality as Modality,
        count(i.sop_instance_uid) as Images,
        t.study_date as StudyDate,
        t.study_desc as StudyDescription,
        s.series_desc as SeriesDescription,
        s.series_number as SeriesNumber,
        t.study_instance_uid as StudyInstanceUID,
        s.series_instance_uid as SeriesInstanceUID,
        q.manufacturer as Mfr,
        q.manufacturer_model_name as Model,
        q.software_versions,
        c.reconstruction_diameter as ReconstructionDiameter,
        c.kvp as KVP,
        i.slice_thickness as SliceThickness
     from
        general_image i,
        general_series s,
        study t,
        patient p,
        trial_data_provenance tdp,
        general_equipment q,
        ct_image c
     where
        i.general_series_pk_id = s.general_series_pk_id and
        s.study_pk_id = t.study_pk_id and
        s.general_equipment_pk_id = q.general_equipment_pk_id and
        t.patient_pk_id = p.patient_pk_id and
        p.trial_dp_pk_id = tdp.trial_dp_pk_id and
        tdp.project = ? and
        tdp.dp_site_name = ? and
        c.image_pk_id = i.image_pk_id
    group by p.patient_id, i.image_type, s.series_instance_uid, t.study_instance_uid
