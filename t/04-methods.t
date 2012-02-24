#!perl -T
use strict;
use warnings;
use Test::More 'no_plan';

BEGIN { use_ok('MIDI::Simple::Drummer::Rudiments') }

my $d = eval { MIDI::Simple::Drummer::Rudiments->new };
isa_ok $d, 'MIDI::Simple::Drummer::Rudiments';
ok !$@, 'created with no arguments';

my $x = $d->patterns(0);
is $x, undef, 'get unknown pattern is undef';

#$x = $d->write('Rudiments-Drummer.mid');
#ok $x eq 'Rudiments-Drummer.mid' && -e $x, 'named write';
#unlink $x;
#ok !-e $x, 'removed';
