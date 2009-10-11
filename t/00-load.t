#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'MIDI::Simple::Drummer' );
}

diag( "Testing MIDI::Simple::Drummer $MIDI::Simple::Drummer::VERSION, Perl $], $^X" );

__END__
#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;
use_ok 'MIDI::Simple::Drummer';
my $obj = eval { MIDI::Simple::Drummer->new() };
isa_ok $obj, 'MIDI::Simple::Drummer';
ok !$@, 'created with no arguments';
