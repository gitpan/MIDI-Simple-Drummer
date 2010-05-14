package MIDI::Simple::Drummer::Rock;
our $VERSION = '0.00_03';
use strict;
use warnings;
use base 'MIDI::Simple::Drummer';

sub _default_patterns {
    my $self = shift;
    return {
        # Beats:
        rock_1 => sub {
            # Quater-note beat: Qn tick. Cym on 1. Kick on 1&3. Snare on 2&4.
            my $self = shift;
            my %args = (
                -patches => [
                    'Closed Hi-Hat',
                    'Ride Bell',
                    'Ride Cymbal 2',
#                    'Tambourine', # Maybe...
#                    'Cowbell', # Maybe not.
                ],
                @_
            );
            for my $beat (1 .. $self->beats) {
                $self->note($self->QUARTER,
                    $self->rotate($beat, $args{-rotate}),
                    $self->option_strike(@{$args{-patches}})
                );
            }
        },
        rock_2 => sub { # Basic rock beat: en c-hh. qn k1,3. qn s2,4. Crash after fill.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->beats) {
                $self->note($self->EIGHTH, $self->backbeat_rhythm(%args, -beat => $beat));
                $self->note($self->EIGHTH, $self->tick);
            }
        },
        rock_3 => sub { # Main beat: en c-hh. qn k1,3,3&. qn s2,4.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->beats) {
                $self->note($self->EIGHTH, $self->backbeat_rhythm(%args, -beat => $beat));
                $self->note($self->EIGHTH,
($beat == 3 ? ($self->kick, $self->tick) : $self->tick)
                );
            }
        },
        rock_4 => sub { # Syncopated beat 1: en c-hh. qn k1,3,4&. qn s2,4.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->beats) {
                $self->note($self->EIGHTH, $self->backbeat_rhythm(%args, -beat => $beat));
                $self->note($self->EIGHTH,
($beat == 4 ? ($self->kick, $self->tick) : $self->tick)
                );
            }
        },
        rock_5 => sub { # Syncopated beat 2: en c-hh. qn k1,3,3&,4&. qn s2,4.
            my $self = shift;
            my %args = @_;
            for my $beat (1 .. $self->beats) {
                $self->note($self->EIGHTH, $self->backbeat_rhythm(%args, -beat => $beat));
                $self->note($self->EIGHTH,
($beat == 3 || $beat == 4 ? ($self->kick, $self->tick) : $self->tick)
                );
            }
        },
        # Fills:
        'snare_1 fill' => sub {
            my $self = shift;
            $self->note($self->QUARTER, $self->snare) for 0 .. 1;
            $self->note($self->EIGHTH, $self->snare) for 0 .. 3;
        },
        'snare_2 fill' => sub {
            my $self = shift;
            $self->note($self->EIGHTH, $self->snare) for 0 .. 1;
            $self->rest($self->EIGHTH);
            $self->note($self->EIGHTH, $self->snare);
            $self->note($self->QUARTER, $self->snare) for 0 .. 1;
        },
        'snare_3 fill' => sub {
            my $self = shift;
            $self->note($self->EIGHTH, $self->snare) for 0 .. 1;
            $self->rest($self->EIGHTH);
            $self->note($self->EIGHTH, $self->snare) for 0 .. 2;
            $self->rest($self->EIGHTH);
            $self->note($self->EIGHTH, $self->snare);
        },
        'snare_4 fill' => sub {
            my $self = shift;
            $self->note($self->QUARTER, $self->snare) for 0 .. 1;
            $self->note($self->SIXTEENTH, $self->snare) for 0 .. 3;
            $self->note($self->QUARTER, $self->snare);
        },
    };
}

1;
__END__

=head1 NAME

MIDI::Simple::Drummer::Rock - Rock drum grooves

=head1 DESCRIPTION

This package contains a kit and collection of patterns, loaded by
L<MIDI::Simple::Drummer>.

=head1 FUNCTIONS

=head2 _default_kit()

  my $kit = $self->_default_kit();

This bit is here for illustration purposes.  This module inherits the
default "General MIDI kit" from the parent.

=head2 _default_patterns()

  my $patterns = $self->_default_patterns();

Return a hash-reference of named code-references, that define the
"style" we are playing.

=head1 SEE ALSO

L<MIDI::Simple::Drummer>

L<MIDI::Simple::Drummer::API>

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2010, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it under
the same terms as Perl itself.

=cut
