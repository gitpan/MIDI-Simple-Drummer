package MIDI::Simple::Drummer;
our $VERSION = '0.00_18';
use strict;
use warnings;
use MIDI::Simple;

sub new { # Is there a drummer in the house?
    my $class = shift;
    my $self  = {
        # MIDI
        -channel => '9',
        -volume => '100',
        # Rhythm
        -style => 'Rock',
        -accent => 30, # Volume increment
        -bpm => 120,
        -phrases => 4, # Also equals measures
        -beats => 4, # Beats per measure
        # The Goods[TM].
        -file => 'Drummer.mid',
        -kit => undef,
        -patterns => undef,
        -score => undef,
        @_
    };
    bless $self, ref($class) || $class;
    $self->_setup;
    return $self;
}

sub _setup { # Where's my Roadies, Man?
    my $self = shift;

    # See if we have something to play.
    my $style = 'MIDI::Simple::Drummer::' . $self->{-style};
    eval "require $style";
    for my $m (qw(kit patterns)) {
        next if $self->{'-'.$m};
        my $s = eval sprintf('%s::%s()', $style, $m);
        my $x = $self->_setting($m, %$s);
    }

    # Give unto us a blank score, onto which we can inscribe inscriptions.
    $self->score(MIDI::Simple->new_score); # XXX unless $self->score; ?
    $self->tempo(int(60_000_000 / $self->{-bpm}));
    $self->no_op('c'.$self->{-channel}, 'V'.$self->{-volume});
}

sub _n2p { return {%MIDI::notenum2percussion} } # Convenience functions.
sub _p2n { return {%MIDI::percussion2notenum} }

sub WHOLE {'wn'} # Readable durations.
sub HALF {'hn'}
sub QUARTER {'qn'}
sub EIGHTH {'en'}
sub SIXTEENTH {'sn'} # TODO THIRTYSECOND, SIXTYFOURTH

sub no_op { shift->{-score}->noop(@_) } # Score pass-throughs.
sub note  { shift->{-score}->n(@_) }
sub rest  { shift->{-score}->r(@_) }
sub tempo { shift->{-score}->set_tempo(@_) }

# Accessors.
sub channel { # I guess you could use a different instrument...
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
sub file { # The name of the file to write.
    my $self = shift;
    $self->{-file} = shift if @_;
    return $self->{-file}
}
sub score { # The MIDI::Simple score object.
    my $self = shift;
    $self->{-score} = shift if @_;
    return $self->{-score}
}
sub style { # TODO Set kit and patterns if asked.
    my $self = shift;
    $self->{-style} = shift if @_;
    return $self->{-style}
}
sub accent { # Accent a note.
    my $self = shift;
    $self->{-accent} = shift if @_;
    # Increase volume.
    my $accent = $self->{-volume} + $self->{-accent};
    $accent = $MIDI::Simple::Volume{fff}
        if $accent > $MIDI::Simple::Volume{fff};
    return $accent;
}
sub kit { # Arrayrefs of patches.
    my $self = shift;
    return $self->_setting('kit', @_);
}
sub patterns { # Coderefs of patterns.
    my $self = shift;
    return $self->_setting('patterns', @_);
}

# XXX This is a frightfully stupid design:
sub _set_get { # Kit access.
    my $self = shift;
    my $key = shift || return;
    my $option = shift || 0;
    $self->kit($key => [@_]) if @_;
    return $option
        ? $self->option_strike(@{$self->kit($key)})
        : $self->strike(@{$self->kit($key)});
}
sub backbeat { return shift->_set_get(backbeat => 0, @_) }
sub snare    { return shift->_set_get(snare => 1, @_) }
sub kick     { return shift->_set_get(kick => 1, @_) }
sub tick     { return shift->_set_get(tick => 1, @_) }
sub hhat     { return shift->_set_get(hhat => 1, @_) }
sub crash    { return shift->_set_get(crash => 1, @_) }
sub ride     { return shift->_set_get(ride => 1, @_) }
sub tom      { return shift->_set_get(tom => 1, @_) }

sub strike { # Return note values.
    my $self = shift;
    my @patches = @_ ? @_ : @{$self->kit('snare')};
    my @notes = map { 'n' . $MIDI::percussion2notenum{$_} } @patches;
    return wantarray ? @notes : join(',', @notes);
}
sub option_strike { # When in doubt, crash.
    my $self = shift;
    my @patches = @_ ? @_ : @{$self->kit('crash')};
    return $self->strike($patches[int(rand @patches)]);
}

# Compositional tools.
sub rotate { # Rotate through a list of patches. Default backbeat.
    my $self = shift;
    my $beat = shift || 1;
    my $patches = shift || $self->kit('backbeat');
    return $self->strike($patches->[$beat % @$patches]);
}
sub rotate_backbeat { # Rotate the backbeat, tick and post-fill option strike.
    my $self = shift;
    my %args = (
        -beat => 1,
        -fill => 0,
        -backbeat => scalar $self->kit('backbeat'),
        -tick => scalar $self->kit('tick'),
        -options => scalar $self->kit('crash'),
        @_
    );
    my $c = $args{-beat} == 1 && $args{-fill}
        ? $self->option_strike(@{$args{-options}}) : $self->strike(@{$args{-tick}});
    my $n = $self->rotate($args{-beat}, $args{-backbeat});
    return wantarray ? ($n, $c) : join(',', $n, $c);
}

sub count_in {
    my $self = shift;
    my $bars = shift || 1;
    my $strike = @_ ? $self->strike(@_) : $self->tick;
    my $accent = $self->accent;
    for my $i (1 .. $self->{-beats} * $bars) {
        $self->no_op('V'.$accent) if $i % $self->{-beats} == 1;
        $self->note(QUARTER(), $strike);
        $self->no_op('V'.$self->{-volume}) if $i % $self->{-beats} == 1;
    }
    return $strike;
}
sub metronome {
    my $self = shift;
    return $self->count_in($self->{-phrases}, shift || 'Pedal Hi-Hat');
}

# XXX This is a frightfully stupid design:
sub _setting {
    my $self = shift;
    my $type = '-' . shift || return;
    if(!@_) {
        # Return all known types if no arguments.
        return $self->{$type};
    }
    elsif(@_ == 1) {
        # Return the named type.
        my $p = shift;
        return wantarray
            ? ($p => $self->{$type}{$p})
            :        $self->{$type}{$p};
    }
    elsif(@_ > 1) {
        # Add new type(s) to our collection.
        my %args = @_;
        my @p = ();
        while(my($p, $v) = each %args) {
            $self->{$type}{$p} = $v;
            push @p, $p;
        }
        # Return the named type(s).
        return wantarray
            ? (map { $_ => $self->{$type}{$_} } @p) # Hash of named types.
            : @p > 1
                ? [map { $self->{$type}{$_} } @p]   # Arrayref of types.
                : $self->{$type}{$p[0]};            # Single type.
    }
}

sub beat { # Pattern selector method.
    my $self = shift;
    my %args = (
        -name => 0,
        -fill => 0,
        -last => 0,
        -type => '',
        @_
    );

    # Get the names of the known patterns.
    my @k = ref($self->{-patterns}) eq 'HASH'
          ? keys %{$self->{-patterns}}
          : undef;
    # Bail out if there are none.
    return undef unless @k;

    # Do we want a certain type that isn't already in the given name?
    my $n = $args{-name} && $args{-type} && $args{-name} !~ /^.+\s+$args{-type}$/
          ? "$args{-name} $args{-type}"
          : $args{-name};

    # Return the only pattern if there is only one.
    if(@k == 1) {
        $n = $k[0];
    }
    else {
        # Otherwise choose a different pattern.
        while($n eq 0 || $n eq $args{-last}) {
            # TODO Allow custom method of "randomization?"
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
    return -e $self->{-file} ? $file : 0;
}

1;
__END__

=head1 NAME

MIDI::Simple::Drummer - Glorified Metronome

=head1 ABSTRACT

Is there a drummer in the house?

=head1 SYNOPSIS

  use MIDI::Simple::Drummer;
  my $d = MIDI::Simple::Drummer->new(-bpm => 100);

  # A glorified metronome:
  $d->count_in;
  for(1 .. $d->phrases * $d->beats) {
    $d->note($d->EIGHTH, $d->rotate_backbeat(-beat => $_));
    $d->note($d->EIGHTH, $d->tick);
  }

  # A smarter drummer:
  my($beat, $fill) = (0, 0);
  $d->count_in;
  for my $p (1 .. $d->phrases) {
    if($p % 2 > 0) {
        $beat = $d->beat(-name => 'rock_3', -fill => $fill);
    }
    else {
        $beat = $d->beat(-name => 'rock_4');
        $fill = $d->fill(-last => $fill);
    }
  }
  $d->pattern(fin => \&fin);
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

This module is embroyonic but may yet grow into a giant reptilian
monster that smashes Tokyo.

Until then, this is a robotic drummer that hides L<MIDI::Simple>
details.  It is B<not> a "drum machine", that you program with verbose
or arcane syntax.  Rather, it is a "sufficiently intelligent" drummer
(if that's not a contradiction of terms!B<E<lt>sting!E<gt>>) with which you can
practice and improvise.

Also, since these "patterns" are entirely perl, any available method
can be used to generate the phrases: stochastic, evolutionary,
l-system, recursive descent grammar, whatever.

Note that B<you>, the programmer, should know what the patterns and
kit elements are named and what they do. For these, check out the
included style(s), e.g. L<MIDI::Simple::Drummer::Rock>.

The default kit is the B<exciting>, general MIDI drumkit.  Fortunately,
you can import the C<.mid> file into your favorite sequencer and
assign better patches.  Voila!

=head1 METHODS

=head2 * new()

  my $d = MIDI::Simple::Drummer->new(%arguments);

Far away in a distant galaxy... But nevermind that, Luke: use The
Source.

Currently, the accepted => default attributes are:

  # MIDI settings.
  -channel => '9',
  -volume => '100',
  # Rhythm metrics.
  -accent => 30, # Volume increment
  -bpm => 120,
  -phrases => 4,
  -beats => 4,
  # The Goods[TM].
  -kit => _rock_kit(),
  -patterns => _rock_patterns(),
  -file => 'Drummer.mid',
  -score => MIDI::Simple->new_score(),

These can all be overridden with the constuctor or accessors.

=head2 * volume()

  $x = $d->volume;
  $x = $d->volume($y);

Return or set the volume.

=head2 * bpm()

  $x = $d->bpm;
  $d->bpm($x);

Return or set the beats per minute.

=head2 * phrases()

  $x = $d->phrases;
  $d->phrases($x);

Return or set the number of phrases to play.

=head2 * beats()

  $x = $d->beats;
  $d->beats($x);

Return or set the number of beats per measure.

=head2 * score()

  $x = $d->score;
  $d->score($x);

Return or set the L<MIDI::Simple/score> object.

=head2 * channel()

  $x = $d->channel;
  $d->channel($x);

=head2 * file()

  $x = $d->file;
  $d->file($x);

=head2 * patterns()

  $x = $d->patterns;
  $d->patterns($x);

=head2 * style()

  $x = $d->style;
  $d->style($x);

=head2 * tempo()

  $x = $d->tempo;
  $d->tempo($x);

=head2 * accent()

  $x = $d->accent;
  $x = $d->accent($y);

Either return the current volume plus the accent increment or set the
accent increment.

=head2 * strike()

  $x = $d->strike;
  $x = $d->strike('Cowbell');
  $x = $d->strike('Cowbell','Tambourine');
  @x = $d->strike('Cowbell','Tambourine');

Return note values for percussion names from the standard MIDI
percussion set (with L<MIDI/notenum2percussion>) in either scalar or
list context. (Default predefined snare patch.)

=head2 * option_strike()

  $x = $d->option_strike;
  $x = $d->option_strike('Short Guiro','Short Whistle','Vibraslap');

Return a note value from a list of patches (default predefined crash
cymbals).  If another set of patches is given, one of those is chosen
at random.

=head2 * note()

  $d->note($d->SIXTEENTH, $d->snare);
  $d->note('sn', 'n38');

Add a note to the score.  This is a pass-through to
L<MIDI::Simple/n>.

=head2 * rest()

  $d->rest($d->SIXTEENTH);
  $d->rest('sn');

Add a rest to the score.  This is a pass-through to
L<MIDI::Simple/r>.

=head2 * no_op()

  $d->no_op('V127');

Add a no-op to the score.  This is a pass-through to
L<MIDI::Simple/noop>.

=head2 * metronome()

  $d->metronome;
  $d->metronome('Mute Triangle');

Add beats * phases of the C<Pedal Hi-Hat>, unless another patch is
provided.

=head2 * count_in()

  $d->count_in;
  $d->count_in(2);
  $d->count_in(1, 'Side Stick');

And a-one and a-two and a-one, two, three!E<lt>E<sol>Lawrence WelkE<gt>
..11E<lt>E<sol>FZE<gt>

If No arguments are provided, the C<Closed Hi-Hat> is used.

=head2 * rotate()

  $x = $d->rotate;
  $x = $d->rotate(3);
  $x = $d->rotate(5, ['Mute Hi Conga','Open Hi Conga','Low Conga']);

Rotate through a list of patches according to the given beat number.
(Default backbeat patches.)

=head2 * rotate_backbeat()

  $x = $d->rotate_backbeat;
  $x = $d->rotate_backbeat(-beat => $y);
  $x = $d->rotate_backbeat(-fill => $z);
  $x = $d->rotate_backbeat(-options => ['Cowbell','Hand Clap']);
  $x = $d->rotate_backbeat(-backbeat => ['Bass Drum 1','Electric Snare']);
  $x = $d->rotate_backbeat(-tick => ['Claves']);

Return the rotating C<backbeat> with either the C<tick> or an option
patch.  If the beat given is the first, a post-fill option strike is
made.

=head2 * beat()

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

=head2 * fill()

This is an alias to the C<beat> method with
C<-type =E<gt> 'fill'> added.

=head2 * pattern()

  $x = $d->pattern;
  $x = $d->pattern('rock_1');
  @x = $d->pattern(paraflamaramadiddle => \&code, 'foo fill' => \&foo_fill);

Return or set the code reference(s) to the named pattern(s).  If no
argument is given, all the known patterns are returned.

=head2 * write()

  $x = $d->write;
  $x = $d->write('Buddy-Rich.mid');

This is an alias for L<MIDI::Simple/write_score> but with
unimaginably intelligent bits.  It returns the name of the written
file if successful.  If no filename is given, we use the preset
C<-file> attribute.

=head1 KIT ACCESS

=head2 * kit()

  $x = $d->kit;
  $x = $d->kit('snare');
  @x = $d->kit( clapsnare => ['Handclap','Electric Snare'],
                kickstick => ['Bass Drum 1','Side Stick']);
  @x = $d->kit('clapsnare');

Return or set part or all of the percussion set.

=head2 * hhat()

    $x = $d->hhat;
    $x = $d->hhat('Cabasa','Maracas','Claves');

Strike or set the "hhat" patches.  By default, these are the
C<Closed Hi-Hat>, C<Open Hi-Hat> and the C<Pedal Hi-Hat.>

=head2 * crash()

    $x = $d->crash;
    $x = $d->crash(@crashes);

Strike or set the "crash" patches.  By default, these are the
C<Chinese Cymbal>, C<Crash Cymbal 1>, C<Crash Cymbal 2> and the
C<Splash Cymbal.>

=head2 * ride()

    $x = $d->ride;
    $x = $d->ride(@rides);

Strike or set the "ride" patches.  By default, these are the
C<Ride Bell>, C<Ride Cymbal 1> and the C<Ride Cymbal 2.>

=head2 * tom()

    $x = $d->tom;
    $x = $d->tom('Low Conga','Mute Hi Conga','Open Hi Conga');

Strike or set the "tom" patches.  By default, these are the
C<High Tom>, C<Hi-Mid Tom>, etc.

=head2 * kick()

    $x = $d->kick;
    $x = $d->kick('Bass Drum 1');

Strike or set the "kick" patch.  By default, this is the
C<Acoustic Bass Drum>.

=head2 * tick()

    $x = $d->tick;
    $x = $d->tick('Mute Triangle');

Strike or set the "tick" patch.  By default, this is the
C<Closed Hi-Hat>.

=head2 * snare()

    $x = $d->snare;
    $x = $d->snare('Electric Snare');

Strike or set the "snare" patches.  By default, this is the
C<Acoustic Snare.>

=head2 * backbeat()

    $x = $d->backbeat;
    $x = $d->backbeat('Bass Drum 1','Side Stick');

Strike or set the "backbeat" patches.  By default, these are the
predefined C<kick> and C<snare> patches.

=head1 CONVENIENCE METHODS

These are meant to avoid literal strings and the need to remember
and type the relevant MIDI variables.

=head2 * WHOLE

  $x = $d->WHOLE;

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

=head1 TO DO

* It don't mean a thing if it ain't got that swing.

* Intelligently modulate dynamics (i.e. "add nuance" like accent or
crescendo).

* Add 32nd and 64th durations to C<%MIDI::Simple::Length.>

* Comprehend time signature via beat construction and as a "running
total" to know where you are in time, at all times.

* Possibly load patterns automatically with C<qw(:rock)> syntax, in
the C<use> line.

* Import patterns via L<MIDI::Simple/read_score>, maybe.

* Possibly leverage L<MIDI::Tab/from_drum_tab>.

=head1 SEE ALSO

The F<eg/*> and F<t/*> files, that come with this distribution.

The C<MIDI::Simple::Drummer::*> style package(s).

L<MIDI::Simple> itself.

L<http://maps.google.com/maps?q=mike+avery+joplin> - my drum teacher.

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2010, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it under
the same terms as Perl itself.

=cut
