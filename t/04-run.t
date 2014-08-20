use Test::More;
use Test::Exception;
use Capture::Tiny qw(capture);
use FindBin;
use lib "$FindBin::Bin/target2";
use Getopt::Config::FromPod;
Getopt::Config::FromPod->set_class_default(-file => 'bin/installdeps');

my @tests = (
	[['-u', '-i', "$FindBin::Bin/dummy -S"], ['target/1.pl'], <<EOF, '-iu'],
$FindBin::Bin/dummy -S Test::More App::installdeps
-S,Test::More,App::installdeps
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
