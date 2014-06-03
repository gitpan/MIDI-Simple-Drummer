
BEGIN {
  unless ($ENV{RELEASE_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for release candidate testing');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::NoTabsTests 0.08

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/MIDI/Simple/Drummer.pm',
    'lib/MIDI/Simple/Drummer/Euclidean.pm',
    'lib/MIDI/Simple/Drummer/Jazz.pm',
    'lib/MIDI/Simple/Drummer/Rock.pm',
    'lib/MIDI/Simple/Drummer/Rudiments.pm',
    't/00-compile.t',
    't/00-load.t',
    't/01-Drummer.t',
    't/02-Rock.t',
    't/03-Jazz.t',
    't/04-Rudiments.t',
    't/05-Euclidean.t',
    't/author-pod-spell.t',
    't/release-eol.t',
    't/release-no-tabs.t',
    't/release-pod-coverage.t',
    't/release-pod-syntax.t'
);

notabs_ok($_) foreach @files;
done_testing;
