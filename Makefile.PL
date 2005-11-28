use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'B::Lisp',
    VERSION_FROM => 'lib/B/Lisp.pm',
    PREREQ_PM    => {
        'strict'     => 0,
        'Carp'       => 0,
        'B'          => 0,
        'Test::More' => 0,
    },
    (   $] >= 5.005
        ? ( AUTHOR        => 'Joshua ben Jore <jjore@cpan.org>',
            ABSTRACT_FROM => 'lib/B/Lisp.pm'
            )
        : ()
    ),
);
