-- Name: GetPublicHierarchyBySopInstance
-- Schema: public
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'sop_instance_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['Hierarchy']
-- Description: Get Patient, Study, Series, Modality, Sop Instance by sop_instance from public database

select
  i.patient_id, s.study_instance_uid, s.series_instance_uid, modality, sop_instance_uid
from 
  general_image i, general_series s where sop_instance_uid = ? and
  s.general_series_pk_id = i.general_series_pk_id