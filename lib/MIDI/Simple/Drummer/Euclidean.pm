package MIDI::Simple::Drummer::Euclidean;
BEGIN {
  $MIDI::Simple::Drummer::Euclidean::AUTHORITY = 'cpan:GENE';
}
our $VERSION = '0.00_01';
use strict;
use warnings;
use parent 'MIDI::Simple::Drummer';

sub new {
    my $self = shift;
    $self->SUPER::new(
        -patch  => 25,
        -tr_808 => 0,
        @_
    );
    # Use the requested kit.
    if ($self->{-tr_808}) {
        $self->patch(26);
    }
}

sub _default_patterns {
    my $self = shift;
    return {

1 => \&euclid,

    };
}

sub euclid {
    my $self = shift;
    my ($m, $n) = @_;

    my $ones = 1 x $m;
    my $zeros = 0 x ($n - $m);

    if (@$n) {
        return euclid($n % $m, $m);
    }
    else {
        return $m;
    }
};

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

MIDI::Simple::Drummer::Euclidean

=head1 VERSION

version 0.0601

=head1 DESCRIPTION

Sadly, this module is but a stub.

=head1 NAME

MIDI::Simple::Drummer::Euclidean - Euclidean Rhythms

=head1 METHODS

=head2 euclid()

Thinking out loud. Work in progress...

=head1 SEE ALSO

L<MIDI::Simple::Drummer>, the F<eg/*> and F<t/*> scripts.

L<http://student.ulb.ac.be/~ptaslaki/publications/phdThesis-Perouz.pdf>

L<http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf>

L<http://www.ageofthewheel.com/2011/03/euclidean-rhythm-midi-file-resource-in.html>

=head1 AUTHOR

Gene Boggs <gene@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
