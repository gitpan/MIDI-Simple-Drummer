#!perl -T
use strict;
use warnings;
use Test::More tests => 74;

BEGIN { use_ok('MIDI::Simple::Drummer') }

my $d = eval { MIDI::Simple::Drummer->new };
isa_ok $d, 'MIDI::Simple::Drummer';
ok !$@, 'created with no arguments';

is $d->WHOLE, 'wn', 'WHOLE';
is $d->HALF, 'hn', 'HALF';
is $d->QUARTER, 'qn', 'QUARTER';
is $d->EIGHTH, 'en', 'EIGHTH';
is $d->SIXTEENTH, 'sn', 'SIXTEENTH';
TODO: { local $TODO = 'not yet implemented';
my $x = eval { $d->THIRTYSECOND };
is $x, 'ts', 'THIRTYSECOND';
$x = eval { $d->SIXTYFOURTH };
is $x, 'sf', 'SIXTYFOURTH';
}

my $x = $d->channel;
is $x, 9, 'get default channel';
$x = $d->channel(2);
is $x, 2, 'set channel';
$d->channel(9); # Ok enough of that.

$x = $d->bpm;
is $x, 120, 'get default bpm';
$x = $d->bpm(111);
is $x, 111, 'set bpm';

$x = $d->volume;
is $x, 100, 'get default volume';
$x = $d->volume(101);
is $x, 101, 'set volume';

$x = $d->phrases;
is $x, 4, 'get default phrases';
$x = $d->phrases(2);
is $x, 2, 'set phrases';

$x = $d->beats;
is $x, 4, 'get default beats';
$x = $d->beats(2);
is $x, 2, 'set beats';

$x = $d->file;
is $x, 'Drummer.mid', 'get default file';
$x = $d->file('Buddy-Rich.mid');
is $x, 'Buddy-Rich.mid', 'set file';

$x = $d->score;
isa_ok $x, 'MIDI::Simple', 'score';

$x = $d->accent;
is $x, 127, 'get default accent';
$x = $d->accent(20);
is $x, 121, 'set accent';

$x = $d->kit;
isa_ok $x, 'HASH';
$x = $d->kit('clank');
is $x, undef, 'kit clank undef';
$x = $d->kit(clunk => ['Foo','Bar']);
is_deeply $x, ['Foo','Bar'], 'kit set clunk';

$x = $d->name_of('kick');
is $x, 'Acoustic Bass Drum', 'kick is Acoustic Bass Drum';

$x = $d->snare;
is $x, 'n38', 'snare';
$x = $d->kick;
is $x, 'n35', 'kick';
$x = $d->tick;
is $x, 'n42', 'tick';
$x = $d->backbeat;
like $x, qr/n3[58]/, 'backbeat';
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

$x = $d->backbeat_rhythm;
is $x, 'n35,n42', 'backbeat_rhythm';
$x = $d->backbeat_rhythm(-beat => 1);
is $x, 'n35,n42', 'backbeat_rhythm 1';
$x = $d->backbeat_rhythm(-beat => 2);
is $x, 'n38,n42', 'backbeat_rhythm 2';
$x = $d->backbeat_rhythm(-beat => 3);
is $x, 'n35,n42', 'backbeat_rhythm 3';
$x = $d->backbeat_rhythm(-beat => 1, -fill => 0);
is $x, 'n35,n42', 'backbeat_rhythm 1 no fill';
$x = $d->backbeat_rhythm(-beat => 1, -fill => 1);
like $x, qr/n35,n(?:5[257]|49)/, 'backbeat_rhythm 1 fill';
$x = $d->backbeat_rhythm(-beat => 2, -fill => 1);
is $x, 'n38,n42', 'backbeat_rhythm 2 fill';
$x = $d->backbeat_rhythm(-beat => 3, -fill => 1);
is $x, 'n35,n42', 'backbeat_rhythm 3 fill';

$d->patterns;
$x = $d->patterns(1);
is $x, undef, 'get unknown pattern is undef';
my $y = sub { $d->note($d->EIGHTH, $d->strike) };
$x = $d->patterns('y', $y);
is_deeply $x, $y, 'set y pattern';
$x = $d->patterns('y fill', $y);
is_deeply $x, $y, 'set y fill pattern';

$x = eval { $d->beat };
ok $x, 'random beat';
$x = eval { $d->fill };
ok $x, 'random fill';
$x = eval { $d->beat(-name => 'y') };
is $x, 'y', 'named y beat';
$x = eval { $d->beat(-type => 'fill') };
like $x, qr/ fill$/, 'type';
$x = eval { $d->beat(-name => 'y', -type => 'fill') };
is $x, 'y fill', 'named fill';
$x = eval { $d->beat(-last => 1) };
ok $x ne 1, 'last unknown beat';
$x = eval { $d->beat(-last => 'y') };
ok $x ne 'y', 'last known beat';
$x = eval { $d->beat(-last => 'y fill') };
isnt $x, 'y fill', 'last known fill';

$x = $d->write;
ok $x eq 'Drummer.mid' && -e $x, 'write';
$x = $d->write('Gene-Krupa.mid');
ok $x eq 'Gene-Krupa.mid' && -e $x, 'named write';
