package App::installdeps;

use strict;
use warnings;

# ABSTRACT: A tiny script to install dependent modules
# VERSION

use Getopt::Std;
use Getopt::Config::FromPod;
use Pod::Usage;

use Module::ExtractUse;
use File::Find;

sub _exists
{
	my $module = shift;
	unless($module =~ /\.pm$/) {
		$module =~ s@::@/@g;
		$module .= '.pm';
	}
	for my $prefix (@INC) {
		return 1 if -e "$prefix/$module";
	}
	return;
}

sub _process
{
	local (@ARGV) = @_;

	my %opts;
	getopts(Getopt::Config::FromPod->string, \%opts);
	pod2usage(-verbose => 2) if exists $opts{h};
	pod2usage(-msg => 'At least one argument MUST be specified', -verbose => 0, -exitval => 1) if ! @ARGV;
	$opts{i} ||= 'cpanm';

	my $p = Module::ExtractUse->new;

	while(my $arg = shift @ARGV) {
		if(-f $arg) { $p->extract_use($arg); }
		elsif(-d $arg) {
			find({ no_chdir => 1, wanted => sub {
				$p->extract_use($_) if -f $_;
			}}, $arg);
		} else {
			warn "can't recognize argument: $arg";
		}
	}
	my (@target) = grep { ! exists $opts{x} || $_ !~ /$opts{x}/ } grep { exists $opts{u} || ! _exists($_) } keys %{exists $opts{r} ? $p->used_out_of_eval : $p->used};
	return (\%opts, \@target);
}

sub run
{
	shift if @_ && eval { $_[0]->isa(__PACKAGE__) };
	my ($opts, $target) = _process(@_);

	if($opts->{n}) {
		print join(' ', @$target), "\n";
	} else {
		print $opts->{i},' ',join(' ', @$target), "\n";
		system $opts->{i},@$target;
	}
}

1;
__END__

=head1 SYNOPSIS

  App::installdeps->run(@ARGV);

=head1 DESCRIPTION

This is an implementation module for a tiny script to install dependent modules.
If you upload your scripts or modules to PAUSE, you can install dependent modules by cpanm/cpan/cpanp.
However, it is almost impossible and meaningless to upload all your daily-use scripts.

This script scans source to detect dependent modules and install them.

=method C<run(@arg)>

Process arguments. Typically, C<@ARGV> is passed. For argument details, see L<installdeps>.

=head1 SEE ALSO

=for :list
* L<installdeps>

=cut
