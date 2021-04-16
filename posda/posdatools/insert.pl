use Modern::Perl;

use Redis;
use JSON;

use Posda::Config ('Config', 'Database');
use DBD::Pg;

use Data::Dumper;

use constant REDIS_HOST => Config('redis_host') . ':6379';

my $redis = Redis->new(server => REDIS_HOST);
my $db = DBI->connect(Database('posda_files'));

my $q = $db->prepare(qq{
  select file_id, root_path || '/' || rel_path as path
  from file
  natural join file_location
  natural join file_storage_root
  where is_dicom_file is null
    and ready_to_process
    and processing_priority is not null
});

$q->execute();

while(my $h = $q->fetchrow_arrayref){
  my $json_string = encode_json($h);
  say $json_string;
  $redis->lpush('files', $json_string);
}

$redis->quit;
