package MIDI::Simple::Drummer::Rock;
our $VERSION = '0.01';
use strict;
use warnings;
use base 'MIDI::Simple::Drummer';

# "Quater-note beat" Qn tick. Cym on 1. Kick 1&3. Snare 2&4.
sub _quarter {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. $self->beats) {
        $self->note($self->QUARTER,
            $self->rotate($beat, $args{-rotate}),
            $self->strike($args{-key_patch})
        );
    }
}

# Common eighth-note based grooves with kick syncopation.
sub _eighth {
    my $self = shift;
    my %args = @_;
    for my $beat (1 .. $self->beats) {
        # Lay-down a back-beat rhythm.
        $self->note($self->EIGHTH,
            $self->backbeat_rhythm(%args, -beat => $beat)
        );
        # Add another kick or tick if we're at the right beat.
        $self->note($self->EIGHTH,
            ((grep { $beat == $_ } @{$args{-key_beat}})
                ? ($self->kick, $self->tick) : $self->tick)
        ) if $args{-key_beat} && @{$args{-key_beat}};
    }
}

sub _default_patterns {
    my $self = shift;
    return {

1.1 => sub {
    my $self = shift;
    my %args = (-key_patch => 'Closed Hi-Hat', @_);
    $self->_quarter(%args);
},
1.2 => sub {
    my $self = shift;
    my %args = (-key_patch => 'Ride Bell', @_);
    $self->_quarter(%args);
},
1.3 => sub {
    my $self = shift;
    my %args = (-key_patch => 'Ride Cymbal 2', @_);
    $self->_quarter(%args);
},

2.1 => sub { # "Basic rock beat" en c-hh. qn k1,3. qn s2,4. Crash after fill.
    my $self = shift;
    my %args = (-key_beat => [0], @_);
    $self->_eighth(%args);
},
2.2 => sub { # "Main beat" en c-hh. qn k1,3,3&. qn s2,4.
    my $self = shift;
    my %args = (-key_beat => [3], @_);
    $self->_eighth(%args);
},
2.3 => sub { # "Syncopated beat 1" en c-hh. qn k1,3,4&. qn s2,4.
    my $self = shift;
    my %args = (-key_beat => [4], @_);
    $self->_eighth(%args);
},
2.4 => sub { # "Syncopated beat 2" en c-hh. qn k1,3,3&,4&. qn s2,4.
    my $self = shift;
    my %args = (-key_beat => [3, 4], @_);
    $self->_eighth(%args);
},

# XXX These fills all suck.
'1 fill' => sub {
    my $self = shift;
    $self->note($self->QUARTER, $self->snare) for 0 .. 1;
    $self->note($self->EIGHTH, $self->snare) for 0 .. 3;
},
'2 fill' => sub {
    my $self = shift;
    $self->note($self->EIGHTH, $self->snare) for 0 .. 1;
    $self->rest($self->EIGHTH);
    $self->note($self->EIGHTH, $self->snare);
    $self->note($self->QUARTER, $self->snare) for 0 .. 1;
},
'3 fill' => sub {
    my $self = shift;
    $self->note($self->EIGHTH, $self->snare) for 0 .. 1;
    $self->rest($self->EIGHTH);
    $self->note($self->EIGHTH, $self->snare) for 0 .. 2;
    $self->rest($self->EIGHTH);
    $self->note($self->EIGHTH, $self->snare);
},
'4 fill' => sub {
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

This package contains a collection of patterns, loaded by
L<MIDI::Simple::Drummer>.

=head1 METHODS

=head2 _default_patterns()

  my $patterns = $self->_default_patterns();

Return a hash-reference of named code-references, that define the
patterns we can play.

=head1 TO DO

* Make cooler fills, Man.

=head1 SEE ALSO

L<MIDI::Simple::Drummer>

=head1 AUTHOR AND COPYRIGHT

Gene Boggs E<lt>gene@cpan.orgE<gt>

Copyright 2010, Gene Boggs, All Rights Reserved.

=head1 LICENSE

This program is free software; you can redistribute or modify it
under the same terms as Perl itself.

=cut
