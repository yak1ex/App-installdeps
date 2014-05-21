use Test::More;
use Test::Exception;
use Capture::Tiny qw(capture);
use FindBin;
use lib "$FindBin::Bin/target2";
use Getopt::Config::FromPod;
Getopt::Config::FromPod->set_class_default(-file => 'bin/installdeps');

my @tests = (
	['-Nu',   ['target2/1.pl'], <<EOF, '-Nu'],
$FindBin::Bin/target2/1.pl
  App::installdeps::Dummy
EOF
	['-NR',   ['target2/1.pl'], <<EOF, '-NR'],
$FindBin::Bin/target2/1.pl
  (App::installdeps::Dummy)
    App::installdeps::Dummy2
    App::installdeps::Dummy3
EOF
	['-NRu',  ['target2/1.pl'], <<EOF, '-NRu'],
$FindBin::Bin/target2/1.pl
  App::installdeps::Dummy
    App::installdeps::Dummy2
    App::installdeps::Dummy3
EOF
	['-Nur',  ['target2/1.pl'], <<EOF, '-Nur'],
$FindBin::Bin/target2/1.pl
  App::installdeps::Dummy
EOF
	['-NRr',  ['target2/1.pl'], <<EOF, '-NRr'],
$FindBin::Bin/target2/1.pl
  (App::installdeps::Dummy)
    App::installdeps::Dummy2
EOF
	['-NRru', ['target2/1.pl'], <<EOF, '-NRru'],
$FindBin::Bin/target2/1.pl
  App::installdeps::Dummy
    App::installdeps::Dummy2
EOF
	['-N',   [qw(target/1.pl target/2.pl)], <<EOF, 'multi -N'],
$FindBin::Bin/target/1.pl
$FindBin::Bin/target/2.pl
EOF
	['-Nu',  [qw(target/1.pl target/2.pl)], <<EOF, 'multi -Nu'],
$FindBin::Bin/target/1.pl
  App::installdeps
  Test::More
$FindBin::Bin/target/2.pl
  Test::Exception
  Test::More [+]
EOF
	['-Nru', [qw(target/1.pl target/2.pl)], <<EOF, 'multi -Nru'],
$FindBin::Bin/target/1.pl
  App::installdeps
  Test::More
$FindBin::Bin/target/2.pl
  Test::More [+]
EOF
	['-N',   ['target'], <<EOF, 'dir -N'],
$FindBin::Bin/target/1.pl
$FindBin::Bin/target/2.pl
EOF
	['-Nu',  ['target'], <<EOF, 'dir -Nu'],
$FindBin::Bin/target/1.pl
  App::installdeps
  Test::More
$FindBin::Bin/target/2.pl
  Test::Exception
  Test::More [+]
EOF
	['-Nru', ['target'], <<EOF, 'dir -Nru'],
$FindBin::Bin/target/1.pl
  App::installdeps
  Test::More
$FindBin::Bin/target/2.pl
  Test::More [+]
EOF
);

plan tests => 1 + 3 * @tests;

use_ok 'App::installdeps';

foreach my $test (@tests) {
	my ($opts, $target);
	my ($stdout, $stderr);
	lives_ok { ($stdout, $stderr) = capture { App::installdeps->run(ref $test->[0] ? @{$test->[0]} : $test->[0], map { "$FindBin::Bin/$_" } @{$test->[1]}) }; } "$test->[3] - lives_ok";
	is($stdout, $test->[2], "$test->[3] - stdout");
	is($stderr, '', "$test->[3] - stderr");
}
