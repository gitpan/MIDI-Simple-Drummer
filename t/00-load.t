#!perl -T
use strict;
use warnings;
use Test::More tests => 1;
BEGIN { use_ok( 'MIDI::Simple::Drummer' ) }
diag( "Testing MIDI::Simple::Drummer $MIDI::Simple::Drummer::VERSION, Perl $], $^X" );
