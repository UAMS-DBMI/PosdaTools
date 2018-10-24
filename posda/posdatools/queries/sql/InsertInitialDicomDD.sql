-- Name: InsertInitialDicomDD
-- Schema: dicom_dd
-- Columns: []
-- Args: ['tag', 'name', 'keyword', 'vr', 'vm', 'is_retired', 'comments']
-- Tags: ['Insert', 'NotInteractive', 'dicom_dd']
-- Description: Insert row into dicom_dd database

insert into dicom_element(tag, name, keyword, vr, vm, is_retired, comments)
values (?,?,?,?,?,?,?)