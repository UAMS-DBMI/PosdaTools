################################################################################
# Test Posda::Nicknames2
################################################################################

use lib 'Posda/include/';

use Modern::Perl '2010';

use Test::More tests => 11;

use Posda::Nicknames2;
# use Posda::Nicknames2Factory;

my $project_name = 'nn-test-project';
my $site_name = 'nn-test-site';
my $subj_id = 'nn-test-subj';

my $study_instance_uid = 'nn-test-study-inst-uid';
my $series_instance_uid = 'nn-test-series-inst-uid';
my $sop_instance_uid = 'nn-test-sop-inst-uid';
my $for_instance_uid = 'nn-test-for-inst-uid';
my $digest = 'nn-test-digest2';
my $modality = 'TEST';


my $nn = Posda::Nicknames2::get($project_name, $site_name, $subj_id);

my $study_nn = $nn->FromStudy($study_instance_uid);
my $series_nn = $nn->FromSeries($series_instance_uid);
my $file_nn = $nn->FromFile($sop_instance_uid, $digest, $modality);
my $for_nn = $nn->FromFor($for_instance_uid);

like($study_nn, qr/STUDY_/, 'FromStudy');
like($series_nn, qr/SERIES_/, 'FromSeries');
like($file_nn, qr/TEST_/, 'FromFile');
like($for_nn, qr/FOR_/, 'FromFor');

{
  # make sure all failures are graceful in reverse
  # should all return undef
  my $tname = "graceful failures in reverse";
  if (not defined $nn->ToStudy('BADDATA') and
      not defined $nn->ToSeries('BADDATA') and
      not defined $nn->ToFor('BADDATA') and
      not defined $nn->ToSop('BADDATA')) {
    pass($tname);
  } else {
    fail($tname);
  }
}

is($nn->ToFor($for_nn), 'nn-test-for-inst-uid', 'ToFor');
is($nn->ToStudy($study_nn), 'nn-test-study-inst-uid', 'ToStudy');
is($nn->ToSeries($series_nn), 'nn-test-series-inst-uid', 'ToSeries');
is($nn->ToSop($file_nn), 'nn-test-sop-inst-uid', 'ToSop');
for my $f (@{$nn->ToFiles($file_nn)}) {
  is($f, 'nn-test-digest2', 'ToFiles');
  last;
}

is_deeply($nn->FromUnknown($sop_instance_uid), [
  { 'nickname_type' => 'file',
    'nickname' => 'TEST_0',
    'project_name' => 'nn-test-project',
    'site_name' => 'nn-test-site',
    'subj_id' => 'nn-test-subj' },

  { 'nickname_type' => 'sop',
    'nickname' => 'TEST_0',
    'project_name' => 'nn-test-project',
    'site_name' => 'nn-test-site',
    'subj_id' => 'nn-test-subj' },

], 'FromUnknown');

is(Posda::Nicknames2::clear(), undef);
