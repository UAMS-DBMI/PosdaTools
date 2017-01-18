-- Revert posda:spreadsheet from pg

BEGIN;

drop TABLE spreadsheet_operation;

COMMIT;
