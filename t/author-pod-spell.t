
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;
use Test::More;

# generated by Dist::Zilla::Plugin::Test::PodSpelling 2.006008
use Test::Spelling 0.12;
use Pod::Wordlist;

set_spell_cmd('aspell list');
add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( bin lib  ) );
__DATA__
API
CPAN
DAW
Dragadiddle
Flam
flam
Flamacue
Flammed
flammed
Goroway
OO
Paradiddle
Pataflafla
Ratamacue
Rudd
SIXTYFOURTH
THIRTYSECOND
TODO
backbeat
constuctor
controled
de
drumkit
facto
fff
filename
hhat
reverb
Euclidian
Gene
Boggs
gene
lib
MIDI
Simple
Drummer
Rudiments
Jazz
Euclidean
Rock
