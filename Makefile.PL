#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'MIDI::Simple::Drummer',
    VERSION_FROM => 'lib/MIDI/Simple/Drummer.pm',
    (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
    PREREQ_PM    => { MIDI => 0 },
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'lib/MIDI/Simple/Drummer.pm',
           AUTHOR        => 'Gene Boggs <gene@cpan.org>')
        : ()
    ),
);
