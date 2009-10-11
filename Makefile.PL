use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'MIDI::Simple::Drummer',
    AUTHOR              => q{Gene Boggs <gene@cpan.org>},
    VERSION_FROM        => 'lib/MIDI/Simple/Drummer.pm',
    ABSTRACT_FROM       => 'lib/MIDI/Simple/Drummer.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'MIDI'       => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'MIDI-Simple-Drummer-*' },
);
