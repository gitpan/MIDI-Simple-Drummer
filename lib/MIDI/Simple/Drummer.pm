package MIDI::Simple::Drummer;
our $VERSION = '0.00_14';
use strict;
use warnings;
use MIDI::Simple;

sub new {
    my $class = shift;
    my $self  = {
        # Rhythm metrics.
        -bpm => 120,
        -phrases => 4,
        -beats => 4,
        # MIDI settings.
        -channel => '9',
        -volume => '100',
        # The Goods[TM].
        -patterns => undef,
        -kit => undef,
        -file => 'Drummer.mid',
        -score => MIDI::Simple->new_score(),
        @_
    };
    bless $self, $class;
    $self->_setup();
    return $self;
}

sub _setup { # Where's my Roadies, Man?
    my $self = shift;
    if($self->{-kit}) {
        $self->kit($self->{-kit});
    }
    else {
        $self->kit($self->_rock_kit);
    }
    if($self->{-patterns}) {
        $self->pattern($self->{-patterns});
    }
    else {
        $self->pattern($self->_rock_patterns);
    }
    $self->{-score}->set_tempo(int(60_000_000 / $self->{-bpm}));
    $self->{-score}->noop('c'.$self->{-channel}, 'V'.$self->{-volume});
}

sub WHOLE {'wn'} # Note values.
sub HALF {'hn'}
sub QUARTER {'qn'}
sub EIGHTH {'en'}
sub SIXTEENTH {'sn'} # XXX THIRTYSECOND, SIXTYFOURTH ?

sub _n2p { return {%MIDI::notenum2percussion} }
sub _p2n { return {%MIDI::percussion2notenum} }

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

sub score { # The MIDI::Simple score object.
    my $self = shift;
    $self->{-score} = shift if @_;
    return $self->{-score}
}

sub note { # Add a note to the score.
    my $self = shift;
    $self->{-score}->n(@_);
}

sub rest { # Add a rest to the score.
    my $self = shift;
    $self->{-score}->r(@_);
}

sub strike { # Return note values.
    my $self = shift;
    my @patches = @_ ? @_ : @{$self->kit('snare')};
    my @notes = map { 'n' . $MIDI::percussion2notenum{$_} } @patches;
    return wantarray ? @notes : join(',', @notes);
}
sub option_strike { # When in doubt, crash.
    my $self = shift;
    my @patches = @_ ? @_ : @{$self->kit('crash')};
    return $self->strike($patches[rand(@patches)]);
}

sub snare { # Kit access.
    my $self = shift;
    $self->kit(snare => shift) if @_;
    return $self->option_strike(@{$self->kit('snare')});
}
sub kick {
    my $self = shift;
    $self->kit(kick => shift) if @_;
    return $self->option_strike(@{$self->kit('kick')});
}
sub tick {
    my $self = shift;
    $self->kit(tick => shift) if @_;
    return $self->option_strike(@{$self->kit('tick')});
}
sub kicktick {
    my $self = shift;
    $self->kit(kicktick => shift) if @_;
    return $self->strike(@{$self->kit('kicktick')});
}
sub backbeat {
    my $self = shift;
    $self->kit(backbeat => shift) if @_;
    return $self->strike(@{$self->kit('backbeat')});
}
sub hhat {
    my $self = shift;
    $self->kit(hhat => shift) if @_;
    return $self->option_strike(@{$self->kit('hhat')});
}
sub crash {
    my $self = shift;
    $self->kit(crash => shift) if @_;
    return $self->option_strike(@{$self->kit('crash')});
}
sub ride {
    my $self = shift;
    $self->kit(ride => shift) if @_;
    return $self->option_strike(@{$self->kit('ride')});
}
sub tom {
    my $self = shift;
    $self->kit(tom => shift) if @_;
    return $self->option_strike(@{$self->kit('tom')});
}

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
        -backbeat => $self->kit('backbeat'),
        -tick => $self->kit('tick'),
        -options => $self->kit('crash'),
        @_
    );
    my $c = $args{-beat} == 1 && $args{-fill}
        ? $self->option_strike(@{$args{-options}}) : $self->strike(@{$args{-tick}});
    my $n = $self->rotate($args{-beat}, $args{-backbeat});
    return wantarray ? ($n, $c) : join(',', $n, $c);
}

sub count_in { # TODO Accent the 1s.
    my $self = shift;
    my $bars = shift || 1;
    my $strike = @_ ? $self->strike(shift) : $self->tick;
    $self->note(QUARTER(), $strike) for 1 .. $self->{-beats} * $bars;
    return $strike;
}
sub metronome {
    my $self = shift;
    return $self->count_in($self->{-phrases}, shift || 'Pedal Hi-Hat');
}

sub pattern { # Beats and fills and random flailing, etc.
    my $self = shift;
    # Return all known patterns if no arguments are given.
    return $self->{-patterns} unless @_;
    # Are we given a set of patterns to save?
    if(ref $_[0] eq 'HASH') {
        my $p = $_[0];
        while(my($k, $v) = each %$p) {
            $self->{-patterns}{$k} = $v;
        }
        return $self->{-patterns};
    }
    else {
        my $n = shift;
        # Do we want to save a pattern?
        my $v = shift;
        # Are we a particular type (like a fill)?
        my $type = @_ ? ' '. shift : '';
        $n .= $type;
        # Shovel it onto the pile.
        $self->{-patterns}{$n} = $v if $v && ref $v eq 'CODE';
        # Hand back the named pattern.
        return wantarray ? ($n => $self->{-patterns}{$n}) : $self->{-patterns}{$n};
    }
}

sub kit {
    my $self = shift;
    # Return the drumkit if no arguments are given.
    return $self->{-kit} unless @_;
    # Are we given a set of patches to save?
    if(ref $_[0] eq 'HASH') {
        my $kit = $_[0];
        while(my($k, $v) = each %$kit) {
            $self->{-kit}{$k} = $v;
        }
        return $self->{-kit};
    }
    else {
        my $n = shift;
        # Do we want to save a patch?
        my $v = shift;
        # Shovel it on.
        $self->{-kit}{$n} = $v if $v && ref $v eq 'ARRAY';
        # Hand back the patch(es).
        return $self->{-kit}{$n};
    }
}

sub beat { # Pattern selector method.
    my $self = shift;
    my %args = (
        -name => 0,
        -fill => 0,
        -last => 0,
        -pattern => undef,
        -type => '',
        @_
    );

    my $n = $args{-name} && $args{-type}
        ? "$args{-name} $args{-type}" : $args{-name};

    # Get the names of the known patterns.
    my @k = keys %{$self->{-patterns}};
    # Bail out if there are no patterns defined.
    return undef unless @k;
    # Return the only pattern if there is only one.
    if(@k == 1) {
        $n = $k[0];
    }
    else {
        # Otherwise choose a different pattern.
        while($n eq 0 || $n eq $args{-last}) {
            $n = $k[int(rand @k)];
            if($args{-type}) {
                (my $t = $n) =~ s/^.+\s+(\w+)$/$1/;
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

sub _rock_kit {
    return {
        hhat => [
            'Closed Hi-Hat', # 42
            'Open Hi-Hat', # 46
            'Pedal Hi-Hat', # 44
        ],
        crash => [
            'Chinese Cymbal', # 52
            'Crash Cymbal 1', # 49
            'Crash Cymbal 2', # 57
            'Splash Cymbal', # 55
        ],
        ride => [
            'Ride Bell', # 53
            'Ride Cymbal 1', # 51
            'Ride Cymbal 2', # 59
        ],
        tom => [
            'High Tom', # 50
            'Hi-Mid Tom', # 48
            'Low-Mid Tom', # 47
            'Low Tom', # 45
            'High Floor Tom', # 43
            'Low Floor Tom', # 41
        ],
        kick => ['Acoustic Bass Drum'], # 35
        tick => ['Closed Hi-Hat'], # 42
        kicktick => ['Acoustic Bass Drum', 'Closed Hi-Hat'],
        snare => ['Acoustic Snare'], # 38
        backbeat => ['Acoustic Snare', 'Acoustic Bass Drum'],
    };
}

sub _rock_patterns {
    my $self = shift;
    return {
        # Beats.
        rock_1 => sub { # Quater-note rock beat: qn cym. qn k on 1 & 3. qn s on 2 & 4.
            my $self = shift;
            my %args = @_;
            my $options = [
                'Closed Hi-Hat',
                'Ride Bell',
                'Ride Cymbal 2',
#                'Tambourine', # Maybe...
#                'Cowbell', # Maybe not.
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
        rock_2 => sub { # Basic rock beat: en c-hh. qn k1,3. qn s2,4. Crash after fill.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->{-beats}) {
                $self->note(EIGHTH(), $self->rotate_backbeat(%args, -beat => $beat));
                $self->note(EIGHTH(), $self->tick);
            }
        },
        rock_3 => sub { # Main rock beat: en c-hh. qn k1,3,3&. qn s2,4.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->{-beats}) {
                $self->note(EIGHTH(), $self->rotate_backbeat(%args, -beat => $beat));
                if($beat == 3) {
                    $self->note(EIGHTH(), $self->kicktick);
                }
                else {
                    $self->note(EIGHTH(), $self->tick);
                }
            }
        },
        rock_4 => sub { # Syncopated rock beat 1: en c-hh. qn k1,3,4&. qn s2,4.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->{-beats}) {
                $self->note(EIGHTH(), $self->rotate_backbeat(%args, -beat => $beat));
                if($beat == 4) {
                    $self->note(EIGHTH(), $self->kicktick);
                }
                else {
                    $self->note(EIGHTH(), $self->tick);
                }
            }
        },
        rock_5 => sub { # Syncopated rock beat 2: en c-hh. qn k1,3,3&,4&. qn s2,4.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->{-beats}) {
                $self->note(EIGHTH(), $self->rotate_backbeat(%args, -beat => $beat));
                if($beat == 3 || $beat == 4) {
                    $self->note(EIGHTH(), $self->kicktick);
                }
                else {
                    $self->note(EIGHTH(), $self->tick);
                }
            }
        },
        # Fills.
        'snare_1 fill' => sub {
            my $self = shift;
            $self->note(QUARTER(), $self->snare) for 0 .. 1;
            $self->note(EIGHTH(), $self->snare) for 0 .. 3;
        },
        'snare_2 fill' => sub {
            my $self = shift;
            $self->note(EIGHTH(), $self->snare) for 0 .. 1;
            $self->rest(EIGHTH());
            $self->note(EIGHTH(), $self->snare);
            $self->note(QUARTER(), $self->snare) for 0 .. 1;
        },
        'snare_3 fill' => sub {
            my $self = shift;
            $self->note(EIGHTH(), $self->snare) for 0 .. 1;
            $self->rest(EIGHTH());
            $self->note(EIGHTH(), $self->snare) for 0 .. 2;
            $self->rest(EIGHTH());
            $self->note(EIGHTH(), $self->snare);
        },
        'snare_4 fill' => sub {
            my $self = shift;
            $self->note(QUARTER(), $self->snare) for 0 .. 1;
            $self->note(SIXTEENTH(), $self->snare) for 0 .. 3;
            $self->note(QUARTER(), $self->snare);
        },
    };
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
  $d->pattern('fin', \&fin);
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

Until then, this is just meant to be a robotic drummer and hide the
L<MIDI::Simple> details.  It is B<not> a "drum machine", that you have
to "program" with some arcane specification syntax.  Rather, it will
evolve into a sufficiently intelligent drummer, that you can jam with.

Note that B<you>, the user, should know what the patterns are named
and what they do.  For this, see the L<MIDI::Simple::Drummer/pattern>
method.

Since we are talking about patterns (A.K.A. beats and fills), this is
entirely perl logic based, so you could use a Markov chain, stochastic
techniques or a L<Parse::RecDescent> grammar, even.

=head1 METHODS

=head2 * new()

  my $d = MIDI::Simple::Drummer->new(%arguments);

Far away in a distant galaxy... But nevermind that, Luke. Use The
Source.

Currently, the accepted attributes are:

  # Rhythm metrics:
  -bpm      => 120,
  -phrases  => 4,
  -beats    => 4,
  # MIDI settings:
  -channel  => '9',
  -volume   => '100',
  # The Goods[TM]:
  -patterns => undef,
  -kit      => undef,
  -file     => 'Drummer.mid',
  -score    => MIDI::Simple->new_score,

These can all be overridden by supplying them to the constuctor.

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

Add a note to the score.  This is just a pass-through to
L<MIDI::Simple/n>.

=head2 * rest()

  $d->rest($d->SIXTEENTH);
  $d->rest('sn');

Add a rest to the score.  This is just a pass-through to
L<MIDI::Simple/r>.

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
  $x = $d->beat(-name => $x);
  $x = $d->beat(-last => $x);
  $x = $d->beat(-fill => $x);
  $x = $d->beat(-type => 'fill');

Play a beat type and return the id for the selected pattern.  Beats
and fills are both just patterns but drummers think of them as
distinct animals.

This method adds an anecdotal "beat" to the MIDI score.  You can
indicate that we filled in the previous bar, and do something exciting
like crash on the first beat, by supplying the C<-fill =E<gt> $y>
argument, where C<$y> is the fill we just played.  Similarly, the
C<-last =E<gt> $z> argument indicates that C<$z> is the last beat we
played, so that we can maintain "context sensitivity."

Unless specifically given a pattern to play with the C<-name> argument,
we try to play something different each time, so if the pattern is the
same as the C<-last>, or if there is no given pattern to play, another
is chosen.

For C<-type =E<gt> 'fill'>, we append a drum-fill to the MIDI score.

=head2 * fill()

This is just a handy alias to the C<beat> method but with
C<-type =E<gt> 'fill'> added.

=head2 * pattern()

  $x = $d->pattern;
  $x = $d->pattern('foo');
  $x = $d->pattern(bar => \&bar);
  $x = $d->pattern('paraflamaramadiddle', \&code, 'fill');
  $x = $d->pattern(\%patterns);

Return the code reference to the named pattern(s).  If a second,
coderef argument is provided, the named pattern is assigned to it.
A third named argument can be supplied so that a type can be set or
selected.  C<-type =E<gt> 'fill'> to select a named fill.

If the argument is a single hash reference, each is added to the set
of known beats.

If no argument is given, all the known patterns are returned.

=head2 * write()

  $x = $d->write;
  $x = $d->write('Buddy-Rich.mid');

This is just an alias for L<MIDI::Simple/write_score> but with
unimaginably intelligent bits.  It returns the name of the written
file if successful.  If no filename is given, we use the preset
C<-file> attribute.

=head1 Kit Access

=head2 * kit()

  $x = $d->kit;
  $x = $d->kit('clank');
  $x = $d->kit(clunk => ['Foo','Bar']);
  $x = $d->kit(\%drumkit);

Return or set part or all of the percussion set.

=head2 * hhat()

    $x = $d->hhat;
    $x = $d->hhat(['Cabasa','Maracas','Claves']);

Strike or set the "hhat" patches.  By default, these are the
C<Closed Hi-Hat>, C<Open Hi-Hat> and the C<Pedal Hi-Hat.>

=head2 * crash()

    $x = $d->crash;
    $x = $d->crash(\@crashes);

Strike or set the "crash" patches.  By default, these are the
C<Chinese Cymbal>, C<Crash Cymbal 1>, C<Crash Cymbal 2> and the
C<Splash Cymbal.>

=head2 * ride()

    $x = $d->ride;
    $x = $d->ride(\@rides);

Strike or set the "ride" patches.  By default, these are the
C<Ride Bell>, C<Ride Cymbal 1> and the C<Ride Cymbal 2.>

=head2 * tom()

    $x = $d->tom;
    $x = $d->tom(['Low Conga','Mute Hi Conga','Open Hi Conga']);

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

=head2 * kicktick()

    $x = $d->kicktick;
    $x = $d->kicktick(['Bass Drum 1','Mute Triangle']);

Strike or set the "kicktick" patches.  By default, these are the
predefined C<kick> and C<tick> patches.

=head2 * snare()

    $x = $d->snare;
    $x = $d->snare('Electric Snare');

Strike or set the "snare" patches.  By default, this is the
C<Acoustic Snare.>

=head2 * backbeat()

    $x = $d->backbeat;
    $x = $d->backbeat(['Bass Drum 1','Side Stick']);

Strike or set the "backbeat" patches.  By default, these are the
predefined C<kick> and C<snare> patches.

=head1 CONVENIENCE METHODS

These are just meant to avoid literal strings and the need to remember
and type the relevant MIDI variables.

=head2 * WHOLE

  $d->WHOLE;

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

* Make any and all appropriate C<MIDI::Simple> parameters available
in the constructor.

* Intelligently modulate dynamics (i.e. "add nuance" like accent or
crescendo).

* Possibly load patterns automatically with C<qw(:rock)> syntax, in
the C<use> line.

* Import patterns via L<MIDI::Simple/read_score>, maybe.

* Leverage L<MIDI::Tab/from_drum_tab>, possibly.

=head1 SEE ALSO

The F<eg/*> and F<t/*> files, that come with this distribution.

L<MIDI::Simple> itself.

L<http://maps.google.com/maps?q=mike+avery+joplin> - my drum teacher.

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2009, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it under
the same terms as Perl itself.

=cut
