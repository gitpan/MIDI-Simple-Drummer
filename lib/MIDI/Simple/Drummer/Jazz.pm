package MIDI::Simple::Drummer::Jazz;
our $VERSION = '0.01';
use strict;
use warnings;
use base 'MIDI::Simple::Drummer';

sub _setup {
    my $self = shift;
    $self->SUPER::_setup(@_);
    $self->swing(1); # XXX Naive
}

sub _default_patterns {
    my $self = shift;
    return {

1 => sub { # Basic swing with no kick or snare.
    my $self = shift;
    for my $beat (1 .. $self->beats) {
        $self->note($self->TRIPLET_8TH, $self->ride1);
        $self->rest($self->TRIPLET_8TH) for 0 .. 1;
        $self->note($self->TRIPLET_8TH, $self->pedal, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->ride1);
    }
},

2 => sub { # Syncopated swing with kick and snare.
    my $self = shift;
    for my $beat (1 .. $self->beats) {
        $self->note($self->TRIPLET_8TH, $self->kick, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->snare);

        $self->note($self->TRIPLET_8TH, $self->snare, $self->pedal, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->kick, $self->ride1);

        $self->note($self->TRIPLET_8TH, $self->snare, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->kick);

        $self->note($self->TRIPLET_8TH, $self->kick, $self->pedal, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->snare, $self->ride1);
    }
},

3 => sub { # Syncopated swing with kick and snare.
    my $self = shift;
    for my $beat (1 .. $self->beats) {
        $self->note($self->TRIPLET_8TH, $self->pedal, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->snare);

        $self->note($self->TRIPLET_8TH, $self->snare, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->pedal, $self->ride1);

        $self->note($self->TRIPLET_8TH, $self->snare, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->pedal);

        $self->note($self->TRIPLET_8TH, $self->kick, $self->pedal, $self->ride1);
        $self->rest($self->TRIPLET_8TH);
        $self->note($self->TRIPLET_8TH, $self->snare, $self->ride1);
    }
},

'1 fill' => sub {
    my $self = shift;
    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->rest($self->TRIPLET_8TH);
    $self->note($self->TRIPLET_8TH, $self->snare);

    $self->note($self->_8TH, $self->snare) for 0 .. 1;
},

'2 fill' => sub {
    my $self = shift;
    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->rest($self->TRIPLET_8TH);
    $self->note($self->TRIPLET_8TH, $self->snare);

    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->rest($self->TRIPLET_8TH);
    $self->note($self->TRIPLET_8TH, $self->snare);

    $self->note($self->_8TH, $self->snare) for 0 .. 1;
},

'3 fill' => sub { # Ala Buddy
    my $self = shift;
    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->note($self->TRIPLET_8TH, $self->kick);
    $self->note($self->TRIPLET_8TH, $self->snare);

    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->note($self->TRIPLET_8TH, $self->kick) for 0 .. 1;


    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->note($self->TRIPLET_8TH, $self->kick) for 0 .. 1;

    $self->note($self->TRIPLET_8TH, $self->snare);
    $self->note($self->TRIPLET_8TH, $self->kick) for 0 .. 1;
},

    };
}

# Kit access
sub _default_kit {
    my $self = shift;
    return {
        %{ $self->SUPER::_default_kit() },
        ride1 => ['Ride Cymbal 1'],
        ride2 => ['Ride Cymbal 2'],
        bell  => ['Ride Bell'],
        pedal => ['Pedal Hi-Hat'],
    }
}
sub ride1 { return shift->_set_get('ride1', @_) }
sub ride2 { return shift->_set_get('ride2', @_) }
sub bell  { return shift->_set_get('bell', @_) }
sub pedal { return shift->_set_get('pedal', @_) }

1;
__END__

=head1 NAME

MIDI::Simple::Drummer::Jazz - Jazz drum grooves

=head1 DESCRIPTION

This package contains a collection of patterns, loaded by
L<MIDI::Simple::Drummer>.

=head1 METHODS

=head2 _default_kit()

  my $kit = $self->_default_kit();

Return a hash-reference of named code-references, that define the
patches we can play.

=head2 _default_patterns()

  my $patterns = $self->_default_patterns();

Return a hash-reference of named code-references, that define the
patterns we can play.

=head2 ride1(), ride2(), bell()

Strike (or set) the rides, individually.  By default, these are the
kit rides.  Imagine that!

=head2 pedal()

"Depress" the pedal hi-hat.

=head1 SEE ALSO

L<MIDI::Simple::Drummer>

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2010, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it
under the same terms as Perl itself.

=cut
