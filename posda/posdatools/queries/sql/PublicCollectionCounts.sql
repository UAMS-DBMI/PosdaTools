-- Name: PublicCollectionCounts
-- Schema: public
-- Columns: ['Collection', 'Modalities', 'Pts', 'Studies', 'Series', 'Images', 'GBytes']
-- Args: ['collection', 'visibility']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get public totals for collection
-- 
-- Used to fill in "Detailed description" on public Wiki page
-- 
-- 

select
        tdp.project as Collection,'|',
        group_concat(distinct s.modality) as Modalities,'|',
        count(distinct p.patient_id) as Pts,'|',
        count(distinct t.study_instance_uid) as Studies,'|',
        count(distinct s.series_instance_uid) as Series,'|',
        count(distinct i.sop_instance_uid) as Images, '|',
        format(sum(i.dicom_size)/1000000000,1) as GBytes
 
     from
        general_image i,
        general_series s,
        study t,
        patient p,
        trial_data_provenance tdp
 
     where
        i.general_series_pk_id = s.general_series_pk_id and
        s.study_pk_id = t.study_pk_id and
        t.patient_pk_id = p.patient_pk_id and
        p.trial_dp_pk_id = tdp.trial_dp_pk_id and
        tdp.project =?
 
     group by tdp.project