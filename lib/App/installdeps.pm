package App::installdeps;

use strict;
use warnings;

# ABSTRACT: A tiny script to install dependent modules
# VERSION

1;
__END__

=head1 DESCRIPTION

This is a tinay script to install dependent modules.
If you upload your scripts or modules to PAUSE, you can install dependent modules by cpanm/cpan/cpanp.
However, it is almost impossible and meaningless to upload all your daily-use scripts.

This script scans source to detect dependent modules and install them.

=cut
