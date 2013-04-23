use Test::More;
use Test::Exception;
use FindBin;

use_ok 'App::installdeps';
my ($opts, $target);
#lives_ok { ($opts, $target) = App::installdeps::_process() };
lives_ok { ($opts, $target) = App::installdeps::_process('-n', "$FindBind::Bin/1.pl") };
is_deeply($target, [], 'simple');
lives_ok { ($opts, $target) = App::installdeps::_process('-nu', "$FindBin::Bin/1.pl") };
is_deeply($target, [qw(Test::More App::installdeps)], 'simple');
