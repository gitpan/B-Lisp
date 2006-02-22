package B::Lisp::_impl;

use 5.006;
use strict;
use warnings;
use B qw( class OPf_WANT_VOID OPf_WANT_SCALAR OPf_WANT_LIST );
use base 'B::OP';
use Data::Dump::Streamer ();

=head1 METHODS

=over

=item new( $op )

=cut

sub new {
    my ( $class, $op ) = @_;

    return bless \$op, $class;
}

=item stringify

=cut

###############################################################################

sub stringify {
    my $self = shift;
    my $op   = $$self;

    return if 'NULL' eq class $op;

    # sv warnings io gv pmreplroot pmreplstart
    my $name = $op->name();
    my $id   = "'op-$$op";

    my @attr = $op->_lisp_attr;

    my $children;
    if ( $op->can('first') ) {
        $children = $op->first->lispy;
    }

    my $op_str
        = "(" . join( ' ', $name, grep defined(), @attr, $children ) . ")";

    return "$op_str " . $op->sibling->lispy;
}

###############################################################################
# Create a series of B::$FooOP->_lisp_attr methods tailored for whatever
# each class is capable of doing.
{
    my @unhandled_attributes = (
        qw( stash warnings io sv gv pmreplroot pmreplstart pmnext pmregexp ),
        qw( pmflags pmdynflags pmnext )
    );
    my @string_attributes = qw( ppaddr desc pv label stashpv file precomp );
    my @number_attributes = (
        qw( targ type opt static flags private spare cop_seq arybase line ),
        qw( padix children pmoffset pmflags pmdynflags )
    );
    my @treeorder_attributes = qw( sibling first pmreplroot );
    my @execorder_attributes
        = qw( next other last redoop nextop lastop pmreplstart );

    for my $class ( map sprintf( "B::%sOP", $_ ),
        '', qw(UN SV PAD C PV BIN LOG LO PM ) )
    {
        my @attr_snips;
        for my $t (qw( unhandled string number treeorder execorder )) {

            # Loops over all attributes that objects of this class can
            # provide.
            for my $used_attr ( grep $class->can($_),
                eval sprintf '@%s_attributes', $t )
            {

                # Attribute fetching will be done by something more
                # specific if available otherwise whatever is appropriate
                # for dealing with this generic sort of attribute
                # (number/string/etc)
                if ( $class->can("_lisp_attr_$used_attr") ) {
                    push @attr_snips, sprintf '$_[0]->_lisp_attr_%s()',
                        $used_attr;
                }
                else {
                    push @attr_snips, sprintf '$_[0]->_lisp_attr_%s( q[%s] )',
                        $t, $used_attr;
                }
            }
        }

        my $do_this = join ',', @attr_snips;

        my $src = sprintf 'sub %1$s::_lisp_attr { print q[%1$s\n]; %2$s }',
            $class, $do_this;
        eval $src;
        die "$src\n$@" if $@;
    }
}

=back

=head1 FUNCTIONS

=over

=item $string = quote( $string )

Returns a quoted version of C<$string> that's ok for inclusion in a
C<"..."> string.

=cut

{
    my %quote = (
        '\\' => '\\\\',
        '\"' => '\\\"'
    );

    sub quote {
        local $_ = shift;
        s/([\"\\])/$quote{$1}/g;
        return qq["$_"];
    }
}

=item ??? = string_attr( ??? )

=cut

sub B::OP::_lisp_attr_string {
    my ( $op, $attr ) = @_;

    local $_ = $op->$attr;
    no warnings 'uninitialized';
    return unless length;
    return ":$attr" => quote($_);
}

sub B::OP::_lisp_attr_number {
    my ( $op, $attr ) = @_;

    local $_ = $op->$attr;
    no warnings 'uninitialized';
    return unless $_ != 0;
    return ":$attr" => $_;
}

{
    my $Dumper = Data::Dump::Streamer->new;
    $Dumper->Verbose(0);
    $Dumper->Indent(0);

    # [0] = Nullsv
    my @SPECIALS = (
        undef,
        qw( 'PL_sv_undef 'PL_sv_yes 'PL_sv_no ),
        qw( 'WARN_ALL 'WARN_NONE 'WARN_STD )
    );

    sub B::OP::_lisp_attr_unhandled {
        my ( $op, $attr ) = @_;

        if ( not 'SPECIAL' eq class $op ) {
            my $val = $Dumper->Dump( $op->$attr )->Out;
            $val =~ s/\s+$//;

            return ":$attr" => quote($val);
        }

        return unless defined $SPECIALS[$$op];
        return ":$attr" => $SPECIALS[$$op];
    }
}

sub B::OP::_lisp_attr_treeorder {
    my ( $op, $attr ) = @_;

    my $addr = ${ $op->$attr };
    return if not $addr;
    return ":$attr" => "'op-$addr";
}

sub B::OP::_lisp_attr_execorder {
    my ( $op, $attr ) = @_;

    my $addr = ${ $op->$attr };
    return if not $addr;
    return ":$attr" => "'op-$addr";
}

{
    my %flags = (
        0x04 => "flag-kids",
        0x08 => "flag-parens",
        0x10 => "flag-ref",
        0x20 => "flag-lvalue",
        0x40 => "flag-stacked",
        0x80 => "flag-special"
    );

    sub B::OP::_lisp_attr_flags {
        my $op = shift;

        my $flags = $op->flags;

        return (
            ":flags" => "(XXX)",
            ":gimme" => (
                  $flags & OPf_WANT_LIST   ? q['want-list]
                : $flags & OPf_WANT_SCALAR ? q['want-scalar]
                : q['want-void]
            )
        );
    }
}

# =item my(%flags)
#
# Table relating bitflags on B::OP->flags to strings.
#
# =cut
#

# =item my(%pmflags)
#
# Table relating bitflags on B::OP->pmflags to strings.
#
# =cut
#
# my %pmflags = (
#     0x0001 => ":retaint",
#     0x0002 => ":once",
#
#     # 4 => unused
#     0x0008 => ":maybe_const",
#     0x0010 => ":skipwhite",
#     0x0020 => ":white",
#     0x0040 => ":const",
#     0x0080 => ":keep",
#     0x0100 => ":global",
#     0x0200 => ":continue",
#     0x0400 => ":eval",
#     0x0800 => ":locale",
#     0x1000 => ":multiline",
#     0x2000 => ":singleline",
#     0x4000 => ":fold",
#     0x8000 => ":extended"
# );

# =item my( @private )
#
# An array of potential bitflags. Each array's C<<->[0]>> element is
# either a string or a regex. If it is a string, the OP's ->name must
# match exactly. If it is a regex, it must match the regex.
#
# Once the C<<->[0]>> has matched, the bitmasks are applied to
# C<<$op->private>> to see what info is stored in it.
#
# =cut
#
# my @private = (
#     [ qr/(?#)/ => [ 0x80 => 'lvalue-intro' ] ],
#     [   qr/\A(?:leave|leavesub|leavesublv|leavewrite)\z/ =>
#             [ 0x40 => 'refcounted' ]
#     ],
#     [   assign => [
#             0x20 => 'assign-common',
#             0x40 => 'assign-hash'
#         ],
#     ],
#     [ sassign                            => [ 0x40 => 'assign-backwards' ] ],
#     [ qr/\A(?:match|subst|substconst)\z/ => [ 0x40 => 'runtime' ] ],
#     [   trans => [
#             0x01 => 'trans-from-utf',
#             0x02 => 'trans-to-utf',
#             0x04 => 'trans-identical',
#             0x08 => 'trans-squash',
#             0x10 => 'trans-delete',
#             0x20 => 'trans-complement',
#             0x40 => 'trans-grows'
#         ]
#     ],
#     [ repeat => [ 0x40 => 'repeat-dolist' ] ],
#     [   qr/\A(?:rv2gv|rv2sv|aelem|helem|padsv)\z/ => [
#             0x20            => 'deref-av',
#             0x40            => 'deref-hv',
#             ( 0x20 | 0x40 ) => 'deref-sv'
#         ]
#     ],
#     [   entersub => [
#             0x10 => 'entersub-db',
#             0x20 => 'entersub-hastarg',
#             0x40 => 'entersub-nomod'
#         ]
#     ],
#     [   rv2cv => [
#             0x04 => 'entersub-inargs',
#             0x08 => 'entersub-amper',
#             0x80 => 'entersub-noparen'
#         ]
#     ],
#     [ gv                               => [ 0x20 => 'early-cv' ] ],
#     [ qr/\A.elem\z/                    => [ 0x10 => 'lval-defer' ] ],
#     [ qr/\A(?:rv2.v|gvsv|enteriter)\z/ => [ 0x10 => 'our-intro' ] ],
#     [   qr/\A(?:rv2av|rv2hv|padav|padhv|aelem|helem)\z/ =>
#             [ 0x08 => 'maybe-lvsub' ]
#     ],
#
#     # lower bits may have maxarg. This is handled separately
#     [ targlex => [ 0x10 => 'target-my' ] ],
#
#     [ qr/\A(?:enteriter|iter)\z/ => [ 4 => 'iter-reversed' ] ],
#     [   const => [
#             0x04 => 'const-shortcircuit',
#             0x08 => 'const-strict',
#             0x10 => 'const-entered',
#             0x20 => 'const-arybase',
#             0x40 => 'const-bare',
#             0x80 => 'const-warning'
#         ]
#     ],
#     [ qr/\A(?:flip|flop)\z/ => [ 0x40 => 'flip-linenum' ] ],
#     [ list                  => [ 0x40 => 'list-guessed' ] ],
#     [ delete                => [ 0x40 => 'slice' ] ],
#     [ exists                => [ 0x40 => 'exists-sub' ] ],
#     [   sort => [
#             0x01 => 'sort-numeric',
#             0x02 => 'sort-integer',
#             0x04 => 'sort-reverse',
#             0x08 => 'sort-inplace',
#             0x10 => 'sort-descend'
#         ]
#     ],
#     [ threadsv => [ 0x40 => 'done-svref' ] ],
#     [   qr/\A(?:backtick|open)\z/ => [
#             0x10 => 'open-in-raw',
#             0x20 => 'open-in-crlf',
#             0x40 => 'open-out-raw',
#             0x80 => 'open-out-crlf'
#         ]
#     ],
#     [   qr/\A(?:exit|hush|die)\z/ => [
#             0x40 => 'hush-vmsish',
#             0x80 => 'exit-vmsish'
#         ]
#     ],
#     [ qr/\Aft...\z/ => [ 0x02 => 'ft-access' ] ]
# );
#
# =item ??? = number_attr( ??? )
#
# =cut
#
# use constant WANT_MASK => ( OPf_WANT_VOID | OPf_WANT_SCALAR | OPf_WANT_LIST );
#
# sub number_attr {
#     my ( $self, $node, $attr ) = @_;
#
#     my $name;
#     if ( ref $attr ) {
#         ( $attr, $name ) = @$attr;
#     }
#     else {
#         $name = $attr;
#     }
#
#     my $value = $self->_attr( $node, $attr );
#     defined $value and $value != 0
#         or return;
#
#     my @result;
#     if ( 'flags' eq $attr ) {
#
#         # Resolving ->flags
#
#         if ( my $want = $value & WANT_MASK ) {
#             push @result, 'want-'
#                 . (
#                   OPf_WANT_LIST &$value   ? 'list'
#                 : OPf_WANT_SCALAR &$value ? 'scalar'
#                 : 'void'
#                 );
#         }
#
#         $value & $_ && push @result, $flags{$_} for sort { $a <=> $b }
#             keys %flags;
#
#         return fmt_list( flags => @result );
#     }
#     elsif ( 'private' eq $attr ) {
#
#         # Resolving ->private
#         for my $prv (@private) {
#             my ( $rx, $flags ) = @$prv;
#             next
#                 if ref($rx) ? $node->name() !~ /$rx/ : $node->name ne $rx;
#
#             while (@$flags) {
#                 my ( $test, $name ) = splice @$flags, 0, 2;
#                 if ( $value & $test ) {
#                     push @result, $name;
#                 }
#             }
#         }
#
#         return fmt_list( private => @result );
#     }
#     elsif ( 'pmflags' eq $attr ) {
#
#         for my $test (
#             sort { $a <=> $b }
#             keys %pmflags
#             )
#         {
#             push @result, $pmflags{$test}, if $_ & $test;
#         }
#
#         return fmt_list( pmflags => @result );
#     }
#     elsif ( $attr =~ /^(?:arybase|cop_seq|line|seq|targ)$/ ) {
#
#         # Pure numeric
#         return (":$name $_");
#     }
#     else {
#         croak("Invalid numeric attribute $name=$_");
#     }
#
#     croak("Invalid numeric attribute $attr");
# }
#
# sub fmt_list {
#     my ( $name, $list ) = @_;
#
#     return unless ref $list and @$list;
#
#     if ( @$list >= 2 ) {
#         return (
#             join(
#                 ' ',
#                 ":flags" => "($list->[0]",
#                 @$list[ 1 .. $#$list - 1 ],
#                 "$list->[$#$list])"
#             )
#         );
#     }
#     elsif ( 1 == @$list ) {
#         return (":flags ($list->[0])");
#     }
#     else {
#         return ();
#     }
# }
#
# sub sv_attr {
#     my ( $self, $node, $attr ) = @_;
#     local $_ = $self->_attr( $node, $attr );
#     defined() or return;
#
#     if ( $attr eq 'warnings' ) {
#
#         # This, from Deparse.pm.
#         if ( class($_) eq 'SPECIAL' ) {
#             if ( 4 == $$_ ) {
#                 return ( ":warnings" => "WARN_ALL" );
#             }
#             elsif ( 5 == $$_ ) {
#                 return ( ":warnings" => "WARN_NONE" );
#             }
#             elsif ( 6 == $$_ ) {
#                 return ( ":warnings" => "WARN_STD" );
#             }
#             else {
#                 croak("Invalid WARNINGs bits: $$_");
#             }
#         }
#         elsif ( $_->isa('B::NV') ) {
#             return ( ":warnings" => $_->NV );
#         }
#         elsif ( $_->isa('B::IV') ) {
#             return ( ":warnings" => $_->IV );
#         }
#         else {
#             croak("Invalid warnings object isn\'t an IV or NV");
#         }
#     }
#     elsif ( 'sv' eq $attr ) { }
#     elsif ( 'gv' eq $attr ) { }
#     elsif ( 'io' eq $attr ) { }
#     elsif ('pmreplroot')  { }
#     elsif ('pmreplstart') { }
#     else {
#         return ( ":$attr" => $_ );
#     }
# }

=back

=head1 Ops and their properties

The following is a diagram lifted from L<B>'s documentation showing how various
ops are related by ISA and what properties each has.

                            B::OP[next    type
                              |   sibling opt
                              |   name    static
                              |   ppaddr  flags
                              |   desc    private
                              |   targ    spare  ]
                              |
               +--------------+---------+----------+----------+
               |              |         |          |          |
            B::UNOP[first]  B::SVOP  B::PADOP  B::COP      B::PVOP
           /      \           [sv     [padix]   [label        [pv]
          /        \           gv]               stash
         /          \                            stashpv
    B::BINOP[last] B::LOGOP[other]               file
        |                                        cop_seq
        |                                        arybase
       B::LISTOP[children]                       line
      /        \                                 warnings
     /          \				 io      ]
 B::LOOP[redoop  B::PMOP[pmreplroot
         nextop          pmreplstart
         lastop]         pmnext
                         pmregexp
                         pmflags
                         pmdynflags
                         precomp
                         pmoffset]

=cut

qq[

  Well --- me!

  A ----ing wizard.  I hate ----ing wizards!!

  Well you shouldn't ---- them, then.

]
