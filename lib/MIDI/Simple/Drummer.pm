package MIDI::Simple::Drummer;
our $VERSION = '0.00_01';

use strict;
use warnings;

use MIDI::Simple;

# Note values.
use constant WHOLE => 'wn';
use constant HALF => 'hn';
use constant QUARTER => 'qn';
use constant EIGHTH => 'en';
use constant SIXTEENTH => 'sn';
#use constant THIRTYSECOND => 'tn'; ?
#use constant SIXTYFOURTH => 'fn'; ?

# This is the default drumkit:
my %kit = (
    -back_beat => ['Acoustic Bass Drum', 'Acoustic Snare'],
    -hhat => [
        'Closed Hi-Hat',
        'Open Hi-Hat',
        'Pedal Hi-Hat',
    ],
    -crash => [
        'Chinese Cymbal',
        'Crash Cymbal 1',
        'Crash Cymbal 2',
        'Splash Cymbal',
    ],
    -ride => [
        'Ride Bell',
        'Ride Cymbal 1',
        'Ride Cymbal 2',
    ],
    -toms => [
        'High Tom',
        'Hi-Mid Tom',
        'Low-Mid Tom',
        'Low Tom',
        'High Floor Tom',
        'Low Floor Tom',
    ],
);

sub new {
    my $class = shift;
    my $self  = {
        # Rhythm metrics.
        -bpm     => 120,
        -phrases => 4,
        -beats   => 4,
        # MIDI settings.
        -channel => 'c9',
        -volume  => 'V96',
        # The Goods[TM].
        -file    => lc __PACKAGE__ . '.mid',
        -score   => MIDI::Simple->new_score(),
        @_
    };
    bless $self, $class;
    $self->_init($self);
    return $self;
}

# Where's my Roadies, Man?
sub _init {
    my $self = shift;
    $self->{-score}->set_tempo(int(60_000_000 / $self->{-bpm}));
    # TODO Settings TLC/TCB.
    $self->{-score}->noop($self->{-channel}, $self->{-volume});
}

# You gotta get it out there, you know. Make some buzz, Man.
sub write {
    my $self = shift;
    $self->{-score}->write_score($self->{-file});
}

# o/` How many more times? Treat me the way you wanna do?
sub phrases {
    my $self = shift;
    $self->{-phrases} = shift if @_;
    return $self->{-phrases}
}

# Please, just the facts Ma'am.
sub n2p { %MIDI::notenum2percussion }
sub p2n { %MIDI::percussion2notenum }
sub kit {
    my $self = shift;
    my @patches = @_;
    my @notes = map { 'n' . $MIDI::percussion2notenum{$_} } @patches;
    return @notes > 1 ? @notes : $notes[0];
}

# TODO Accent the 1s by default. Add to score optional.
sub metronome {
    my $self = shift;
    my $patch = shift || 'Pedal Hi-Hat';
    $self->{-score}->n(QUARTER, $self->kit($patch))
        for 1 .. $self->{-beats} * $self->{-phrases};
}

# TODO Prepend to score?
sub count_in {
    my $self = shift;
    my $bars = shift || 1;
    my $patch = shift || 'Closed Hi-Hat';
    $self->{-score}->n(QUARTER, $self->kit($patch))
        for 1 .. ($self->{-beats} * $bars);
}

# Alternate between two patches. Default kick & snare.
sub alternate {
    my $self = shift;
    my $beat = shift || 0;
    my $patches = shift || $kit{-back_beat};
    return $beat % 2 > 0 ? $self->kit($patches->[0]) : $self->kit($patches->[1]);
}

# When in doubt, crash.
sub option_patch {
    my $self = shift;
    my %args = @_;
    my $options = $args{-options} || $kit{-crash};
    my $patch = $args{-patch} || $options->[rand(@$options)];
warn"option_patch: $patch\n";
    return $patch;
}

# TODO Support user defined patterns.
# Quater-note rock beat: qn cym. qn k on 1 & 3. qn s on 2 & 4.
sub beat_1 {
    my $self = shift;
    my %args = @_;
    my $options = [
        'Closed Hi-Hat',
        'Ride Bell',
        'Ride Cymbal 1',
        'Ride Cymbal 2',
#        'Tambourine', # Maybe...
#        'Cowbell', # Ugh.
    ];
    for(1 .. $self->{-beats}) {
        my $n = $self->alternate($_, $args{-alternate});
        $self->{-score}->n(
            QUARTER,
            $self->kit($self->option_patch(%args, -options => $options)),
            $n
        );
    }
}
# Basic rock beat: en c-hh. qn k1,3. qn s2,4. Crash after fill.
sub beat_2 {
    my $self = shift;
    my %args = @_;
    for(1 .. $self->{-beats}) {
        my $n = $self->alternate($_, $args{-alternate});
        my $c = $_ == 1 && $args{-fill}
            ? $self->kit($self->option_patch(%args))
            : $self->kit('Closed Hi-Hat');
        $self->{-score}->n(EIGHTH, $c, $n);
        $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'));
    }
}
# Main rock beat: en c-hh. qn k1,3,3&. qn s2,4.
sub beat_3 {
    my $self = shift;
    my %args = @_;
    for(1 .. $self->{-beats}) {
        my $n = $self->alternate($_, $args{-alternate});
        my $c = $_ == 1 && $args{-fill}
            ? $self->kit($self->option_patch(%args))
            : $self->kit('Closed Hi-Hat');
        $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $n);
        if($_ == 3) {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
        }
        else {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'));
        }
    }
}
# Syncopated rock beat 1: en c-hh. qn k1,3,4&. qn s2,4.
sub beat_4 {
    my $self = shift;
    my %args = @_;
    for(1 .. $self->{-beats}) {
        my $n = $self->alternate($_);
        my $c = $_ == 1 && $args{-fill}
            ? $self->kit($self->option_patch(%args))
            : $self->kit('Closed Hi-Hat');
        $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $n);
        if($_ == 4) {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
        }
        else {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'));
        }
    }
}
# Syncopated rock beat 2: en c-hh. qn k1,3,3&,4&. qn s2,4.
sub beat_5 {
    my $self = shift;
    my %args = @_;
    for(1 .. $self->{-beats}) {
        my $n = $self->alternate($_);
        my $c = $_ == 1 && $args{-fill}
            ? $self->kit($self->option_patch(%args))
            : $self->kit('Closed Hi-Hat');
        $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $n);
        if($_ == 3) {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
        }
        elsif($_ == 4) {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
        }
        else {
            $self->{-score}->n(EIGHTH, $self->kit('Closed Hi-Hat'));
        }
    }
}

# TODO Support user defined patterns.
sub fill {
    my $self = shift;
    my %args = @_;
    my $n = $args{-n} || 0;
    $args{-last} ||= 0;
    while($n == 0 || $n == $args{-last}) {
        $n = int(rand(4)) + 1;
    }
    my $method = 'fill_' . $n;
    $self->$method;
    return $n;
}
sub fill_1 {
    my $self = shift;
    $self->{-score}->n(QUARTER, $self->kit('Acoustic Snare')) for 0 .. 1;
    $self->{-score}->n(EIGHTH, $self->kit('Acoustic Snare')) for 0 .. 3;
}
sub fill_2 {
    my $self = shift;
    $self->{-score}->n(EIGHTH, $self->kit('Acoustic Snare')) for 0 .. 1;
    $self->{-score}->r(EIGHTH);
    $self->{-score}->n(EIGHTH, $self->kit('Acoustic Snare'));
    $self->{-score}->n(QUARTER, $self->kit('Acoustic Snare')) for 0 .. 1;
}
sub fill_3 {
    my $self = shift;
    $self->{-score}->n(EIGHTH, $self->kit('Acoustic Snare')) for 0 .. 1;
    $self->{-score}->r(EIGHTH);
    $self->{-score}->n(EIGHTH, $self->kit('Acoustic Snare')) for 0 .. 2;
    $self->{-score}->r(EIGHTH);
    $self->{-score}->n(EIGHTH, $self->kit('Acoustic Snare'));
}
sub fill_4 {
    my $self = shift;
    $self->{-score}->n(QUARTER, $self->kit('Acoustic Snare')) for 0 .. 1;
    $self->{-score}->n(SIXTEENTH, $self->kit('Acoustic Snare')) for 0 .. 3;
    $self->{-score}->n(QUARTER, $self->kit('Acoustic Snare'));
}

1;
__END__

=head1 NAME

MIDI::Simple::Drummer - Glorified metronome

=head1 ABSTRACT

Is there a drummer in the house?

=head1 SYNOPSIS

  use MIDI::Simple::Drummer;
  my $d = MIDI::Simple::Drummer->new(-bpm => 111);
  $d->count_in();
  for(0 .. $d->phrases - 1) {
    $d->beat_2(-fill => $_);
    $d->beat_3();
    $d->fill();
  }
  $d->write;

=head1 DESCRIPTION

This module is embroyonic but may yet grow into a giant reptilian
monster that smashes Tokyo.

Until then, this is just meant to be a robotic drummer and hide the
ugliness of fooling with L<MIDI::Simple> parameters.

=head1 METHODS

=head2 * new()

  my $d = MIDI::Simple::Drummer->new(%arguments);

Far away in a distant galaxy... But nevermind that Luke, use The Source.

=head2 * phrases()

Return or set the number of phrases to play.

=head2 * n2p(), p2n()

Return %MIDI::notenum2percussion or %MIDI::percussion2notenum.

=head2 * kit()

Return note values for percussion names.

=head2 * metronome()

Beats x Phases.

=head2 * count_in()

And a-one, and a-two and a-one, two, three, four!</Lawrence Welk> ..11</FZ>

=head2 = * alternate()

Return the alternating backbeat of the rhythm. By default, this is the
kick and snare.

=head2 = * option_patch()

Return a patch name from a given patch or a random selection from a
list of patches.

=head2 * foo_beat()

Append a bar of this anecdotal beat onto the event stream.  Indicate
that we filled in the previous bar to crash on the first beat.

=head2 * fill()

Append a glop of filler cheese to the event stream and return the id
for the chosen fill.  The C<N> parameter determines which fill will be
played.  If C<N=0> or there is no C<Nth> fill, a random one is chosen.

=head2 * write()

This is just an alias for L<MIDI::Simple/write_score>.

=head1 TO DO

* Read the source TODO comments.
  > grep TODO `perldoc -l MIDI::Simple::Drummer`

* Make the beats and fills a user definable list of coderefs.

* Allow smoother modification of the drum kit.

* It don't mean a thing if it ain't got that swing.

* Intelligently modulate dynamics (A.K.A. "add nuance").

=head1 SEE ALSO

The F<eg/*> file(s), that come(s) with this distribution.

L<MIDI::Simple> itself.

L<http://maps.google.com/maps?q=mike+avery+joplin> - my drum teacher.

L<MIDI::Tab/from_drum_tab> - possibly handy

L<Music::Tempo> - possibly handy

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2009, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it under the same terms as Perl itself.

=cut
