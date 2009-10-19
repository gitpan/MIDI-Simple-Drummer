#!perl -T
use strict;
use warnings;

use Test::More tests => 47;

BEGIN { use_ok('MIDI::Simple::Drummer') }

my $d = eval { MIDI::Simple::Drummer->new() };
isa_ok $d, 'MIDI::Simple::Drummer';
ok !$@, 'created with no arguments';

my $x = $d->phrases();
ok $x, "get phrases";
$x = $d->phrases(2);
is $x, 2, "set phrases";

$x = $d->beats();
ok $x, "get beats";
$x = $d->beats(2);
is $x, 2, "set beats";

is $d->WHOLE(), 'wn', "WHOLE";
is $d->HALF(), 'hn', "HALF";
is $d->QUARTER(), 'qn', "QUARTER";
is $d->EIGHTH(), 'en', "EIGHTH";
is $d->SIXTEENTH(), 'sn', "SIXTEENTH";

$d->count_in();
$x = grep { $_->[0] eq 'note' } @{$d->{-score}{Score}};
ok $x == $d->beats(), "count_in";

$d = eval { MIDI::Simple::Drummer->new() };
$d->metronome();
$x = grep { $_->[0] eq 'note' } @{$d->{-score}{Score}};
ok $x == $d->beats() * $d->phrases(), "metronome";

$x = $d->pattern(1);
is ref($x), 'CODE', "get pattern";
my $y = 'foo';
my $z = sub { $d->note($d->EIGHTH(), $d->strike('Closed Hi-Hat')) };
$x = $d->pattern($y, $z);
ok ref($x) eq 'CODE' && $y eq $d->beat(-n => $y), "set beat pattern";
$x = $d->pattern($y, $z, -type => 'fill');
ok ref($x) eq 'CODE' && $y eq $d->fill(-n => $y), "set fill pattern";

$x = $d->strike('Cowbell');
is $x, 'n56', "strike patch";
$x = $d->strike('Cowbell', 'Tambourine');
is $x, 'n56, n54', "strike patches string";
$x = join(', ', $d->strike('Cowbell', 'Tambourine'));
is $x, 'n56, n54', "strike patches list";

$x = $d->backbeat_strike();
is $x, 'n38', "backbeat_strike";
$x = $d->backbeat_strike(-patch => 'Cowbell');
is $x, 'n56', "backbeat_strike patch";

$x = $d->option_strike();
like $x, qr/Cymbal/, "option_strike";
$x = $d->option_strike(-patch => 'Cowbell');
is $x, 'Cowbell', "option_strike patch";
$x = $d->option_strike(-options => ['Cowbell', 'Tambourine']);
ok $x eq 'Cowbell' || $x eq 'Tambourine', "option_strike options";

$x = $d->rotate();
is $x, 'n38', "rotate";
$x = $d->rotate(1);
is $x, 'n35', "rotate 1";
$x = $d->rotate(2);
is $x, 'n38', "rotate 2";
$x = $d->rotate(1, ['Cowbell', 'Tambourine']);
is $x, 'n54', "rotate 1 options";
$x = $d->rotate(2, ['Cowbell', 'Tambourine']);
is $x, 'n56', "rotate 2 options";

($x, $y) = $d->backbeat_fill();
ok $x eq 'n42' && $y eq 'n35', "backbeat_fill";
($x, $y) = $d->backbeat_fill(-beat => 1);
ok $x eq 'n42' && $y eq 'n35', "backbeat_fill beat=1";
($x, $y) = $d->backbeat_fill(-beat => 2);
ok $x eq 'n42' && $y eq 'n38', "backbeat_fill beat=2";
($x, $y) = $d->backbeat_fill(-beat => 1, -fill => 1);
my $n = grep { $x eq 'n'.$_ } qw(49 52 55 57);
ok $n && $y eq 'n35', "backbeat_fill beat=1 fill=1";
($x, $y) = $d->backbeat_fill(-beat => 2, -fill => 1);
ok $x eq 'n42' && $y eq 'n38', "backbeat_fill beat=2 fill=1";

$d = eval { MIDI::Simple::Drummer->new() };
$d->note('en', 'n56');
$n = grep { $_->[0] eq 'note' } @{$d->{-score}{Score}};
is $n, 1, "note";
$d->rest('en');
$n = grep { $_->[0] eq 'note' } @{$d->{-score}{Score}};
is $n, 1, "rest";

$x = $d->beat();
ok $x > 0, "beat=$x";
$x = $d->beat(-n => 1);
ok $x == 1, "beat=$x";
$x = $d->beat(-last => 1);
ok $x != 1, "beat=$x";
$x = $d->beat(-n => 1, -fill => 1);
ok $x == 1, "fill=$x";
$x = $d->beat(-fill => 1, -last => 2);
ok $x != 2, "fill=$x";

$x = $d->fill();
ok $x > 0, "fill=$x";
$x = $d->fill(-n => 1, -fill => 1);
ok $x == 1, "fill=$x";
$x = $d->fill(-fill => 1, -last => 2);
ok $x != 2, "fill=$x";

$x = $d->write();
ok $x, "$x write";
$x = $d->write('foo.mid');
ok $x, "$x write";