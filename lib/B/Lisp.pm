package B::Lisp;

use strict;
use warnings;

=head1 NAME

B::Lisp - Perl code stringifies as lisp.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

 perl -MO=Lispy yourprogram.pl

 use B qw( svref_2object );
 use B::Lispy;
 print svref_2object( \ &foo )->ROOT;

=head1 EXPORT

Optionally, lispy() is exported.

=cut

use Exporter;
*import = *import = \&Exporter::import;

=head1 FUNCTIONS

=over

=item lispy( $op )

Returns a lispy representation of an opcode.

=cut

use B qw( main_root class );
use B::Lisp::_impl;
use Carp 'croak';

sub B::OP::lispy {
    my $self = shift;
    return B::Lisp::_impl->new($self);
}

sub B::NULL::lispy {
    return;
}

=item compile( ... )

This function is private to the L<O> module. It allows C<perl -MO=Lisp
your-file.pl> to work.

=cut

sub compile {
    my @args = @_;
    return sub {
        if ( defined wantarray ) {
            return lispy( main_root() );
        }
        else {
            print lispy( main_root() );
        }
    };
}

=back

=head1 AUTHOR

Joshua ben Jore <jjore@cpan.org>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-b-lisplist@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=B-Lisp>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2006 Joshua ben Jore, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

no warnings;

# Quote blatantly stolen from Michael Poe's web site
# http://errantstory.com, the location of his web comic Errant Story.

qq[

Conversations tend to be so much more civil when there's a chance the other person might snap and kill you.

]
