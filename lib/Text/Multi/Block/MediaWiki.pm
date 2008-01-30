package Text::Multi::Block::MediaWiki;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: MediaWiki.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Text::Multi::Block );
use Text::MediaWikiFormat ();

sub as_html { Text::MediaWikiFormat::format( shift->content ) }

1;
__END__

=head1 NAME

Text::Multi::Block::MediaWiki - Text::Multi processor for MediaWiki blocks

=head1 SYNOPSIS

  {{{ MediaWiki }}}

=head1 DESCRIPTION

This subclass of L<Text::Multi::Block> uses L<Text::MediaWikiFormat> to
process MediaWiki formatted text into HTML.  For more information on MediaWiki
syntax, see L<http://en.wikipedia.org/wiki/Help:Contents/Editing_Wikipedia>.

=head1 PARAMETERS

These are parameters that can be set in the L<Text::Multi> tag in your
text document, to provide additional information to formatter modules, and
potentially to influence how the content is rendered.  Also see
L<Text::Multi::Block/PARAMETERS> for inherited parameters that can be used
by this formatter.

=head1 INTERNAL METHODS

=head2 as_html()

See L<Text::Multi::Block/as_html>.

=head1 SEE ALSO

L<Text::Multi>

L<Text::Multi::Block>

L<Text::MediaWikiFormat>

L<http://en.wikipedia.org/wiki/Help:Contents/Editing_Wikipedia>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 AUTHOR

Jason Kohles C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

