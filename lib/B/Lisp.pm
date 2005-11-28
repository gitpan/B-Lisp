package B::Lisp;

=head1 NAME

B::Lisp - Adds ->lisp

=head1 VERSION

Version 0.01

=cut

$VERSION = '0.01';

=head1 SYNOPSIS

 perl -MO=Lispy yourprogram.pl

 use B qw( svref_2object );
 use B::Lispy qw( lispy );
 print lispy( svref_2object( \ &foo ) );

=head1 EXPORT

Optionally, lispy() is exported.

=cut

use strict;
use Carp ('croak');
use B qw( main_root class );

=pod

=head1 FUNCTIONS

=over 4

=item lispy( $op )

Returns a lispy representation of an opcode.

=cut

sub lispy {
    my $obj = shift;

    if ( $obj->isa('B::OP') ) {
        return B::Lisp::OP->new($obj)->stringify;
    }
    elsif ( class($obj) eq 'NULL' ) {
        return;
    }
    else {
        croak("Invalid obj $obj");
    }
}

=pod

=item compile( ... )

Undocumented.

=cut

sub compile {
    my @args = @_;
    return sub {
        local $_ = lispy( main_root() );
        if ( defined wantarray ) {
            return $_;
        }
        else {
            print;
        }
    };
}

=pod

=back

=head1 AUTHOR

Joshua ben Jore jjore@cpan.org

=head1 BUGS

Please report any bugs or feature requests to
C<bug-b-lisplist@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=B-Lisp>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Joshua ben Jore, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

"Conversations tend to be so much more civil when there's a chance the other person might snap and kill you."

