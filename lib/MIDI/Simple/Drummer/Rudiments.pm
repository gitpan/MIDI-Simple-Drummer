package MIDI::Simple::Drummer::Rudiments;
our $VERSION = '0.02';
use strict;
use warnings;
use base 'MIDI::Simple::Drummer';

use constant PAN_CENTER => 63;


sub _setup {
    my $self = shift;
    $self->SUPER::_setup(@_);
}

sub _default_patterns {
    my $self = shift;
    return {
        1  => \&single_stroke_roll,
        2  => \&single_stroke_four,
        3  => \&single_stroke_seven,
        4  => \&multiple_bounce_roll,
        5  => \&triple_stroke_roll,
        6  => \&double_stroke_open_roll,
        7  => \&five_stroke_roll,
        8  => \&six_stroke_roll,
        9  => \&seven_stroke_roll,
        10 => \&nine_stroke_roll,
        11 => \&ten_stroke_roll,
        12 => \&eleven_stroke_roll,
        13 => \&thirteen_stroke_roll,
        14 => \&fifteen_stroke_roll,
        15 => \&seventeen_stroke_roll,
        16 => \&single_paradiddle,
        17 => \&double_paradiddle,
        18 => \&triple_paradiddle,
        19 => \&paradiddle_diddle,
        20 => \&flam,
        21 => \&flam_accent,
        22 => \&flam_tap,
        23 => \&flamacue,
        24 => \&flam_paradiddle,
        25 => \&flammed_mill,
        26 => \&flam_paradiddle_diddle,
        27 => \&pataflafla,
        28 => \&swiss_army_triplet,
        29 => \&inverted_flam_tap,
        30 => \&flam_drag,
        31 => \&drag,
        32 => \&single_drag_tap,
        33 => \&double_drag_tap,
        34 => \&lesson_25_two_and_three,
        35 => \&single_dragadiddle,
        36 => \&drag_paradiddle_1,
        37 => \&drag_paradiddle_2,
        38 => \&single_ratamacue,
        39 => \&double_ratamacue,
        40 => \&triple_ratamacue,
    };
};

sub _groups_of {
    my ($beat, $group) = @_;
    return ($beat - 1) % $group;
}


sub single_stroke_roll {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. 8) {
        $self->alternate_pan($beat % 2, $args{pan_width});
        $self->note($self->THIRTYSECOND, $self->strike);
    }
}


sub single_stroke_four {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. 8) {
        $self->alternate_pan($beat % 2, $args{pan_width});
        if ($beat == 4 || $beat == 8) {
            $self->note($self->EIGHTH, $self->strike);
        }
        else {
            $self->note($self->TRIPLET_SIXTEENTH, $self->strike);
        }
    }
}


sub single_stroke_seven {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. 7) {
        $self->alternate_pan($beat % 2, $args{pan_width});
        if ($beat == 7) {
            $self->note($self->EIGHTH, $self->strike);
        }
        else {
            $self->note($self->TRIPLET_SIXTEENTH, $self->strike);
        }
    }
}


sub multiple_bounce_roll {
    my $self = shift;
    # TODO Set $multiple and then do a multi-stroke below.
}


sub triple_stroke_roll {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. 12) {
        # Pan after groups of three.
        $self->alternate_pan(_groups_of($beat, 3), $args{pan_width});
        $self->note($self->TRIPLET_SIXTEENTH, $self->strike);
    }
}


sub double_stroke_open_roll {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. 8) {
        # Pan after groups of two.
        $self->alternate_pan(_groups_of($beat, 2), $args{pan_width});
        $self->note($self->THIRTYSECOND, $self->strike);
    }
}


sub five_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub six_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub seven_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub nine_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub ten_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub eleven_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub thirteen_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub fifteen_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub seventeen_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub single_paradiddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub double_paradiddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub triple_paradiddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub paradiddle_diddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flam {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flam_accent {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flam_tap {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flamacue {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flam_paradiddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flammed_mill {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flam_paradiddle_diddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub pataflafla {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub swiss_army_triplet {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub inverted_flam_tap {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub flam_drag {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub drag {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub single_drag_tap {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub double_drag_tap {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub lesson_25_two_and_three {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub single_dragadiddle {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub drag_paradiddle_1 {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub drag_paradiddle_2 {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub single_ratamacue {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub double_ratamacue {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub triple_ratamacue {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}


sub pan_left {
    my ($self, $width) = @_;
    $self->pan(PAN_CENTER - $width);
}
sub pan_center {
    my ($self, $width) = @_;
    $self->pan(PAN_CENTER);
}
sub pan_right {
    my ($self, $width) = @_;
    $self->pan(PAN_CENTER + $width);
}



sub alternate_pan {
    my ($self, $pan, $width) = @_;
    # Pan hard left if not given.
    $pan = 0 unless defined $pan;
    # Set balance to 100% if necessary.
    $width = PAN_CENTER + 1 unless defined $width;
    # Pan the stereo balance.
    $self->pan( $pan ? abs($width - PAN_CENTER) : PAN_CENTER + $width );
    # Return the pan dimensions.
    return $pan, $width;
}

1;

__END__

=pod

=head1 NAME

MIDI::Simple::Drummer::Rudiments

=head1 VERSION

version 0.03

=head1 SYNOPSIS

  use MIDI::Simple::Drummer::Rudiments;
  my $d = MIDI::Simple::Drummer::Rudiments->new;
  $d->count_in;
  $d->beat(-name => 1) for 1 .. $d->phrases;
  $d->write('single_stroke_roll.mid');

=head1 DESCRIPTION

This package contains rudiment patterns.

=head1 NAME

MIDI::Simple::Drummer::Rudiments - Drum rudiments

=head1 METHODS

=head2 I. Roll Rudiments

=head3 A. Single Stroke Rudiments

1. Single Stroke Roll

2. Single Stroke Four

3. Single Stroke Seven

=head3 B. Multiple Bounce Rudiments

4. Multiple Bounce Roll

TODO: Not yet implemented...

5. Triple Stroke Roll

=head3 C. Double Stroke Rudiments

6. Double Stroke Open Roll

7. Five Stroke Roll

8. Six Stroke Roll

9. Seven Stroke Roll

10. Nine Stroke Roll

11. Ten Stroke Roll

12. Eleven Stroke Roll

13. Thirteen Stroke Roll

14. Fifteen Stroke Roll

15. Seventeen Stroke Roll

=head2 II. Diddle Rudiments

16. Single Paradiddle

17. Double Paradiddle

18. Triple Paradiddle

19. Paradiddle-Diddle

=head2 III. Flam Rudiments

20. Flam

21. Flam Accent

22. Flam Tap

23. Flamacue

24. Flam Paradiddle

25. Flammed Mill

26. Flam Paradiddle-Diddle

27. Pataflafla

28. Swiss Army Triplet

29. Inverted Flam Tap

30. Flam Drag

=head2 IV. Drag Rudiments

31. Drag

32. Single Drag Tap

33. Double Drag Tap

34. Lesson 25 (Two and Three)

35. Single Dragadiddle

36. Drag Paradiddle #1

37. Drag Paradiddle #2

38. Single Ratamacue

39. Double Ratamacue

40. Triple Ratamacue

=head2 pan_left() pan_center() pan_right()

 $d->pan_left($width);
 $d->pan_center();
 $d->pan_right($width);

Convenience methods to pan in different directions.

=head2 alternate_pan()

 $d->alternate_pan();
 $d->alternate_pan($direction);
 $d->alternate_pan($direction, $width);

Pan the stereo balance by an amount.

The pan B<direction> is B<0> for left (the default) and B<1> for right.

The B<width> can be any integer between B<1> and B<64> (the default).
A B<width> of B<64> means "stereo pan 100% left/right."

=head1 TO DO

Tempo increase-decrease

With and without metronome

Straight or swing time

Touch velocity

=head1 SEE ALSO

L<MIDI::Simple::Drummer>, the F<eg/> and F<t/> test scripts.

L<http://en.wikipedia.org/wiki/Drum_rudiment>

L<http://www.vicfirth.com/education/rudiments.php>

L<http://www.drumrudiments.com/>

=head1 AUTHOR

Gene Boggs <gene@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
