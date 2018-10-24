delete from permissions
where app_id = (select app_id from apps where app_name = 'DbIf')
  and permission_name = 'update';

insert into permissions (app_id, permission_name) values 
((select app_id from apps where app_name = 'DbIf'), 'view_posda_backlog'),
((select app_id from apps where app_name = 'DbIf'), 'manage_posda_backlog'),
((select app_id from apps where app_name = 'DbIf'), 'downloads_by_date'),
((select app_id from apps where app_name = 'DbIf'), 'duplicate_sop_evaluation'),
((select app_id from apps where app_name = 'DbIf'), 'duplicate_sop_resolution'),
((select app_id from apps where app_name = 'DbIf'), 'counts_patient_status'),
((select app_id from apps where app_name = 'DbIf'), 'consistency_check'),
((select app_id from apps where app_name = 'DbIf'), 'linkage_check'),
((select app_id from apps where app_name = 'DbIf'), 'visual_review_scheduling'),
((select app_id from apps where app_name = 'DbIf'), 'visual_review_tracking_processing'),
((select app_id from apps where app_name = 'DbIf'), 'phi_review'),
((select app_id from apps where app_name = 'DbIf'), 'dicom_batch_file_editing'),
((select app_id from apps where app_name = 'DbIf'), 'send_data_via_dicom'),
((select app_id from apps where app_name = 'DbIf'), 'monthly_report_queries'),
((select app_id from apps where app_name = 'DbIf'), 'superuser')
;
