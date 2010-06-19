package MIDI::Simple::Drummer;
our $VERSION = '0.00_23';
use strict;
use warnings;
use MIDI::Simple;

sub new { # Is there a drummer in the house?
    my $class = shift;
    my $self = {
        # MIDI
        -channel => 9,
        -volume => 100,
        # Rhythm
        -accent => 30, # Volume increment
        -bpm => 120,
        -phrases => 4, # Also equals measures
        -beats => 4,   # Beats per measure
        # The Goods[TM].
        -score => undef,
        -file => 'Drummer.mid',
        -kit => undef,
        -patterns => undef,
        @_
    };
    bless $self, $class;
    $self->_setup();
    return $self;
}
sub _setup { # Where's my Roadies, Man?
    my $self = shift;

    # XXX For now there is only one, linear score so: TODO Multitrack!
    $self->{-score} ||= MIDI::Simple->new_score;
    $self->{-score}->noop('c'.$self->{-channel}, 'V'.$self->{-volume});
    $self->{-score}->set_tempo(int(60_000_000 / $self->{-bpm}));

    # Give unto us a drum, so that we might bang upon it all day, instead of working.
    $self->{-kit} ||= $self->_default_kit();
    $self->{-patterns} ||= $self->_default_patterns();

    return $self;
}

sub _n2p { return \%MIDI::notenum2percussion } # Convenience functions.
sub _p2n { return \%MIDI::percussion2notenum }

sub WHOLE {'wn'} # Readable durations.                                                                                                
sub HALF {'hn'}
sub QUARTER {'qn'}
sub EIGHTH {'en'}
sub SIXTEENTH {'sn'} # TODO THIRTYSECOND, SIXTYFOURTH

# Accessors.
sub channel { # The general MIDI drumkit is often channel 9.
    my $self = shift;
    $self->{-channel} = shift if @_;
    return $self->{-channel}
}
sub bpm { # Beats per minute.
    my $self = shift;
    $self->{-bpm} = shift if @_;
    return $self->{-bpm}
}
sub volume { # TURN IT DOWN IN THERE!
    my $self = shift;
    $self->{-volume} = shift if @_;
    return $self->{-volume}
}
sub phrases { # o/` How many more times? Treat me the way you wanna do?
    my $self = shift;
    $self->{-phrases} = shift if @_;
    return $self->{-phrases}
}
sub beats { # Beats per measure.
    my $self = shift;
    $self->{-beats} = shift if @_;
    return $self->{-beats}
}
sub file { # The name of the "file.mid" output.
    my $self = shift;
    $self->{-file} = shift if @_;
    return $self->{-file}
}

sub score { # The MIDI::Simple score with no-op-ability.
    my $self = shift;
    $self->{-score} = shift if ref $_[0] eq 'MIDI::Simple';
    # Set any remaining arguments as score no-ops.
    $self->{-score}->noop($_) for @_;
    return $self->{-score}
}

# API: Subclass and redefine to emit nuance.
# API: Make a "ducker" method (i.e. the opposite).
sub accent { # Pump up the [dynamics] (default Volume)!
    my $self = shift;
    $self->{-accent} = shift if @_;
    my $accent = $self->{-accent} + $self->volume;
    $accent = $MIDI::Simple::Volume{fff}
        if $accent > $MIDI::Simple::Volume{fff};
    return $accent;
}

sub kit { # Arrayrefs of patches.
    my $self = shift;
    return $self->_type('-kit', @_);
}
sub patterns { # Coderefs of patterns.
    my $self = shift;
    return $self->_type('-patterns', @_);
}

# XXX This _type() method is exceedingly ugly.
sub _type { # Both kit and pattern access.
    my $self = shift;
    my $type = shift || return;
    if(!@_) { # If no arguments return all known types.
        return $self->{$type};
    }
    elsif(@_ == 1) { # Return a named type.
        my $i = shift;
        return wantarray
            ? ($i => $self->{$type}{$i})
            : $self->{$type}{$i};
    }
    elsif(@_ > 1 && !(@_ % 2)) { # Add new types.
        my %args = @_;
        my @t = ();
        while(my($i, $v) = each %args) {
            $self->{$type}{$i} = $v;
            push @t, $i;
        }
        # Return the named types.
        return wantarray
            ? (map { $_ => $self->{$type}{$_} } @t) # Hash of named types.
            : @t > 1                                # More than one?
                ? [map { $self->{$type}{$_} } @t]   # Arrayref of types.
                : $self->{$type}{$t[0]};            # Else single type.
    }
    else {
        warn 'WARNING: Mystery arguments. Giving up.'
    }
}

sub name_of { # Return instrument name(s) given kit keys.
    my $self = shift;
    my $key = shift || return;
    return wantarray ? @{$self->kit($key)} : join ',', @{$self->kit($key)};
}

sub _set_get { # Internal kit access.
    my $self = shift;
    my $key = shift || return;
    # Set the kit event.
    $self->kit($key => [@_]) if @_;
    return $self->option_strike(@{$self->kit($key)});
}

# API: Add "something"s to your kit & patterns, in a subclass.
sub backbeat { return shift->_set_get('backbeat', @_) }
sub snare    { return shift->_set_get('snare', @_) }
sub kick     { return shift->_set_get('kick', @_) }
sub tick     { return shift->_set_get('tick', @_) }
sub hhat     { return shift->_set_get('hhat', @_) }
sub crash    { return shift->_set_get('crash', @_) }
sub ride     { return shift->_set_get('ride', @_) }
sub tom      { return shift->_set_get('tom', @_) }

sub strike { # Return note values.
    my $self = shift;
    my @patches = @_ ? @_ : @{$self->kit('snare')};
    my @notes = map { 'n' . $MIDI::percussion2notenum{$_} } @patches;
    return wantarray ? @notes : join(',', @notes);
}
# API: Redefine this method to use a different decision than C<rand>.
sub option_strike { # When in doubt, crash.
    my $self = shift;
    my @patches = @_ ? @_ : @{$self->kit('crash')};
    return $self->strike($patches[int(rand @patches)]);
}

sub rotate { # Rotate through a list of patches. Default backbeat.
    my $self = shift;
    my $beat = shift || 1;
    my $patches = shift || $self->kit('backbeat');
    return $self->strike($patches->[$beat % @$patches]);
}
sub backbeat_rhythm { # AC/DC forever.
    # Rotate the backbeat with tick & post-fill strike.
    my $self = shift;
    my %args = (
        -beat => 1,
        -fill => 0,
        -backbeat => scalar $self->kit('backbeat'),
        -tick => scalar $self->kit('tick'),
        -patches => scalar $self->kit('crash'),
        @_
    );
    # Strike a cymbal (or the provided patches).
    my $c = $args{-beat} == 1 && $args{-fill}
        ? $self->option_strike(@{$args{-patches}})
        : $self->strike(@{$args{-tick}});
    # Rotate the backbeat.
    my $n = $self->rotate($args{-beat}, $args{-backbeat});
    # Return the cymbal and backbeat note.
    return wantarray ? ($n, $c) : join(',', $n, $c);
}

# Readable, MIDI score pass-throughs.
sub note { return shift->{-score}->n(@_) }
sub rest { return shift->{-score}->r(@_) }

sub count_in {
    my $self = shift;
    my $bars = shift || 1;
    my $strike = @_ ? $self->strike(@_) : $self->tick;
    for my $i (1 .. $self->beats * $bars) {
        $self->score('V'.$self->accent) if $i % $self->beats == 1;
        $self->note(QUARTER(), $strike);
        $self->score('V'.$self->volume) if $i % $self->beats == 1;
    }
    return $strike;
}
sub metronome {
    my $self = shift;
    return $self->count_in($self->phrases, shift || 'Pedal Hi-Hat');
}

# XXX This "skipping named types" is a bit dodgy but seems to work.
sub beat { # Pattern selector method.
    my $self = shift;
    my %args = (
        -name => 0,
        -fill => 0,
        -last => 0,
        -type => '',
        @_
    );

    return undef unless ref($self->patterns) eq 'HASH';
    # Get the names of the known patterns.
    my @k = keys %{$self->patterns};
    # Bail out if we know nothing.
    return undef unless @k;

    # Do we want a certain type that isn't already in the given name?
    my $n = $args{-name} && $args{-type} && $args{-name} !~ /^.+\s+$args{-type}$/
          ? "$args{-name} $args{-type}" : $args{-name};

    if(@k == 1) { # Return the only pattern if there is only one.
        $n = $k[0];
    }
    else { # Otherwise choose a different pattern.
        while($n eq 0 || $n eq $args{-last}) {
            # TODO API: Allow custom decision method.
            $n = $k[int(rand @k)];
            if($args{-type}) {
                (my $t = $n) =~ s/^.+\s+($args{-type})$/$1/;
                # Skip if this is not a type for which we are looking.
                $n = 0 unless $t eq $args{-type};
            }
        }
    }

    # Beat it.
    $self->{-patterns}{$n}->($self, %args);
    return $n;
}
sub fill {
    my $self = shift;
    return $self->beat(@_, -type => 'fill');
}

sub write { # You gotta get it out there, you know. Make some buzz, Man.
    my $self = shift;
    my $file = shift || $self->{-file};
    $self->{-score}->write_score($file);
    return -e $file ? $file : 0;
}

# API: Redefine these methods in a subclass.
sub _default_patterns {
    my $self = shift;
    return {};  # Nothing to see here. Move along.
}
sub _default_kit {
    my $self = shift;
    return {
      backbeat => ['Acoustic Snare', 'Acoustic Bass Drum'],
      snare => ['Acoustic Snare'],     # 38
      kick  => ['Acoustic Bass Drum'], # 35
      tick  => ['Closed Hi-Hat'],
      hhat  => ['Closed Hi-Hat',  # 42
                'Open Hi-Hat',    # 46
                'Pedal Hi-Hat',   # 44
      ],
      crash => ['Chinese Cymbal', # 52
                'Crash Cymbal 1', # 49
                'Crash Cymbal 2', # 57
                'Splash Cymbal',  # 55
      ],
      ride  => ['Ride Bell',      # 53
                'Ride Cymbal 1',  # 51
                'Ride Cymbal 2',  # 59
      ],
      tom   => ['High Tom',       # 50
                'Hi-Mid Tom',     # 48
                'Low-Mid Tom',    # 47
                'Low Tom',        # 45
                'High Floor Tom', # 43
                'Low Floor Tom',  # 41
      ],
  };
}

1;
__END__

=head1 NAME

MIDI::Simple::Drummer - Glorified metronome

=head1 ABSTRACT

Is there a drummer in the house?

=head1 SYNOPSIS

  # A glorified metronome:
  use MIDI::Simple::Drummer;
  my $d = MIDI::Simple::Drummer->new(-bpm => 100);
  $d->count_in;
  for(1 .. $d->phrases * $d->beats) {
    $d->note($d->EIGHTH, $d->backbeat_rhythm(-beat => $_));
    $d->note($d->EIGHTH, $d->tick);
  }

  # A smarter drummer:
  use MIDI::Simple::Drummer::Rock;
  $d = MIDI::Simple::Drummer::Rock->new(-bpm => 100);
  my($beat, $fill) = (0, 0);
  $d->count_in;
  for my $p (1 .. $d->phrases) {
    if($p % 2 > 0) {
        $beat = $d->beat(-name => 3, -fill => $fill);
    }
    else {
        $beat = $d->beat(-name => 4);
        $fill = $d->fill(-last => $fill);
    }
  }
  $d->patterns(fin => \&fin);
  $d->beat(-name => 'fin');
  $d->write;
  sub fin {
    my $d = shift;
    $d->note($d->EIGHTH, $d->option_strike;
    $d->note($d->EIGHTH, $d->strike('Splash Cymbal','Bass Drum 1'));
    $d->note($d->SIXTEENTH, $d->snare) for 0 .. 2;
    $d->rest($d->SIXTEENTH);
    $d->note($d->EIGHTH, $d->strike('Splash Cymbal','Bass Drum 1'));
  }

=head1 DESCRIPTION

This is a "robotic" drummer that 1) hides L<MIDI::Simple> details and
2) provides simple methods to construct beats.

This is not a "drum machine", that you control in any traditional
sense.  It is intended to be a "sufficiently intelligent" drummer,
with which you can practice, improvise, compose, record and
experiment.

These "beats" are entirely perl and any available method can be
used to generate the phrases - Stochastic, Evolutionary, L-system,
Recursive descent grammar, whatever.

Note that B<you>, the programmer, should know what the patterns and
kit elements are named and what they do.  For these, check out the
source of this package, the included style subclass(es), the F<eg/*>
files and the F<.mid> files they produce.

The default kit is the B<exciting>, general MIDI drumkit.  Fortunately,
you can import the F<.mid> file into your favorite sequencer and
assign better patches.  I<Voila!>

=head1 METHODS

=head2 new()

  my $d = MIDI::Simple::Drummer->new(%arguments);

Return a new C<MIDI::Simple::Drummer> instance with these arguments:

  # MIDI
  -channel => 9
  -volume  => 100
  # Rhythm
  -accent  => 30
  -bpm     => 120
  -phrases => 4
  -beats   => 4
  # The Goods[TM].
  -file     => Drummer.mid
  -kit      => Set by the API if not provided
  -patterns => Set by the API if not provided
  -score    => MIDI::Simple->new_score (Set by API...)

These arguments can be overridden with this constuctor or the
following accessor methods.

=head2 volume()

  $x = $d->volume;
  $x = $d->volume($y);

Return and set the volume.

=head2 bpm()

Beats per minute.

=head2 phrases()

Number of phrases to play.

=head2 beats()

Number of beats per measure.

=head2 channel()

MIDI channel.

=head2 file()

Name for the F<.mid> file to write.

=head2 patterns()

Return or set known style patterns.

=head2 score()

  $x = $d->score;
  $x = $d->score($y);
  $x = $d->score($y, 'V127');
  $x = $d->score($volume);

Return or set the L<MIDI::Simple/score> object if provided first.  If
there are any other arguments, they are set as score no-ops.

=head2 accent()

Either return the current volume plus the accent increment or set the
accent increment.  This has an upper limit of MIDI fff.

=head2 strike()

  $x = $d->strike;
  $x = $d->strike('Cowbell');
  $x = $d->strike('Cowbell','Tambourine');
  @x = $d->strike('Cowbell','Tambourine');

Return note values for percussion names from the standard MIDI
percussion set (with L<MIDI/notenum2percussion>) in either scalar or
list context. (Default predefined snare patch.)

=head2 option_strike()

  $x = $d->option_strike;
  $x = $d->option_strike('Short Guiro','Short Whistle','Vibraslap');

Return a note value from a list of patches (default predefined crash
cymbals).  If another set of patches is given, one of those is chosen
at random.

=head2 note()

  $d->note($d->SIXTEENTH, $d->snare);
  $d->note('sn', 'n38');

Add a note to the score.  This is a pass-through to
L<MIDI::Simple/n>.

=head2 rest()

  $d->rest($d->SIXTEENTH);
  $d->rest('sn');

Add a rest to the score.  This is a pass-through to
L<MIDI::Simple/r>.

=head2 no_op()

  $d->no_op('V127');

Add a no-op to the score.  This is a pass-through to
L<MIDI::Simple/noop>.

=head2 metronome()

  $d->metronome;
  $d->metronome('Mute Triangle');

Add beats * phases of the C<Pedal Hi-Hat>, unless another patch is
provided.

=head2 count_in()

  $d->count_in;
  $d->count_in(2);
  $d->count_in(1, 'Side Stick');

And a-one and a-two and a-one, two, three!E<lt>E<sol>Lawrence WelkE<gt>
..11E<lt>E<sol>FZE<gt>

If No arguments are provided, the C<Closed Hi-Hat> is used.

=head2 rotate()

  $x = $d->rotate;
  $x = $d->rotate(3);
  $x = $d->rotate(5, ['Mute Hi Conga','Open Hi Conga','Low Conga']);

Rotate through a list of patches according to the given beat number.
(Default backbeat patches.)

=head2 backbeat_rhythm()

  $x = $d->backbeat_rhythm;
  $x = $d->backbeat_rhythm(-beat => $y);
  $x = $d->backbeat_rhythm(-fill => $z);
  $x = $d->backbeat_rhythm(-patches => ['Cowbell','Hand Clap']);
  $x = $d->backbeat_rhythm(-backbeat => ['Bass Drum 1','Electric Snare']);
  $x = $d->backbeat_rhythm(-tick => ['Claves']);

Return the rotating C<backbeat> with either the C<tick> or an option
patch (default crashes), if it's the first beat and we just filled.

=head2 beat()

  $x = $d->beat;
  $x = $d->beat(-name => $n);
  $x = $d->beat(-last => $y);
  $x = $d->beat(-fill => $z);
  $x = $d->beat(-type => 'fill');

Play a beat type and return the id for the selected pattern.  Beats
and fills are both just patterns but drummers think of them as
distinct animals.

This method adds an anecdotal "beat" to the MIDI score.  You can
indicate that we filled in the previous bar, and do something exciting
like crash on the first beat, by supplying the C<-fill =E<gt> $z>
argument, where C<$z> is the fill we just played.  Similarly, the
C<-last =E<gt> $y> argument indicates that C<$y> is the last beat we
played, so that we can maintain "context sensitivity."

Unless specifically given a pattern to play with the C<-name> argument,
we try to play something different each time, so if the pattern is the
same as the C<-last>, or if there is no given pattern to play, another
is chosen.

For C<-type =E<gt> 'fill'>, we append a named fill to the MIDI score.

=head2 fill()

This is an alias to the C<beat> method with
C<-type =E<gt> 'fill'> added.

=head2 patterns()

  $x = $d->patterns;
  $x = $d->patterns('rock_1');
  @x = $d->patterns(paraflamaramadiddle => \&code, 'foo fill' => \&foo_fill);

Return or set the code references to the named patterns.  If no
argument is given, all the known patterns are returned.

=head2 write()

  $x = $d->write;
  $x = $d->write('Buddy-Rich.mid');

This is an alias for L<MIDI::Simple/write_score> but with
unimaginably intelligent bits.  It returns the name of the written
file if successful.  If no filename is given, we use the preset
C<-file> attribute.

=head1 KIT ACCESS

=head2 kit()

  $x = $d->kit;
  $x = $d->kit('snare');
  @x = $d->kit( clapsnare => ['Handclap','Electric Snare'],
                kickstick => ['Bass Drum 1','Side Stick']);
  @x = $d->kit('clapsnare');

Return or set part or all of the percussion set.

=head2 name_of()

  $x = $d->name_of('kick'); # "Acoustic Bass Drum"
  @x = $d->name_of('crash'); # ('Chinese Cymbal', 'Crash Cymbal 1...)

Return the instrument names behind the kit nick-name lists.

=head2 hhat()

    $x = $d->hhat;
    $x = $d->hhat('Cabasa','Maracas','Claves');

Strike or set the "hhat" patches.  By default, these are the
C<Closed Hi-Hat>, C<Open Hi-Hat> and the C<Pedal Hi-Hat.>

=head2 crash()

    $x = $d->crash;
    $x = $d->crash(@crashes);

Strike or set the "crash" patches.  By default, these are the
C<Chinese Cymbal>, C<Crash Cymbal 1>, C<Crash Cymbal 2> and the
C<Splash Cymbal.>

=head2 ride()

    $x = $d->ride;
    $x = $d->ride(@rides);

Strike or set the "ride" patches.  By default, these are the
C<Ride Bell>, C<Ride Cymbal 1> and the C<Ride Cymbal 2.>

=head2 tom()

    $x = $d->tom;
    $x = $d->tom('Low Conga','Mute Hi Conga','Open Hi Conga');

Strike or set the "tom" patches.  By default, these are the
C<High Tom>, C<Hi-Mid Tom>, etc.

=head2 kick()

    $x = $d->kick;
    $x = $d->kick('Bass Drum 1');

Strike or set the "kick" patch.  By default, this is the
C<Acoustic Bass Drum>.

=head2 tick()

    $x = $d->tick;
    $x = $d->tick('Mute Triangle');

Strike or set the "tick" patch.  By default, this is the
C<Closed Hi-Hat>.

=head2 snare()

    $x = $d->snare;
    $x = $d->snare('Electric Snare');

Strike or set the "snare" patches.  By default, this is the
C<Acoustic Snare.>

=head2 backbeat()

    $x = $d->backbeat;
    $x = $d->backbeat('Bass Drum 1','Side Stick');

Strike or set the "backbeat" patches.  By default, these are the
predefined C<kick> and C<snare> patches.

=head1 CONVENIENCE METHODS

These are meant to avoid literal strings and the need to remember
and type the relevant MIDI variables.

=head2 WHOLE

  $x = $d->WHOLE;

Return C<'wn'>.

=head2 HALF

Return C<'hn'>.

=head2 QUARTER

Return C<'qn'>.

=head2 EIGHTH

Return C<'en'>.

=head2 SIXTEENTH

Return C<'sn'>.

=head2 _p2n()

Return C<%MIDI::percussion2notenum> a la L<MIDI/GOODIES>.

=head2 _n2p()

Return the inverse: C<%MIDI::notenum2percussion>.

=head2 _default_patterns()

Patterns provided by default. This is C<{}>, that is, nothing.

=head2 _default_kit()

Kit provided by default. This is a subset of the general MIDI kit.

=head1 TO DO

* It don't mean a thing if it ain't got that swing. (That is, make a
<MIDI::Simple::Drummer::Jazz> package.)

* Add 32nd and 64th durations to C<%MIDI::Simple::Length>.

* Comprehend time signature via beat construction and keep a "running
clock/total" to know where we are in time, at all times.

* Intelligently modulate dynamics - "add nuance" like accent and
crescendo, etc.

* Praise Les Paul and Multi-track ASAP.

* Import patterns via L<MIDI::Simple/read_score>?

* Leverage L<MIDI::Tab/from_drum_tab>?

=head1 SEE ALSO

The F<eg/*> and F<t/*> files, that come with this distribution.

L<MIDI::Simple::Drummer::API>

The I<MIDI::Simple::Drummer::*> style package(s).

L<MIDI::Simple> itself.

L<http://maps.google.com/maps?q=mike+avery+joplin> - my drum teacher.

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2010, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it under
the same terms as Perl itself.

=cut
