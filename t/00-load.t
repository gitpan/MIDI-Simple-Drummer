#!perl -T
use strict;
use warnings;
use Test::More tests => 2;
BEGIN { use_ok( 'MIDI::Simple::Drummer' ) }
BEGIN { use_ok( 'MIDI::Simple::Drummer::Rock' ) }
diag(
"Testing Drummer $MIDI::Simple::Drummer::VERSION and Rock $MIDI::Simple::Drummer::Rock::VERSION, Perl $], $^X"
);
