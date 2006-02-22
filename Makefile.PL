use 5.006;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'B::Lisp',
    VERSION_FROM => 'lib/B/Lisp.pm',
    PREREQ_PM    => {
        'Data::Dump::Streamer' => 0,
        'Test::More'           => 0
    },
    AUTHOR        => 'Joshua ben Jore <jjore@cpan.org>',
    ABSTRACT_FROM => 'lib/B/Lisp.pm'
);
