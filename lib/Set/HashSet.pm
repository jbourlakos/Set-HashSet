package Set::HashSet;

use 5.032000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Set::HashSet ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = (
    'all' => [
        qw(

        )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(

);

our $VERSION = '0.01';

package Set:HashSet;

use Moose;
use MooseX::Types::Moose qw(HashRef);

use Clone qw();
use Scalar::Util qw( reftype blessed );

# attributes

has 'map' => (
    is       => 'ro',
    isa      => 'HashRef',
    builder  => '_build_map',
    clearer  => '_clear_map',
    init_arg => undef,
    lazy     => 1,
    required => 1,
);

# public methods

sub clone {
    my ($self) = @_;
    return Clone::clone($self);
}

sub contains {
    my ( $self, $value ) = @_;

    # on purpose, hide the internal value
    my $result = $self->map->{$value} ? 1 : 0;
    return $result;
}

sub delete {

    # alias to: _delete_multiple
    goto \&_delete_multiple;
}

sub difference {
    my ( $self, $other_set ) = @_;
    my $other_elements = $self->_resolve_elements_for_operation($other_set);
    return $self->_delete_multiple(@$other_elements);
}

sub elements {
    goto \&to_array;
}

sub insert {

    # alias to: _insert_multiple
    goto \&_insert_multiple;
}

sub intersection {
    my ( $self, $other_set ) = @_;

    # keep elements from other set if they appear in this set
    my $other_elements   = $self->_resolve_elements_for_operation($other_set);
    my @elements_to_keep = grep { $self->contains($_) } @$other_elements;

    # reset the map and keep the proper elements
    $self->_clear_map;
    return $self->_insert_multiple(@elements_to_keep);
}

sub size {
    my ($self) = @_;
    my $map = $self->map;
    return scalar( grep { $map->{$_} } keys(%$map) );
}

sub union {
    my ( $self, $other_set ) = @_;
    my $other_elements = $self->_resolve_elements_for_operation($other_set);
    return $self->_insert_multiple(@$other_elements);
}

sub to_array {
    my ($self) = @_;
    my $map = $self->map;
    return wantarray ? keys(%$map) : [ keys(%$map) ];
}

sub to_hash {
    my ($self) = @_;
    my $map_copy = Clone::clone( $self->map );
    return wantarray ? %$map_copy : $map_copy;
}

# private methods

sub _build_map {
    return {};
}

sub _delete_multiple {
    my ( $self, @elements ) = @_;
    for my $value (@elements) {
        $self->_delete_scalar($value);
    }
    return $self;
}

sub _delete_scalar {
    my ( $self, $value ) = @_;
    my $map = $self->map;
    if ( reftype($value) ) {
        param_exception('Deleting references is not supported');
    }
    delete $map->{$value};
    return 1;
}

sub _insert_multiple {
    my ( $self, @elements ) = @_;
    for my $value (@elements) {
        $self->_insert_scalar($value);
    }
    return $self;
}

sub _insert_scalar {
    my ( $self, $value ) = @_;
    if ( reftype($value) ) {
        param_exception('Inserting references is not supported');
    }
    $self->map->{$value} = 1;
    return 1;
}

sub _resolve_elements_for_operation {
    my ( $self, $other_set ) = @_;
    my $other_reftype   = reftype($other_set);
    my $other_blesstype = blessed($other_set);
    my @other_elements;
    if ( !$other_reftype || $other_reftype eq 'SCALAR' ) {
        param_exception('Union of scalar is not supported');
    }
    elsif ( $other_reftype eq 'ARRAY' ) {
        @other_elements = @$other_set;
    }
    elsif ( $other_reftype eq 'HASH' && !$other_blesstype ) {
        @other_elements = keys(%$other_set);
    }
    elsif ( $other_reftype eq 'HASH' && $other_blesstype eq __PACKAGE__ ) {
        @other_elements = $other_set->elements;
    }
    else {
        param_exception(
            "Invalid parameter ref: $other_reftype, blessed: $other_blesstype");
    }
    return \@other_elements;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Set::HashSet - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Set::HashSet;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Set::HashSet, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Ioannis Bourlakos, E<lt>jbourlakos@(none)E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 by Ioannis Bourlakos

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.32.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
