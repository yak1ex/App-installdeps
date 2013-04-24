# NAME

App::installdeps - A tiny script to install dependent modules

# VERSION

version v0.0.1

# SYNOPSIS

    App::installdeps->run(@ARGV);

# DESCRIPTION

This is an implementation module for a tiny script to install dependent modules.
If you upload your scripts or modules to PAUSE, you can install dependent modules by cpanm/cpan/cpanp.
However, it is almost impossible and meaningless to upload all your daily-use scripts.

This script scans source to detect dependent modules and install them.

# METHODS

## `run(@arg)`

Process arguments. Typically, `@ARGV` is passed. For argument details, see [installdeps](http://search.cpan.org/perldoc?installdeps).

# SEE ALSO

- [installdeps](http://search.cpan.org/perldoc?installdeps)

# AUTHOR

Yasutaka ATARASHI <yakex@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Yasutaka ATARASHI.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
