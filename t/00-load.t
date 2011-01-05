#!perl -T
use strict;
use warnings;
use Test::More 'no_plan';
BEGIN { use_ok( 'MIDI::Simple::Drummer' ) }
BEGIN { use_ok( 'MIDI::Simple::Drummer::Rock' ) }
BEGIN { use_ok( 'MIDI::Simple::Drummer::Jazz' ) }
diag("Testing Drummer $MIDI::Simple::Drummer::VERSION, Perl $], $^X");
