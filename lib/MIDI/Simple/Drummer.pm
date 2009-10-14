package MIDI::Simple::Drummer;
our $VERSION = '0.00_04';
use strict;
use warnings;
use MIDI::Simple;

# The default drumkit, known beats and fills.
my %kit = (
    -backbeat => ['Acoustic Snare', 'Acoustic Bass Drum'],
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
my %beats = (
    1 => sub { # Quater-note rock beat: qn cym. qn k on 1 & 3. qn s on 2 & 4.
        my $self = shift;
        my %args = @_;
        my $options = [
            'Closed Hi-Hat',
            'Ride Bell',
            'Ride Cymbal 1',
            'Ride Cymbal 2',
#            'Tambourine', # Maybe...
#            'Cowbell', # Maybe not.
        ];
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            $self->{-score}->n(
                QUARTER(),
                $self->kit($self->option_patch(%args, -options => $options)),
                $n
            );
        }
    },
    2 => sub { # Basic rock beat: en c-hh. qn k1,3. qn s2,4. Crash after fill.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->kit($self->option_patch(%args))
                : $self->kit('Closed Hi-Hat');
            $self->{-score}->n(EIGHTH(), $c, $n);
            $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'));
        }
    },
    3 => sub { # Main rock beat: en c-hh. qn k1,3,3&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->kit($self->option_patch(%args))
                : $self->kit('Closed Hi-Hat');
            $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $n);
            if($_ == 3) {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
            }
            else {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'));
            }
        }
    },
    4 => sub { # Syncopated rock beat 1: en c-hh. qn k1,3,4&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->kit($self->option_patch(%args))
                : $self->kit('Closed Hi-Hat');
            $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $n);
            if($_ == 4) {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
            }
            else {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'));
            }
        }
    },
    5 => sub { # Syncopated rock beat 2: en c-hh. qn k1,3,3&,4&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->kit($self->option_patch(%args))
                : $self->kit('Closed Hi-Hat');
            $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $n);
            if($_ == 3) {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
            }
            elsif($_ == 4) {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'), $self->kit('Acoustic Bass Drum'));
            }
            else {
                $self->{-score}->n(EIGHTH(), $self->kit('Closed Hi-Hat'));
            }
        }
    },
);
my %fills = (
    1 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->kit($args{-patch});
        $self->{-score}->n(QUARTER(), $patch) for 0 .. 1;
        $self->{-score}->n(EIGHTH(), $patch) for 0 .. 3;
    },
    2 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->kit($args{-patch});
        $self->{-score}->n(EIGHTH(), $patch) for 0 .. 1;
        $self->{-score}->r(EIGHTH());
        $self->{-score}->n(EIGHTH(), $patch);
        $self->{-score}->n(QUARTER(), $patch) for 0 .. 1;
    },
    3 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->kit($args{-patch});
        $self->{-score}->n(EIGHTH(), $patch) for 0 .. 1;
        $self->{-score}->r(EIGHTH());
        $self->{-score}->n(EIGHTH(), $patch) for 0 .. 2;
        $self->{-score}->r(EIGHTH());
        $self->{-score}->n(EIGHTH(), $patch);
    },
    4 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->kit($args{-patch});
        $self->{-score}->n(QUARTER(), $patch) for 0 .. 1;
        $self->{-score}->n(SIXTEENTH(), $patch) for 0 .. 3;
        $self->{-score}->n(QUARTER(), $patch);
    },
);

sub pattern {
    my $self = shift;
    my $n = shift || return;
    my $v = shift;
    my %args = @_;
    if ($args{-type} && $args{-type} eq 'fill') {
        $fills{$n} = $v if $v;
        return $fills{$n};
    }
    else {
        $beats{$n} = $v if $v;
        return $beats{$n};
    }
}

# Note values.
sub WHOLE     {'wn'}
sub HALF      {'hn'}
sub QUARTER   {'qn'}
sub EIGHTH    {'en'}
sub SIXTEENTH {'sn'}
#sub THIRTYSECOND {'tn'} ?
#sub SIXTYFOURTH {'fn'} ?

# And The Lord said, "Let there be drumming."
sub new {
    my $class = shift;
    my $self  = {
        # Rhythm metrics.
        -bpm     => 120,
        -phrases => 4,
        -beats   => 4,
        # MIDI settings.
        -channel => '9',
        -volume  => '100',
        # The Goods[TM].
        -file    => 'Drummer.mid',
        -score   => MIDI::Simple->new_score(),
        @_
    };
    bless $self, $class;
    $self->_setup($self);
    return $self;
}

# Where's my Roadies, Man?
sub _setup {
    my $self = shift;
    $self->{-score}->set_tempo(int(60_000_000 / $self->{-bpm}));
    # TODO Settings TLC/TCB.
    $self->{-score}->noop('c'.$self->{-channel}, 'V'.$self->{-volume});
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
sub n2p { return {%MIDI::notenum2percussion} }
sub p2n { return {%MIDI::percussion2notenum} }
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
    $self->{-score}->n(QUARTER(), $self->kit($patch))
        for 1 .. $self->{-beats} * $self->{-phrases};
}

# TODO Prepend to score?
sub count_in {
    my $self = shift;
    my $bars = shift || 1;
    my $patch = shift || 'Closed Hi-Hat';
    $self->{-score}->n(QUARTER(), $self->kit($patch))
        for 1 .. ($self->{-beats} * $bars);
}

# Rotate through a list of patches. Default snare & kick.
sub rotate {
    my $self = shift;
    my $beat = shift || 0;
    my $patches = shift || $kit{-backbeat};
    return $self->kit($patches->[$beat % @$patches]);
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

# Add a note to the score.
sub strike {
    my $self = shift;
    $self->{-score}->n(@_);
}

# Add a rest to the score.
sub rest {
    my $self = shift;
    $self->{-score}->r(@_);
}

# Generic pattern selector method. An anecdotal, possibly allegorical pattern...
sub play {
    my $self = shift;
    my %args = @_;

    # Get the pattern id.
    my $n = $args{-n} || 0;
    # Was there a last pattern played?
    $args{-last} ||= 0;
    # Get the number of known patterns.
    my $k = $args{-type} && $args{-type} eq 'fill'
        ? keys %fills : keys %beats;
    # Choose a random pattern if desired.
    while($n eq 0 || $n eq $args{-last}) {
        $n = int(rand($k)) + 1;
    }
    # To fill or not to fill...
    if($args{-type} && $args{-type} eq 'fill') {
        $fills{$n}->($self, %args);
    }
    else {
        $beats{$n}->($self, %args);
    }

    return $n;
}

# Alias to a fill pattern.
sub fill {
    my $self = shift;
    $self->pattern(-type => 'fill', @_);
}

1;
__END__

=head1 NAME

MIDI::Simple::Drummer - Glorified Metronome

=head1 ABSTRACT

Is there a drummer in the house?

=head1 SYNOPSIS

  use MIDI::Simple::Drummer;
  my $d = MIDI::Simple::Drummer->new(
    -bpm     => shift || 111,
    -volume  => shift || 121,
    -phrases => shift || 2,
  );
  my $last_fill = 0;
  $d->count_in();
  for my $p (0 .. $d->phrases - 1) {
    if($p % 2 > 0) {
        $d->play(-n => 5);
        $last_fill = $d->fill(-last => $last_fill);
    }
    else {
        $d->play(-n => 3, -fill => $p);
    }
  }
  $d->pattern('fin', \&fin);
  $d->play(-n => 'fin');
  $d->write;
  sub fin {
    my $d = shift;
    $d->strike($d->EIGHTH, $d->kit($d->option_patch));
    $d->strike($d->EIGHTH, $d->kit('Splash Cymbal'), $d->kit('Bass Drum 1'));
    $d->strike($d->SIXTEENTH, $d->kit('Acoustic Snare')) for 0 .. 2;
    $d->rest($d->SIXTEENTH);
    $d->strike($d->EIGHTH, $d->kit('Splash Cymbal'), $d->kit('Bass Drum 1'));
    $d->strike($d->SIXTEENTH, $d->kit('Acoustic Snare')) for 0 .. 2;
    $d->strike($d->EIGHTH, $d->kit('Crash Cymbal 1'), $d->kit('Bass Drum 1'));
  }

=head1 DESCRIPTION

This module is embroyonic but may yet grow into a giant reptilian
monster that smashes Tokyo.

Until then, this is just meant to be a robotic drummer and hide the
L<MIDI::Simple> parameters.

=head1 METHODS

=head2 * new()

  my $d = MIDI::Simple::Drummer->new(%arguments);

Far away in a distant galaxy... But nevermind that, Luke. Use The
Source.

=head2 * phrases()

Return or set the number of phrases to play.

=head2 * kit()

Return note values for percussion names with
C<%MIDI::notenum2percussion>.

=head2 * metronome()

Beats x Phases with the C<Pedal Hi-Hat> or whatever patch you supply.

=head2 * count_in()

And a-one and a-two and a-one, two, three!E<lt>E<sol>Lawrence WelkE<gt>
..11E<lt>E<sol>FZE<gt>

=head2 * rotate()

Return the rotating back-beat of the rhythm. By default, this is
the alternating snare and kick.  This can be any number of patches you
desire by providing a third array reference argument with the patch
names.

=head2 * option_patch()

Return a selection from a list of patches, if one is not given.

=head2 * strike()

Add a note to the score.

=head2 * rest()

Add a rest to the score.

=head2 * play()

Play a beat or fill and return the id (a hash key) for the selected
pattern.  Beats and fills are both just patterns but drummers think of
them as distinct animals.

This method adds a fictional, anecdotal "beat" to the event stream.
You can indicate that we filled in the previous bar, and do something
exciting like crash on the first beat, by supplying the
C<-fill =E<gt> $x> argument, where C<$x> is the fill we just played.

For C<-type =E<gt> 'fill'>, we append a drum-fill to the event stream
and return the name of the selected fill.

Unless specifically given a pattern to play, we try to play something
different each time, so if the pattern is the same as the C<-last>, or
if there is no given pattern to play, another is chosen.

=head2 * fill()

This is just an alias for C<$d-E<gt>play(-type =E<gt> 'fill', %args)>.

=head2 * pattern($name[, $value])

Return the code reference to the named pattern.  If a second, coderef
argument is provided, the named pattern is assigned to it.  A third
set of named arguments can be supplied, like C<-type =E<gt> 'fill'>
to select a fill.  Otherwise a beat pattern is assumed.

=head2 * write()

This is just an alias for L<MIDI::Simple/write_score> but with
unimaginably intelligent bits.

=head1 CONVENIENCE METHODS

These are just meant to avoid literal strings, although tiny, and
needing to remember/type MIDI variables.

=head2 * WHOLE

Return C<'wn'>.

=head2 * HALF

Return C<'hn'>.

=head2 * QUARTER

Return C<'qn'>.

=head2 * EIGHTH

Return C<'en'>.

=head2 * SIXTEENTH

Return C<'sn'>.

=head2 * p2n()

Return C<%MIDI::percussion2notenum> a la L<MIDI/GOODIES>.

=head2 * n2p()

Return the inverse: C<%MIDI::notenum2percussion>.

=head1 TO DO

* Provide smoother access to the current drum-kit, beat and fill
patterns.

* Move the repertoire of patterns to someplace like
C<MIDI::Simple::Drummer::Patterns>.

* It don't mean a thing if it ain't got that swing.

* Intelligently modulate dynamics (i.e. "add nuance" like accent and
crescendo).

=head1 SEE ALSO

The F<eg/*> file(s), that come(s) with this distribution.

L<MIDI::Simple> itself.

L<http://maps.google.com/maps?q=mike+avery+joplin> - my drum teacher.

=head2 POSSIBLY HANDY

L<MIDI::Tab/from_drum_tab>

L<Music::Tempo>

L<MIDI::Tweaks>

L<MIDI::XML>

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2009, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it under
the same terms as Perl itself.

=cut
