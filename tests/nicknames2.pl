################################################################################
# Test Dispatch::LineReader
################################################################################

use lib 'Posda/include/';

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Posda::Nicknames2;

use Test::Simple tests => 4;

ok(1 + 1 == 2 , 'warmup to make sure everything is sane');


my $project_name = 'Pancreas-CT';
my $site_name = 'NIH-CC-LDRR';
my $subj_id = 'PANCREAS_0001';

my $study_instance_uid = '1.2.826.0.1.3680043.2.1125.1.38381854871216336385978062044218957';
my $series_instance_uid = '1.2.826.0.1.3680043.2.1125.1.68878959984837726447916707551399667';
my $sop_instance_uid = 'TEST_SOP_INST';
my $digest = 'TEST_DIGEST';
my $modality = 'CHEST';


my $nn = Posda::Nicknames2->new($project_name, $site_name, $subj_id);

my $study_nn = $nn->Study($study_instance_uid);
my $series_nn = $nn->Series($series_instance_uid);
my $file_nn = $nn->File($sop_instance_uid, $digest, $modality);

ok($study_nn eq 'STUDY_0');
ok($series_nn eq 'SERIES_0');
ok($file_nn eq 'CHEST_0');
