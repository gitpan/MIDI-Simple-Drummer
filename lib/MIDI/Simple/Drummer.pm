package MIDI::Simple::Drummer;
our $VERSION = '0.00_09';
use strict;
use warnings;
use MIDI::Simple;

# The default drumkit.
my %KIT = (
    -tick => 'Closed Hi-Hat',
    -hhat => [
        'Closed Hi-Hat', # 42
        'Open Hi-Hat', # 46
        'Pedal Hi-Hat', # 44
    ],
    -crash => [
        'Chinese Cymbal', # 52
        'Crash Cymbal 1', # 49
        'Crash Cymbal 2', # 57
        'Splash Cymbal', # 55
    ],
    -ride => [
        'Ride Bell', # 53
        'Ride Cymbal 1', # 51
        'Ride Cymbal 2', # 59
    ],
    -tom => [
        'High Tom', # 50
        'Hi-Mid Tom', # 48
        'Low-Mid Tom', # 47
        'Low Tom', # 45
        'High Floor Tom', # 43
        'Low Floor Tom', # 41
    ],
    -kick => 'Acoustic Bass Drum', # 35
    -snare => 'Acoustic Snare', # 38
    -backbeat => ['Acoustic Snare', 'Acoustic Bass Drum'],
    -kicktick => ['Acoustic Bass Drum', 'Side Stick'],
);

# The known beats.
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
        for my $beat (1 .. $self->{-beats}) {
            my $n = $self->rotate($beat, $args{-rotate});
            $self->note(
                QUARTER(),
                $self->option_strike(%args, -options => $options),
                $n
            );
        }
    },
    2 => sub { # Basic rock beat: en c-hh. qn k1,3. qn s2,4. Crash after fill.
        my $self = shift;
        my %args = @_;
        for my $beat (1 .. $self->{-beats}) {
            my($c, $n) = $self->_backbeat_rotate(%args, -beat => $beat);
            $self->note(EIGHTH(), $c, $n);
            $self->note(EIGHTH(), $self->tick);
        }
    },
    3 => sub { # Main rock beat: en c-hh. qn k1,3,3&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for my $beat (1 .. $self->{-beats}) {
            my($c, $n) = $self->_backbeat_rotate(%args, -beat => $beat);
            $self->note(EIGHTH(), $c, $n);
            if($beat == 3) {
                $self->note(EIGHTH(), $self->kicktick);
            }
            else {
                $self->note(EIGHTH(), $self->tick);
            }
        }
    },
    4 => sub { # Syncopated rock beat 1: en c-hh. qn k1,3,4&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for my $beat (1 .. $self->{-beats}) {
            my($c, $n) = $self->_backbeat_rotate(%args, -beat => $beat);
            $self->note(EIGHTH(), $c, $n);
            if($beat == 4) {
                $self->note(EIGHTH(), $self->kicktick);
            }
            else {
                $self->note(EIGHTH(), $self->tick);
            }
        }
    },
    5 => sub { # Syncopated rock beat 2: en c-hh. qn k1,3,3&,4&. qn s2,4.
        my $self = shift;
        my %args = @_;
        for my $beat (1 .. $self->{-beats}) {
            my($c, $n) = $self->_backbeat_rotate(%args, -beat => $beat);
            $self->note(EIGHTH(), $c, $n);
            if($beat == 3) {
                $self->note(EIGHTH(), $self->kicktick);
            }
            elsif($beat == 4) {
                $self->note(EIGHTH(), $self->kicktick);
            }
            else {
                $self->note(EIGHTH(), $self->tick);
            }
        }
    },
);

# The known fills.
my %fills = (
    1 => sub {
        my $self = shift;
        $self->note(QUARTER(), $self->snare) for 0 .. 1;
        $self->note(EIGHTH(), $self->snare) for 0 .. 3;
    },
    2 => sub {
        my $self = shift;
        $self->note(EIGHTH(), $self->snare) for 0 .. 1;
        $self->rest(EIGHTH());
        $self->note(EIGHTH(), $self->snare);
        $self->note(QUARTER(), $self->snare) for 0 .. 1;
    },
    3 => sub {
        my $self = shift;
        $self->note(EIGHTH(), $self->snare) for 0 .. 1;
        $self->rest(EIGHTH());
        $self->note(EIGHTH(), $self->snare) for 0 .. 2;
        $self->rest(EIGHTH());
        $self->note(EIGHTH(), $self->snare);
    },
    4 => sub {
        my $self = shift;
        $self->note(QUARTER(), $self->snare) for 0 .. 1;
        $self->note(SIXTEENTH(), $self->snare) for 0 .. 3;
        $self->note(QUARTER(), $self->snare);
    },
);

# Return the rotating backbeat and post-fill note.
sub _backbeat_rotate {
    my $self = shift;
    my %args = @_;
    $args{-beat} ||= 1;
    my $c = $args{-beat} == 1 && $args{-fill}
        ? $self->option_strike(%args) : $self->tick;
    my $n = $self->rotate($args{-beat}, $args{-rotate});
    return $c, $n;
}

# Beat or fill?
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
sub WHOLE {'wn'}
sub HALF {'hn'}
sub QUARTER {'qn'}
sub EIGHTH {'en'}
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
    return -e $self->{-file} ? $file : 0;
}

# o/` How many more times? Treat me the way you wanna do?
sub phrases {
    my $self = shift;
    $self->{-phrases} = shift if @_;
    return $self->{-phrases}
}

# Please, just the facts Ma'am.
sub beats {
    my $self = shift;
    $self->{-beats} = shift if @_;
    return $self->{-beats}
}

# Please, just the facts Ma'am.
sub _n2p { return {%MIDI::notenum2percussion} }
sub _p2n { return {%MIDI::percussion2notenum} }

# Give us note values.
sub strike {
    my $self = shift;
    my @patches = @_;
    my @notes = map { 'n' . $MIDI::percussion2notenum{$_} } @patches;
    return wantarray ? @notes : join(', ', @notes);
}

# Strike or set the closed hi-hat.
sub tick {
    my $self = shift;
    $KIT{-tick} = shift if @_;
    return $self->strike($KIT{-tick});
}

# Strike or set the snare.
sub snare {
    my $self = shift;
    $KIT{-snare} = shift if @_;
    return $self->strike($KIT{-snare});
}

# Strike or set the kick-tick combo.
sub kicktick {
    my $self = shift;
    $KIT{-kicktick} = shift if @_;
    return $self->strike(@{$KIT{-kicktick}});
}

# TODO Accent the 1s by default. Add to score optional.
sub metronome {
    my $self = shift;
    my $patch = shift || 'Pedal Hi-Hat';
    $self->note(QUARTER(), $self->strike($patch))
        for 1 .. $self->{-beats} * $self->{-phrases};
    return $self->{-beats} * $self->{-phrases};
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
    my $patches = shift || $KIT{-backbeat};
    return $self->strike($patches->[$beat % @$patches]);
}

# When in doubt, crash.
sub option_strike {
    my $self = shift;
    my %args = @_;
    my $options = $args{-options} || $KIT{-crash};
    my $patch = $args{-patch} || $options->[rand(@$options)];
    return $self->strike($patch);
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

# Generic pattern selector method.
sub beat {
    my $self = shift;
    my %args = @_;

    # Is there a new pattern to save?
    $self->pattern($args{-n}, $args{-pattern}) if $args{-pattern};
    # Get the pattern id.
    my $n = $args{-n} || 0;
    # Was there a last pattern played?
    $args{-last} ||= 0;
    # Get the number of known patterns.
    my $k = $args{-type} && $args{-type} eq 'fill'
        ? keys %fills : keys %beats;
    # Choose a random pattern if desired.
    while($n eq 0 || $n eq $args{-last}) {
        $n = int(rand($k));
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
  my $d = MIDI::Simple::Drummer->new;

  # A glorified metronome:
  $d->count_in;
  $d->beat for 1 .. $d->phrases;
  $d->fill;

  # A smarter drummer:
  my $beat = 0;
  my $fill = 0;
  $d->count_in;
  for my $p (1 .. $d->phrases) {
    if($p % 2 > 0) {
        $beat = $d->beat(-n => 3, -fill => $fill);
    }
    else {
        $beat = $d->beat(-n => 4);
        $fill = $d->fill(-last => $fill);
    }
  }
  $d->beat(-last => $beat, -fill => $fill);
  $d->fill(-n => 'end', -pattern => \&fin);
  $d->write;

  sub fin {
    my $d = shift;
    $d->note($d->EIGHTH, $d->option_strike;
    $d->note($d->EIGHTH, $d->strike('Splash Cymbal', 'Bass Drum 1'));
    $d->note($d->SIXTEENTH, $d->snare) for 0 .. 2; # TODO backbeat[0]
    $d->rest($d->SIXTEENTH);
    $d->note($d->EIGHTH, $d->strike('Splash Cymbal', 'Bass Drum 1'));
    $d->note($d->SIXTEENTH, $d->snare) for 0 .. 2;
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

  $d->phrases($x);
  $x = $d->phrases();

Set or return the number of phrases to play.

=head2 * beats()

  $d->beats($x);
  $x = $d->beats();

Set or return the number of beats per measure.

=head2 * strike()

  $x = $d->strike('Cowbell'); # 'n56'
  $x = $d->strike('Cowbell', 'Tambourine'); # 'n56, n54'
  @x = $d->strike('Cowbell', 'Tambourine'); # ('n56', 'n54')

Return note values for percussion names with
C<%MIDI::notenum2percussion> in either list or scalar context.

=head2 * metronome()

  $d->metronome();
  $d->metronome('Mute Triangle');

Add beats * phases (with the C<Pedal Hi-Hat> or whatever patch you
supply) to the score.

=head2 * count_in()

  $d->count_in();
  $d->count_in(2); # Number of bars.
  $d->count_in(1, 'Side Stick'); # Bars and patch.

And a-one and a-two and a-one, two, three!E<lt>E<sol>Lawrence WelkE<gt>
..11E<lt>E<sol>FZE<gt>

If No arguments are provided, the C<Closed Hi-Hat> is used.

=head2 * rotate()

  $x = $d->rotate(3);
  $x = $d->rotate(5, ['Mute Hi Conga', 'Open Hi Conga', 'Low Conga']);

Return the rotating back-beat of the rhythm based on the beat number,
given by the first argument.  By default, this is the alternating
snare and kick.  This can be any number of patches you desire by
providing an array reference argument with the patch names.

=head2 * option_strike()

  $p = $d->option_strike();
  $p = $d->option_strike(-options => ['Mute Hi Conga','Open Hi Conga','Low Conga']);

Return a note value from a list of patches (by default the crash
cymbals).  If another set of patches is given, one of those is chosen
at random.

=head2 * note()

  $d->note($d->SIXTEENTH, $d->snare);
  $d->note('sn', 'n38');

Add a note to the score.  This is just a pass-through to L<MIDI::Simple/n>.

=head2 * rest()

  $d->rest($d->SIXTEENTH);
  $d->rest('sn');

Add a rest to the score.  This is just a pass-through to L<MIDI::Simple/r>.

=head2 * beat()

  $x = $d->beat();
  $x = $d->beat(-n => 'foo');
  $x = $d->beat(-last => $x);
  $x = $d->beat(-fill => $x);
  $x = $d->beat(-type => 'fill');
  $x = $d->beat(-n => 'bar', -pattern => \&bar);

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

  $x = $d->fill(-n => 'foo');
  $x = $d->fill(-last => $x);
  $x = $d->fill(-n => 'bar', -pattern => \&bar);

This is just an alias for C<$d-E<gt>beat(-type =E<gt> 'fill', %args)>.

=head2 * pattern()

  $x = $d->pattern(1);
  $x = $d->pattern(paraflamaramadiddle => \&code, -type => 'fill');

Return the code reference to the named pattern.  If a second, coderef
argument is provided, the named pattern is assigned to it.  A third
set of named arguments can be supplied, like C<-type =E<gt> 'fill'>
to select a fill.  Otherwise a beat pattern is assumed.

=head2 * write()

  $x = $d->write(); # Use the preset -file attribute.
  $x = $d->write('Buddy-Rich.mid');

This is just an alias for L<MIDI::Simple/write_score> but with
unimaginably intelligent bits.  It returns the name of the written
file if successful.

=head1 CONVENIENCE METHODS

These are just meant to avoid literal strings, although tiny, and
needing to remember/type MIDI variables.

=head2 * WHOLE

  $d->WHOLE();

Return C<'wn'>.

=head2 * HALF

Return C<'hn'>.

=head2 * QUARTER

Return C<'qn'>.

=head2 * EIGHTH

Return C<'en'>.

=head2 * SIXTEENTH

Return C<'sn'>.

=head2 * _p2n()

Return C<%MIDI::percussion2notenum> a la L<MIDI/GOODIES>.

=head2 * _n2p()

Return the inverse: C<%MIDI::notenum2percussion>.

=head2 * tick()

    $x = $d->tick;
    $x = $d->tick('Mute Triangle');

Strike or set the "tick" patch.  By default, this is the C<Closed Hi-Hat>.

=head2 * snare()

    $x = $d->snare;
    $x = $d->snare('Electric Snare');

Strike or set the "snare" patch.  By default, this is the C<Acoustic Snare>.

=head2 * kicktick()

    $x = $d->kicktick;
    $x = $d->snare(['Bass Drum 1', 'Side Stick']);

Strike or set the "snare" patch.  By default, this is the C<Acoustic Snare>.

=head1 TO DO

* Provide smoother drum-kit and pattern access and creation.

* It don't mean a thing if it ain't got that swing.

* Intelligently modulate dynamics (i.e. "add nuance" like accent and
crescendo).

* Move the repertoire of patterns to someplace like an XML file to
include with the distribution.

=head1 SEE ALSO

The F<eg/*> and F<t/*> files, that come with this distribution.

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
