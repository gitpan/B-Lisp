use 5.6.0;
use Module::Build;

Module::Build->new(
    module_name    => 'B::Lisp',
    license        => 'perl',
    requires       => { perl => '5.6.0', },
    build_requires => { 'Test::More' => 0 },

    # There is no 'skip' value yet.
    #    create_makefile_pl => 'skip',
    create_readme   => 1,
    create_packlist => 1,
    sign            => 1,
)->create_build_script;
