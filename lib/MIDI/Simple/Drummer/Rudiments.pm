package MIDI::Simple::Drummer::Rudiments;
our $VERSION = '0.01_1';
use strict;
use warnings;
use base 'MIDI::Simple::Drummer';

=head1 NAME

MIDI::Simple::Drummer::Rudiments - Drum rudiments

=head1 SYNOPSIS

  use MIDI::Simple::Drummer::Rudiments;
  my $d = MIDI::Simple::Drummer::Rudiments->new;
  $d->count_in;
  $d->beat(-name => 1) for 1 .. $d->phrases;
  $d->write('single_stroke_roll.mid');

=head1 DESCRIPTION

This package contains a collection of patterns, loaded by
L<MIDI::Simple::Drummer>.

=head1 METHODS

=cut

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
    };
};

=head2 I. Roll Rudiments

=head3 A. Single Stroke Rudiments

1. Single Stroke Roll

=cut

sub single_stroke_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
        $self->pan($beat % 2 ? 1 : 127); # Pan each stroke hard-left and hard-right.
        $self->note($self->EIGHTH, $self->strike);
    }
}

=pod

2. Single Stroke Four

=cut

sub single_stroke_four {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}

=pod

3. Single Stroke Seven

=cut

sub single_stroke_seven {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}

=head3 B. Multiple Bounce Rudiments

4. Multiple Bounce Roll

=cut

sub multiple_bounce_roll {
    my $self = shift;
    for my $beat (1 .. $self->beats) {
    }
}

=pod

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

=cut

1;
__END__

=head1 TO DO

Tempo increase-decrease - continuous and discreet

With and without metronome

Straight or swing time

Panning amount

Touch velocity

=head1 SEE ALSO

L<MIDI::Simple::Drummer>

L<http://en.wikipedia.org/wiki/Drum_rudiment>

L<http://www.vicfirth.com/education/rudiments.php>

L<http://www.drumrudiments.com/>

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2012, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it
under the same terms as Perl itself.

=cut
