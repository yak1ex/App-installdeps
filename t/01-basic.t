use Test::More;
use Test::Exception;
use FindBin;

use_ok 'App::installdeps';

my @tests = (
	['-n',   ['1.pl'], [], 'simple -n'],
	['-nu',  ['1.pl'], [qw(Test::More App::installdeps)], 'simple -nu'],
	['-nru', ['1.pl'], [qw(Test::More App::installdeps)], 'simple -nru'],
	['-n',   ['2.pl'], [], 'eval -n'],
	['-nu',  ['2.pl'], [qw(Test::More Test::Exception)], 'eval -nu'],
	['-nru', ['2.pl'], [qw(Test::More)], 'eval -nru'],
);

plan tests => 1 + 2 * @tests;

foreach my $test (@tests) {
	my ($opts, $target);
	lives_ok { ($opts, $target) = App::installdeps::_process($test->[0], map { "$FindBin::Bin/$_" } @{$test->[1]}) };
	is_deeply($target, $test->[2], $test->[3]);
}
