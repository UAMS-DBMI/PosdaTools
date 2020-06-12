create type transfer_status_type as enum (
        'pending',
        'success',
        'failed temporary',
        'failed permanent'
);
comment on type transfer_status_type is 'The status of an export_event transfer of a file';
create type export_status_type as enum (
        'paused',
        'transfering',
        'finished success',
        'finished failure'
);
comment on type export_status_type is 'The status of an export_event';
create type submitter_type_type as enum (
        'unrecorded',
        'subprocess_invocation'
);
comment on type submitter_type_type is 'What application type made this request';
create type request_status_type as enum (
        'start',
        'pause',
        'abort',
        'retry failures'
);
comment on type request_status_type is 'Options for user-originated requests for status change';
create table export_destination (
        export_destination_name text primary key,
        protocol text not null,
        base_url text not null,
        configuration json
);
comment on table export_destination is 'A list of destinations to export to';
comment on column export_destination.export_destination_name is 'A human-readable name for this configured destination';
comment on column export_destination.protocol is 'System type: nbia, posda';
comment on column export_destination.configuration is 'Full configuration settings for the destination, stored as json';
create table transfer_status (
        transfer_status_id serial primary key,
        transfer_status_message text not null unique
);
comment on table transfer_status is 'Detailed error messages for export_event status';
create table export_event (
        export_event_id serial primary key,
        submitter_type submitter_type_type not null default 'unrecorded',
        subprocess_invocation_id integer references subprocess_invocation(subprocess_invocation_id),
        export_destination_name text not null references export_destination(export_destination_name),
        creation_time timestamp not null,
        start_time timestamp,
        end_time timestamp,
        dismissed_time timestamp,
        request_pending boolean not null default false,
        request_status request_status_type,
        export_status export_status_type,
        destination_import_event_id integer,
        destination_import_event_closed boolean,
        transfer_status_id integer references transfer_status(transfer_status_id) -- for detailed human readable text
);
comment on table export_event is 'Track exports from Posda to other systems';
comment on column export_event.request_pending is 'If true, a user-originated request is waiting to be processed';
comment on column export_event.request_status is 'A user-originated request for action on this request';
comment on column export_event.export_status is 'The current status of this export, as set by the export daemon';
create table file_export (
        export_event_id integer not null references export_event(export_event_id),
        file_id integer not null references file(file_id),
        export_file_dispositions_params_id integer,
        when_queued timestamp not null,
        when_transferred timestamp,
        transfer_status transfer_status_type,
        transfer_status_id integer references transfer_status(transfer_status_id)
);
comment on table file_export is 'Files to export';
create table export_file_dispositions_params(
        export_file_dispositions_params_id serial primary key,
        offset_days integer,
        uid_root text,
        only_modify_group_13 boolean
);
