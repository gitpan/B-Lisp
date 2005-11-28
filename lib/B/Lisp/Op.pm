package B::Lisp::OP;

@ISA   = 'B::OP';
*lispy = \&B::Lisp::lispy;

use strict;
use B qw( class );
use Carp qw( croak );

sub quote {
    local $_ = shift;
    s/\\/\\\\/g;
    s/\"/\\\"/g;
    qq["$_"];
}

sub attr {
    my ( $self, $node, $attr ) = @_;

    my $getter = $node->can($attr)
        or return;
    return $node->$getter();
}

sub string_attr {
    my ( $self, $node, $attr ) = @_;
    my $name;
    if ( ref $attr ) {
        ( $attr, $name ) = @$attr;
    }
    else {
        $name = $attr;
    }
    local $_ = $self->attr( $node, $attr );
    defined() or return;

    return ( ":$name" => quote($_) );
}

my %flags = (
    4   => "flag-kids",
    8   => "flag-parens",
    16  => "flag-ref",
    32  => "flag-lvalue",
    64  => "flag-stacked",
    128 => "flag-special"
);
my %pmflags = (
    0x0001 => ":retaint",
    0x0002 => ":once",

    # 4 => unused
    0x0008 => ":maybe_const",
    0x0010 => ":skipwhite",
    0x0020 => ":white",
    0x0040 => ":const",
    0x0080 => ":keep",
    0x0100 => ":global",
    0x0200 => ":continue",
    0x0400 => ":eval",
    0x0800 => ":locale",
    0x1000 => ":multiline",
    0x2000 => ":singleline",
    0x4000 => ":fold",
    0x8000 => ":extended"
);
my @private = (
    [ qr/(?=)/                         => [ 128 => 'lvalue-intro' ] ],
    [ qr/^leave(?:sub(?:lv)?|write)?$/ => [ 64  => 'refcounted' ] ],
    [   qr/^assign$/ => [
            32 => 'assign-common',
            64 => 'assign-hash'
        ]
    ],
    [ qr/^sassign$/ => [ 64 => 'assign-backwards' ] ],
    [ qr/^(?=[ms])(?:match|subst(?:const)?)$/ => [ 64 => 'runtime' ] ],
    [   qr/^trans$/ => [
            1  => 'trans-from-utf',
            2  => 'trans-to-utf',
            4  => 'trans-identical',
            8  => 'trans-squash',
            16 => 'trans-delete',
            32 => 'trans-complement',
            64 => 'trans-grows'
        ]
    ],
    [ qr/^repeat$/ => [ 64 => 'repeat-dolist' ] ],
    [   qr/^(?=[arhp])(?:rv2[gs]v|[ah]elem|padsv)$/ => [
            32          => 'deref-av',
            64          => 'deref-hv',
            ( 32 | 64 ) => 'deref-sv'
        ]
    ],
    [   qr/^entersub$/ => [
            16 => 'entersub-db',
            32 => 'entersub-hastarg',
            64 => 'entersub-nomod'
        ]
    ],
    [   qr/^rv2cv$/ => [
            4   => 'entersub-inargs',
            8   => 'entersub-amper',
            128 => 'entersub-noparen'
        ]
    ],
    [ qr/^gv$/                                => [ 32 => 'early-cv' ] ],
    [ qr/^.elem$/                             => [ 16 => 'lval-defer' ] ],
    [ qr/^(?=[erg])(?:rv2.v|gvsv|enteriter)$/ => [ 16 => 'our-intro' ] ],
    [   qr/^(?=[ahrp])(?:rv2[ah]v|pad[ah]v|[ah]elem)$/ =>
            [ 8 => 'maybe-lvsub' ]
    ],

    # lower bits may have maxarg. This is handled separately
    [ qr/^targlex$/ => [ 16 => 'target-my' ] ],

    [ qr/^(?=[ei])(?:enter)?iter$/ => [ 4 => 'iter-reversed' ] ],
    [   qr/^const$/ => [
            4   => 'const-shortcircuit',
            8   => 'const-strict',
            16  => 'const-entered',
            32  => 'const-arybase',
            64  => 'const-bare',
            128 => 'const-warning'
        ]
    ],
    [ qr/^fl[io]p$/ => [ 64 => 'flip-linenum' ] ],
    [ qr/^list$/    => [ 64 => 'list-guessed' ] ],
    [ qr/^delete$/  => [ 64 => 'slice' ] ],
    [ qr/^exists$/  => [ 64 => 'exists-sub' ] ],
    [   qr/^sort$/ => [
            1  => 'sort-numeric',
            2  => 'sort-integer',
            4  => 'sort-reverse',
            8  => 'sort-inplace',
            16 => 'sort-descend'
        ]
    ],
    [ qr/^threadsv$/ => [ 64 => 'done-svref' ] ],
    [   qr/^(?=[bo])(?:backtick|open)$/ => [
            16  => 'open-in-raw',
            32  => 'open-in-crlf',
            64  => 'open-out-raw',
            128 => 'open-out-crlf'
        ]
    ],
    [   qr/^(?=[deh])(?:exit|hush|die)$/ => [
            64  => 'hush-vmsish',
            128 => 'exit-vmsish'
        ]
    ],
    [ qr/^ft...$/ => [ 2 => 'ft-access' ] ]
);

sub number_attr {
    my ( $self, $node, $attr ) = @_;
    my $name;
    if ( ref $attr ) {
        ( $attr, $name ) = @$attr;
    }
    else {
        $name = $attr;
    }
    local $_ = $self->attr( $node, $attr );
    defined() and $_ != 0
        or return;

    my @result;
    if ( 'flags' eq $attr ) {
        my $want = $_ & 3;
        if ( 0 != $want ) {
            push @result,
                (
                  1 == $want ? "want-void"
                : 2 == $want ? "want-scalar"
                : 3 == $want ? "want-list"
                : croak("Invalid WANT/GIMME $want")
                );
        }

        for my $test (
            sort { $a <=> $b }
            keys %flags
            )
        {
            push @result, $flags{$test} if $_ & $test;
        }

        if ( 2 <= @result ) {
            my $first = shift @result;
            my $last  = pop @result;
            return (
                join(
                    ' ',
                    ":flags" => "($first",
                    @result, "$last)"
                )
            );
        }
        elsif ( 1 == @result ) {
            return (":flags ($result[0])");
        }
        else {
            return ();
        }
    }
    elsif ( 'private' eq $attr ) {
        my $private = $_;
        for my $prv (@private) {
            my ( $rx, $flags ) = @$prv;
            next if not $node->name() =~ /$rx/;

            while (@$flags) {
                my ( $test, $name ) = splice @$flags, 0, 2;
                if ( $private & $test ) {
                    push @result, $name;
                }
            }
        }

        if ( 2 <= @result ) {
            my $first = shift @result;
            my $last  = pop @result;
            return join(
                ' ',
                ":private-flags"
                    => "($first",
                @result, "$last)"
            );
        }
        elsif ( 1 == @result ) {
            return join( ' ', ":private-flags" => "($result[0])" );
        }
        else {
            return ();
        }
    }
    elsif ( 'pmflags' eq $attr ) {

        for my $test (
            sort { $a <=> $b }
            keys %pmflags
            )
        {
            push @result, $pmflags{$test}, if $_ & $test;
        }

        if ( 2 <= @result ) {
            my $first = shift @result;
            my $last  = pop @result;
            return (
                join ' ',
                ":regexp-flags" => "($first",
                @result, "$last"
            );
        }
        elsif ( 1 == @result ) {
            return ( ":regexp-flags" => "($result[0])" );
        }
        else {
            return ();
        }
    }
    elsif ( $attr =~ /^(?:arybase|cop_seq|line|seq|targ)$/ ) {

        # Pure numeric
        return (":$name $_");
    }
    else {
        croak("Invalid numeric attribute $name=$_");
    }

    croak("Invalid numeric attribute $attr");
}

sub sv_attr {
    my ( $self, $node, $attr ) = @_;
    local $_ = $self->attr( $node, $attr );
    defined() or return;

    if ( $attr eq 'warnings' ) {

        # This, from Deparse.pm.
        if ( class($_) eq 'SPECIAL' ) {
            if ( 4 == $$_ ) {
                return ( ":warnings" => "WARN_ALL" );
            }
            elsif ( 5 == $$_ ) {
                return ( ":warnings" => "WARN_NONE" );
            }
            elsif ( 6 == $$_ ) {
                return ( ":warnings" => "WARN_STD" );
            }
            else {
                croak("Invalid WARNINGs bits: $$_");
            }
        }
        elsif ( $_->isa('B::NV') ) {
            return ( ":warnings" => $_->NV );
        }
        elsif ( $_->isa('B::IV') ) {
            return ( ":warnings" => $_->IV );
        }
        else {
            croak("Invalid warnings object isn\'t an IV or NV");
        }
    }
    elsif ( 'sv' eq $attr ) { }
    elsif ( 'gv' eq $attr ) { }
    elsif ( 'io' eq $attr ) { }
    elsif ('pmreplroot')  { }
    elsif ('pmreplstart') { }
    else {
        return ( ":$attr" => $_ );
    }
}

sub stringify {
    my $self = shift;
    my $node = $$self;

    # sv warnings io gv pmreplroot pmreplstart
    my $name = $node->name();

    my @attr;
    push @attr, (
        map $self->string_attr( $node, $_ ),
        qw( pmregexp label file pmregexp precomp pmoffset )
    );
    push @attr, $self->string_attr( $node, [ 'stashpv', 'package' ] );
    push @attr, $self->number_attr( $node, 'private' );

    no warnings 'uninitialized';
    my $first = ""
        . (
        $node->can('first')
        ? lispy( $node->first() )
        : ''
        );
    my $sibling = ""
        . (
        $node->sibling->can('name')
        ? lispy( $node->sibling() )
        : ''
        );

    my $this = join( ' ',
        grep length(),
        "(" . join( ' ', grep length(), $name, @attr, $first ) . ")",
        $sibling );

    #    print "====$this====\n" if $this =~ /private/;
    return $this;
}

sub new {
    my ( $package, $node ) = @_;
    my $type  = class($node);
    my $class = $package;       # . "::" . $type;

    bless \$node, $class;
}

qq["Well --- me!" "A ----ing wizard.  I hate ----ing wizards!!"  "Well you shouldn't ---- them, then."]
