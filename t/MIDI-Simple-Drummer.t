#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;
use_ok 'MIDI::Simple::Drummer';
my $obj = eval { MIDI::Simple::Drummer->new() };
isa_ok $obj, 'MIDI::Simple::Drummer';
ok !$@, 'created with no arguments';
