#!perl -T
use strict;
use warnings;
use Test::More 'no_plan';

BEGIN { use_ok('MIDI::Simple::Drummer::Jazz') }

my $d = eval { MIDI::Simple::Drummer::Jazz->new };
isa_ok $d, 'MIDI::Simple::Drummer::Jazz';
ok !$@, 'created with no arguments';

my $x = $d->swing();
is $x, 1, 'swing set';

$x = $d->patterns(0);
is $x, undef, 'get unknown pattern is undef';
my $y = sub { $d->note($d->EIGHTH, $d->strike) };
$x = $d->patterns('y', $y);
is_deeply $x, $y, 'set y pattern';
$x = $d->patterns('y fill', $y);
is_deeply $x, $y, 'set y fill pattern';

$x = eval { $d->beat };
ok $x, 'beat';
$x = eval { $d->fill };
like $x, qr/ fill$/, 'fill';
$x = eval { $d->beat(-name => 'y') };
is $x, 'y', 'named y beat';
$x = eval { $d->beat(-type => 'fill') };
like $x, qr/ fill$/, 'fill';
$x = eval { $d->beat(-name => 'y', -type => 'fill') };
is $x, 'y fill', 'named fill';
$x = eval { $d->beat(-last => 'y') };
isnt $x, 'y', 'last known beat';
$x = eval { $d->beat(-last => 'y fill') };
isnt $x, 'y fill', 'last known fill';

$x = $d->write('Jazz-Drummer.mid');
ok $x eq 'Jazz-Drummer.mid' && -e $x, 'named write';
unlink $x;
ok !-e $x, 'removed';
