#!perl -T
use strict;
use warnings;
use Test::More tests => 6;

BEGIN { use_ok('MIDI::Simple::Drummer') }

my $module = 'MIDI::Simple::Drummer';

# Instantiation.
my $d = eval { $module->new() };
isa_ok $d, $module;
ok !$@, 'created with no arguments';

# Phrases.
my $x = $d->phrases();
ok $x, "$x phrases";
$x = $d->phrases(2);
is $x, 2, "set phrases";

# Output.
$x = $d->write();
is $x, 1, "write";
