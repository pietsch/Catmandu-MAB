use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Catmandu::MAB',
    AUTHOR              => q{Johann Rolschewski <rolschewski@gmail.com>},
    VERSION_FROM        => 'lib/Catmandu/MAB.pm',
    ABSTRACT_FROM       => 'lib/Catmandu/MAB.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Catmandu-MAB-*' },
);
