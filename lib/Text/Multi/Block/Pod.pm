package Text::Multi::Block::Pod;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: Pod.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Text::Multi::Block );
use Pod::Xhtml;

__PACKAGE__->mk_group_accessors( inherited => qw(
    make_index top_heading top_links link_parser
) );

sub MakeIndex; *MakeIndex = \&make_index;
sub TopHeading; *TopHeading = \&top_heading;
sub TopLinks; *TopLinks = \&top_links;
sub LinkParser; *LinkParser = \&link_parser;

sub as_html {
    my ( $self ) = @_;

    my %args = (
        StringMode      => 1,
        FragmentOnly    => 1,
    );
    for my $x (qw( TopHeading TopLinks MakeIndex LinkParser )) {
        my $val = $self->$x();
        if ( defined $val ) { $args{ $x } = $val }
    }
    my $helper = bless( {
        lines => [ split( "\n", $self->content ) ],
        count => 0,
    }, 'Text::Multi::Block::Pod::Helper' );

    return Pod::Xhtml->new( %args )->parse_from_filehandle( $helper )->asString;
}

package # hide from PAUSE
    Text::Multi::Block::Pod::Helper;

sub getline { return $_[0]->{ 'lines' }->[ $_[0]->{ 'count' }++ ]; }

1;
__END__

=head1 NAME

Text::Multi::Block::Markdown - Text::Multi processor for Markdown blocks

=head1 SYNOPSIS

  {{{ Markdown }}}

=head1 DESCRIPTION

This subclass of L<Text::Multi::Block> uses L<Text::Markdown> to process
Markdown formatted text into HTML.  For more information on Markdown's
syntax, see L<http://daringfireball.net/projects/markdown/>.

=head1 PARAMETERS

These are parameters that can be set in the L<Text::Multi> tag in your
text document, to provide additional information to formatter modules, and
potentially to influence how the content is rendered.  Also see
L<Text::Multi::Block/PARAMETERS> for inherited parameters that can be used
by this formatter.

=head2 make_index (MakeIndex)

=head2 top_heading (TopHeading)

=head2 top_links (TopLinks)

=head2 link_parser (LinkParser)

=head1 INTERNAL METHODS

=head2 as_html()

See L<Text::Multi::Block/as_html>.

=head1 SEE ALSO

L<Text::Multi>

L<Text::Multi::Block>

L<Text::Markdown>

L<http://daringfireball.net/projects/markdown/>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 AUTHOR

Jason Kohles C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

