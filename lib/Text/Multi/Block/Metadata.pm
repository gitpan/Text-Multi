package Text::Multi::Block::Metadata;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: Metadata.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Text::Multi::Block );

__PACKAGE__->mk_group_accessors( simple => qw( data ) );
__PACKAGE__->mk_group_accessors( inherited => qw( hidden ) );
__PACKAGE__->hidden( 1 );
__PACKAGE__->wrap_element( 'table' );

sub get {
    my ( $self, $which ) = @_;

    if ( ! $self->data ) {
        my $data = {};
        for ( split( /\n/, $self->content ) ) {
            s/^\s*//; s/\s*$//;
            next unless $_;
            my ( $tag, $value ) = split( /\s*:\s*/, $_, 2 );
            $data->{ lc( $tag ) } = $value;
        }
        $self->data( $data );
    }
    if ( $which ) {
        return $self->data->{ lc( $which ) };
    } else {
        return $self->data;
    }
}

sub as_html {
    my ( $self ) = @_;

    return if $self->hidden;

    my $data = $self->data;

    my $output = '';
    for my $key ( keys %{ $data } ) {
        $output .= "<tr><th>$key</th><td>$data->{ $key }</td></tr>";
    }
    return $output;
}

1;
__END__

=head1 NAME

Text::Multi::Block::Metadata - Text::Multi processor for Metadata blocks

=head1 SYNOPSIS

  {{{ Metadata }}}
  Title: Some funky title
  Foo: Bar

=head1 DESCRIPTION

This subclass of L<Text::Multi::Block> implements a metadata information
block, which can provide additional information about the file to your
application.  The content of the block is assumed to be a simple email-header
like key/value format.  The content will be processed into a hash when
accessed.  By default the contents of a Metadata block are not displayed.

=head1 PARAMETERS

These are parameters that can be set in the L<Text::Multi> tag in your
text document, to provide additional information to formatter modules, and
potentially to influence how the content is rendered.  Also see
L<Text::Multi::Block/PARAMETERS> for inherited parameters that can be used
by this formatter.

=head2 hidden

Set to a false value to have the metadata rendered into the output as a
simple table, which you can style with CSS.

=head1 METHODS

=head2 get( $tag );

The get method provides access to the metadata content.  For example, if
your application defines a need for a 'Title' metadata element, you might
access it this way:

  my $tm = Text::Multi->new;
  $tm->process_file( 'myfile.txtm' );
  my ( $meta ) = $tm->find_blocks( type => 'Metadata' );
  my $title = $meta->get( 'title' );

The metadata header tags are not case-sensitive.

=head1 INTERNAL METHODS

=head2 as_html()

See L<Text::Multi::Block/as_html>.

=head1 SEE ALSO

L<Text::Multi>

L<Text::Multi::Block>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 AUTHOR

Jason Kohles C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

