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
use version 0.77;

sub _exists
{
	my $module = shift;
	unless($module =~ /\.pm$/) {
		$module =~ s@::@/@g;
		$module .= '.pm';
	}
	for my $prefix (@INC) {
		my $path = "$prefix/$module";
		return $path if -e $path;
	}
	return;
}

sub _candidate
{
	my $opts = shift;
	my $p = Module::ExtractUse->new;
	while(my $arg = shift) {
		if(-f $arg) { $p->extract_use($arg); }
		elsif(-d $arg) {
			find({ no_chdir => 1, wanted => sub {
				$p->extract_use($_) if -f $_;
			}}, $arg);
		} else {
			warn "can't recognize argument: $arg";
		}
	}
	return keys %{exists $opts->{r} ? $p->used_out_of_eval || {}: $p->used || {}};
}

sub _candidate_N
{
	my $opts = shift;
	my @result;
	my $extract = sub {
		my $p = Module::ExtractUse->new;
		$p->extract_use($_[0]);
		push @result, map { [ $_[0] => $_ ] } sort keys %{exists $opts->{r} ? $p->used_out_of_eval || {}: $p->used || {}};
	};
	while(my $arg = shift) {
		if(-f $arg) { $extract->($arg); }
		elsif(-d $arg) {
			find({ no_chdir => 1, wanted => sub {
				$extract->($_) if -f $_;
			}}, $arg);
		} else {
			warn "can't recognize argument: $arg";
		}
	}
	return @result;
}

sub _process
{
	local (@ARGV) = @_;

	my %opts;
	getopts(Getopt::Config::FromPod->string, \%opts);
	pod2usage(-verbose => 2) if exists $opts{h};
	pod2usage(-msg => 'At least one argument MUST be specified', -verbose => 0, -exitval => 1) if ! @ARGV;
	$opts{i} ||= 'cpanm';

	my (@target, %checked, %mid);
	my $candidater = exists $opts{N} ? \&_candidate_N : \&_candidate;
	my @candidate = $candidater->(\%opts, @ARGV);
	while(my $candidate_ = shift @candidate) {
		my $candidate = exists $opts{N} ? $candidate_->[1] : $candidate_;
		next if version::is_lax($candidate);
		my $path;
		$path = _exists($candidate) if ! exists $opts{u} || exists $opts{R};
		next if exists $opts{x} && $candidate =~ /$opts{x}/;
		next if ! exists $opts{X} && $candidate =~ /\$|::$|^VMS::|^File::BSDGlob$/;
		if(exists $checked{$candidate}) {
			push @target, $candidate_ if exists $opts{N};
			next;
		}
		$checked{$candidate} = 1;
		if(defined $path && exists $opts{R}) {
			my $pp = Module::ExtractUse->new;
			$pp->extract_use($path);
			if(exists $opts{N}) {
				push @candidate, map { [ $candidate => $_ ] } grep { ! exists $checked{$_} } keys %{exists $opts{r} ? $pp->used_out_of_eval || {} : $pp->used || {}};
			} else {
				push @candidate, grep { ! exists $checked{$_} } keys %{exists $opts{r} ? $pp->used_out_of_eval || {} : $pp->used || {}};
			}
		}
		if(! exists $opts{u} && defined $path) {
			if(exists $opts{N}) {
				$mid{$candidate} = 1;
				push @target, $candidate_;
			}
			next;
		}
		push @target, $candidate_;
	}
	return (\%opts, \@target, \%mid);
}

sub _output_N
{
	my ($opts, $target, $mid) = @_;
	my (%tree, @parent, %parent);


# Make tree structure
	foreach my $entry (@$target) {
		if(! exists $parent{$entry->[0]}) {
			push @parent, $entry->[0];
			$parent{$entry->[0]} = 1;
		}
		push @{$tree{$entry->[0]}}, $entry->[1];
	}

# Cut unnecessary nodes
	my (%visited);
	my $cutter; $cutter = sub {
		my ($root) = @_;
		my $cut = exists $mid->{$root};
		my @new;
		foreach my $child (@{$tree{$root}}) {
			my $mycut = $cutter->($child);
			push @new, $child unless $mycut;
			$cut &&= $mycut;
		}
		if(@new) {
			$tree{$root} = \@new;
		} else {
			delete $tree{$root};
		}
		return $cut;
	};
	my @newparent;
	foreach my $parent (@parent) {
		if(! exists $visited{$parent}) {
			if(!$cutter->($parent)) {
				push @newparent, $parent;
			}
		}
		$visited{$parent} = 1;
	}
	@parent = @newparent;

# Output
	undef %visited;
	my $out; $out = sub {
		my ($root, $level) = @_;
		print +('  ' x $level), (exists $mid->{$root} ? "($root)" : $root), (exists $visited{$root} ? ' [+]' : ''), "\n";
		return if exists $visited{$root};
		$visited{$root} = 1;
		$out->($_, $level + 1) for @{$tree{$root}};
	};
	foreach my $parent (@parent) {
		$out->($parent, 0) if ! exists $visited{$parent};
		$visited{$parent} = 1;
	}
}

sub run
{
	shift if @_ && eval { $_[0]->isa(__PACKAGE__) };
	my ($opts, $target, $mid) = _process(@_);

	if($opts->{n}) {
		print join(' ', @$target), "\n";
	} elsif($opts->{N}) {
		_output_N($opts, $target, $mid);
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
