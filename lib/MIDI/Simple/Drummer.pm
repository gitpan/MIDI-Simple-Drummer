package MIDI::Simple::Drummer;
our $VERSION = '0.00_06';
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
            $self->note(
                QUARTER(),
                $self->strike($self->option_strike(%args, -options => $options)),
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
                ? $self->strike($self->option_strike(%args))
                : $self->strike('Closed Hi-Hat');
            $self->note(EIGHTH(), $c, $n);
            $self->note(EIGHTH(), $self->strike('Closed Hi-Hat'));
        }
    },
    3 => sub { # Main rock beat: en c-hh. qn k1,3,3&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->strike($self->option_strike(%args))
                : $self->strike('Closed Hi-Hat');
            $self->note(EIGHTH(), $c, $n);
            if($_ == 3) {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat', 'Acoustic Bass Drum'));
            }
            else {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat'));
            }
        }
    },
    4 => sub { # Syncopated rock beat 1: en c-hh. qn k1,3,4&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->strike($self->option_strike(%args))
                : $self->strike('Closed Hi-Hat');
            $self->note(EIGHTH(), $c, $n);
            if($_ == 4) {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat', 'Acoustic Bass Drum'));
            }
            else {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat'));
            }
        }
    },
    5 => sub { # Syncopated rock beat 2: en c-hh. qn k1,3,3&,4&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for(1 .. $self->{-beats}) {
            my $n = $self->rotate($_, $args{-rotate});
            my $c = $_ == 1 && $args{-fill}
                ? $self->strike($self->option_strike(%args))
                : $self->strike('Closed Hi-Hat');
            $self->note(EIGHTH(), $c, $n);
            if($_ == 3) {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat', 'Acoustic Bass Drum'));
            }
            elsif($_ == 4) {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat', 'Acoustic Bass Drum'));
            }
            else {
                $self->note(EIGHTH(), $self->strike('Closed Hi-Hat'));
            }
        }
    },
);
my %fills = (
    1 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->strike($args{-patch});
        $self->note(QUARTER(), $patch) for 0 .. 1;
        $self->note(EIGHTH(), $patch) for 0 .. 3;
    },
    2 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->strike($args{-patch});
        $self->note(EIGHTH(), $patch) for 0 .. 1;
        $self->rest(EIGHTH());
        $self->note(EIGHTH(), $patch);
        $self->note(QUARTER(), $patch) for 0 .. 1;
    },
    3 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->strike($args{-patch});
        $self->note(EIGHTH(), $patch) for 0 .. 1;
        $self->rest(EIGHTH());
        $self->note(EIGHTH(), $patch) for 0 .. 2;
        $self->rest(EIGHTH());
        $self->note(EIGHTH(), $patch);
    },
    4 => sub {
        my $self = shift;
        my %args = @_;
        $args{-patch} ||= $kit{-backbeat}->[0];
        my $patch = $self->strike($args{-patch});
        $self->note(QUARTER(), $patch) for 0 .. 1;
        $self->note(SIXTEENTH(), $patch) for 0 .. 3;
        $self->note(QUARTER(), $patch);
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
    $self->_setup();
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
    my $file = shift || $self->{-file};
    $self->{-score}->write_score($file);
    return -e $self->{-file};
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

sub strike {
    my $self = shift;
    my @patches = @_;
    my @notes = map { 'n' . $MIDI::percussion2notenum{$_} } @patches;
    return wantarray ? @notes : join(',', @notes);
}

# TODO Accent the 1s by default. Add to score optional.
sub metronome {
    my $self = shift;
    my $patch = shift || 'Pedal Hi-Hat';
    $self->note(QUARTER(), $self->strike($patch))
        for 1 .. $self->{-beats} * $self->{-phrases};
}

# TODO Prepend to score?
sub count_in {
    my $self = shift;
    my $bars = shift || 1;
    my $patch = shift || 'Closed Hi-Hat';
    $self->note(QUARTER(), $self->strike($patch))
        for 1 .. ($self->{-beats} * $bars);
}

# Rotate through a list of patches. Default snare & kick.
sub rotate {
    my $self = shift;
    my $beat = shift || 0;
    my $patches = shift || $kit{-backbeat};
    return $self->strike($patches->[$beat % @$patches]);
}

# When in doubt, crash.
sub option_strike {
    my $self = shift;
    my %args = @_;
    my $options = $args{-options} || $kit{-crash};
    my $patch = $args{-patch} || $options->[rand(@$options)];
warn"option_strike $patch\n";
    return $patch;
}

# Add a note to the score.
sub note {
    my $self = shift;
    $self->{-score}->n(@_);
}

# Add a rest to the score.
sub rest {
    my $self = shift;
    $self->{-score}->r(@_);
}

# Generic pattern selector method. An anecdotal, possibly allegorical pattern...
sub beat {
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
    $self->beat(-type => 'fill', @_);
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
  my $last_beat = 0;
  my $last_fill = 0;
  $d->count_in();
  for my $p (1 .. $d->phrases) {
    warn "last_beat $last_beat, last_fill: $last_fill\n";
    if($p % 2 > 0) {
        $last_beat = $d->beat(-n => 3, -fill => $last_fill);
    }
    else {
        $last_beat = $d->beat(-n => 4);
        $last_fill = $d->fill(-last => $last_fill);
    }
  }
  $last_beat = $d->beat(-n => 3, -fill => $last_fill);
  $d->pattern('fin', \&fin);
  $d->beat(-n => 'fin');
  $d->write;
  sub fin {
    my $d = shift;
    $d->note($d->EIGHTH, $d->strike($d->option_strike));
    $d->note($d->EIGHTH, $d->strike('Splash Cymbal', 'Bass Drum 1'));
    $d->note($d->SIXTEENTH, $d->strike('Acoustic Snare')) for 0 .. 2;
    $d->rest($d->SIXTEENTH);
    $d->note($d->EIGHTH, $d->strike('Splash Cymbal', 'Bass Drum 1'));
    $d->note($d->SIXTEENTH, $d->strike('Acoustic Snare')) for 0 .. 2;
    $d->note($d->EIGHTH, $d->strike('Crash Cymbal 1', 'Bass Drum 1'));
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

  $d->phrases($p);
  $p = $d->phrases();

Set or return the number of phrases to play.

=head2 * strike()

  $strike = $d->strike('Cowbell'); # 'n56'
  $strike = $d->strike('Cowbell', 'Tambourine'); # 'n56, n54')
  @strike = $d->strike('Cowbell', 'Tambourine'); # ('n56', 'n54')

Return note values for percussion names with
C<%MIDI::notenum2percussion> in either list or scalar context.

=head2 * metronome()

  $d->metronome();
  $d->metronome('Mute Triangle');

Add beats x phases (with the C<Pedal Hi-Hat> or whatever patch you
supply) to the score.

=head2 * count_in()

  $d->count_in();
  $d->count_in(2); # Bars
  $d->count_in(1, 'Side Stick'); # Bars and patch.

And a-one and a-two and a-one, two, three!E<lt>E<sol>Lawrence WelkE<gt>
..11E<lt>E<sol>FZE<gt>

If No arguments are provided, the C<Closed Hi-Hat> is used.

=head2 * rotate()

  $n = $d->rotate(1); # n38
  $n = $d->rotate(2, ['Side Stick', 'Bass Drum 1']); n36
  $n = $d->rotate(#, []); # n

Return the rotating back-beat of the rhythm. By default, this is
the alternating snare and kick.  This can be any number of patches you
desire by providing a third array reference argument with the patch
names.

=head2 * option_strike()

  $p = $d->option_strike();
  $p = $d->option_strike(-patch => 'Splash Cymbal');
  $p = $d->option_strike(-options => ['Mute Hi Conga','Open Hi Conga','Low Conga']);

Return a selection from a list of patches, if one is not given.  If a
set of optional patches is given, a random one is chosen.

=head2 * note()

  $d->note('sn', 'n38');
  $d->note($d->SIXTEENTH, $d->strike('Acoustic Snare'));

Add a note to the score.  This is just a pass-through to L<MIDI::Simple/n>.

=head2 * rest()

  $d->rest($d->SIXTEENTH);
  $d->rest('sn');

Add a rest to the score.  This is just a pass-through to L<MIDI::Simple/r>.

=head2 * beat()

  $last_beat = $d->beat();
  $last_beat = $d->beat(-n => 'foo');
  $last_fill = $d->beat(-type => 'fill', -last => $last_fill);
  $last_beat = $d->beat(-fill => $last_fill);
  $last_beat = $d->beat(-last => $last_beat);

Play a beat or fill and return the id for the selected pattern.  Beats
and fills are both just patterns but drummers think of them as
distinct animals.

This method adds an anecdotal "beat" to the event stream.  You can
indicate that we filled in the previous bar, and do something exciting
like crash on the first beat, by supplying the C<-fill =E<gt> $y>
argument, where C<$y> is the fill we just played.  Similarly, the
C<-last =E<gt> $z> argument indicates that C<$z> is the last beat we
played, so that we can maintain "context sensitivity."

Unless specifically given a pattern to play with the C<-n> argument,
we try to play something different each time, so if the pattern is the
same as the C<-last>, or if there is no given pattern to play, another
is chosen.

For C<-type =E<gt> 'fill'>, we append a drum-fill to the event stream.
See the L<MIDI::Simple::Drummer/fill> section for this shortcut.

=head2 * fill()

  $last_fill = $d->fill(-n => 'foo');
  $last_fill = $d->fill(-last => $last_fill);

This is just an alias for C<$d-E<gt>beat(-type =E<gt> 'fill', %args)>.

=head2 * pattern()

  $p = $d->pattern(1);
  $p = $d->pattern('paraflamaramadiddle', $coderef);
  $p = $d->pattern('paraflamaramadiddle', $coderef, -type => 'fill');

Return the code reference to the named pattern.  If a second, coderef
argument is provided, the named pattern is assigned to it.  A third
set of named arguments can be supplied, like C<-type =E<gt> 'fill'>
to select a fill.  Otherwise a beat pattern is assumed.

=head2 * write()

  $x = $d->write(); # Uses the -file attribute.
  $x = $d->write('Buddy-Rich.mid');

This is just an alias for L<MIDI::Simple/write_score> but with
unimaginably intelligent bits.  It returns the name of the written
file if successful.

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

* Provide smoother access o and creation of the drum-kit and patterns.

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
