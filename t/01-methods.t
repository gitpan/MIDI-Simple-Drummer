#!perl -T
use strict;
use warnings;
use Test::More tests => 64;

BEGIN { use_ok('MIDI::Simple::Drummer') }

my $d = eval { MIDI::Simple::Drummer->new };
isa_ok $d, 'MIDI::Simple::Drummer';
ok !$@, 'created with no arguments';

my $x = $d->phrases;
ok $x, 'get phrases';
$x = $d->phrases(2);
is $x, 2, 'set phrases';

$x = $d->beats;
ok $x, 'get beats';
$x = $d->beats(2);
is $x, 2, 'set beats';

$x = $d->score;
isa_ok $x, 'MIDI::Simple', 'score';

$d->note('en', 'n56');
my $n = grep { $_->[0] eq 'note' } @{$d->score->{Score}};
is $n, 1, 'note';
$d->rest('en');
$n = grep { $_->[0] eq 'note' } @{$d->score->{Score}};
is $n, 1, 'rest';

is $d->WHOLE, 'wn', 'WHOLE';
is $d->HALF, 'hn', 'HALF';
is $d->QUARTER, 'qn', 'QUARTER';
is $d->EIGHTH, 'en', 'EIGHTH';
is $d->SIXTEENTH, 'sn', 'SIXTEENTH';

$x = $d->kit;
isa_ok $x, 'HASH';
$x = $d->kit('clank');
is $x, undef, 'kit clank undef';
$x = $d->kit(clunk => ['Foo','Bar']);
is_deeply $x, ['Foo','Bar'], 'kit set clunk';

$x = $d->snare;
is $x, 'n38', 'snare';
$x = $d->kick;
is $x, 'n35', 'kick';
$x = $d->tick;
is $x, 'n42', 'tick';
$x = $d->backbeat;
is $x, 'n38,n35', 'backbeat';
$x = $d->kicktick;
is $x, 'n35,n42', 'kicktick';
$x = $d->hhat;
like $x, qr/n4[246]/, 'hhat';
$x = $d->crash;
like $x, qr/n(?:5[257]|49)/, 'crash';
$x = $d->ride;
like $x, qr/n5[139]/, 'ride';
$x = $d->tom;
like $x, qr/n(?:4[13578]|50)/, 'tom';

$x = $d->strike;
is $x, 'n38', 'strike default';
$x = $d->strike('Cowbell');
is $x, 'n56', 'strike patch';
$x = $d->strike('Cowbell', 'Tambourine');
is $x, 'n56,n54', 'strike patches string';
$x = [$d->strike('Cowbell', 'Tambourine')];
is_deeply $x, ['n56', 'n54'], 'strike patches list';

$x = $d->option_strike;
like $x, qr/n(?:5[257]|49)/, 'option_strike default';
$x = $d->option_strike('Cowbell');
is $x, 'n56', 'option_strike patch';
$x = $d->option_strike('Cowbell', 'Tambourine');
like $x, qr/n5[46]/, 'option_strike options';

$d = eval { MIDI::Simple::Drummer->new };
$d->metronome;
$x = grep { $_->[0] eq 'note' } @{$d->score->{Score}};
ok $x == $d->beats * $d->phrases, 'metronome';

$d = eval { MIDI::Simple::Drummer->new };
$d->count_in;
$x = grep { $_->[0] eq 'note' } @{$d->score->{Score}};
ok $x == $d->beats, 'count_in';

$x = $d->rotate;
is $x, 'n35', 'rotate';
$x = $d->rotate(1);
is $x, 'n35', 'rotate 1';
$x = $d->rotate(2);
is $x, 'n38', 'rotate 2';
$x = $d->rotate(3);
is $x, 'n35', 'rotate 3';
$x = $d->rotate(1, ['Cowbell', 'Tambourine']);
is $x, 'n54', 'rotate 1 options';
$x = $d->rotate(2, ['Cowbell', 'Tambourine']);
is $x, 'n56', 'rotate 2 options';
$x = $d->rotate(3, ['Cowbell', 'Tambourine']);
is $x, 'n54', 'rotate 3 options';

$x = $d->rotate_backbeat;
is $x, 'n35,n42', 'rotate_backbeat';
$x = $d->rotate_backbeat(-beat => 1);
is $x, 'n35,n42', 'rotate_backbeat 1';
$x = $d->rotate_backbeat(-beat => 2);
is $x, 'n38,n42', 'rotate_backbeat 2';
$x = $d->rotate_backbeat(-beat => 3);
is $x, 'n35,n42', 'rotate_backbeat 3';
$x = $d->rotate_backbeat(-beat => 1, -fill => 0);
is $x, 'n35,n42', 'rotate_backbeat 1 no fill';
$x = $d->rotate_backbeat(-beat => 1, -fill => 1);
like $x, qr/n35,n(?:5[257]|49)/, 'rotate_backbeat 1 fill';
$x = $d->rotate_backbeat(-beat => 2, -fill => 1);
is $x, 'n38,n42', 'rotate_backbeat 2 fill';
$x = $d->rotate_backbeat(-beat => 3, -fill => 1);
is $x, 'n35,n42', 'rotate_backbeat 3 fill';

$x = $d->pattern(1);
is $x, undef, 'get pattern undef';
my $y = sub { $d->note($d->EIGHTH, $d->strike) };
$x = $d->pattern('foo', $y);
is_deeply $x, $y, 'get pattern';
$x = $d->pattern('foo fill', $y);
is_deeply $x, $y, 'set fill pattern';

$x = $d->beat;
ok $x, 'random beat';
$x = $d->fill;
ok $x, 'random fill';
$x = $d->beat(-name => 'foo');
is $x, 'foo', 'named beat';
$x = $d->beat(-type => 'fill');
like $x, qr/ fill$/, 'type';
$x = $d->beat(-name => 'foo', -type => 'fill');
is $x, 'foo fill', 'named fill';
$x = $d->beat(-last => 1);
ok $x ne 1, 'last unknown beat';
$x = $d->beat(-last => 'foo');
ok $x ne 'foo', 'last known beat';
$x = $d->beat(-last => 'foo fill');
isnt $x, 'foo fill', 'last known fill';

$x = $d->write;
is $x, 'Drummer.mid', 'write';
$x = $d->write("Buddy-Rich.mid");
ok $x, 'named write';
