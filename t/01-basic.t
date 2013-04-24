use Test::More;
use Test::Exception;
use FindBin;

use_ok 'App::installdeps';

my @tests = (
	['-n',  ['1.pl'], [], 'simple -n'],
	['-nu', ['1.pl'], [qw(Test::More App::installdeps)], 'simple -nu'],
);

plan tests => 1 + 2 * @tests;

foreach my $test (@tests) {
	my ($opts, $target);
	lives_ok { ($opts, $target) = App::installdeps::_process($test->[0], map { "$FindBin::Bin/$_" } @{$test->[1]}) };
	is_deeply($target, $test->[2], $test->[3]);
}
