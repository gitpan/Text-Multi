package Text::Multi::Block::WikiCreole;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: WikiCreole.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Text::Multi::Block );
use Text::WikiCreole ();

sub as_html { Text::WikiCreole::creole_parse( shift->content ) }

1;
__END__

=head1 NAME

Text::Multi::Block::WikiCreole - Text::Multi processor for WikiCreole blocks

=head1 SYNOPSIS

  {{{ WikiCreole }}}

=head1 DESCRIPTION

This subclass of L<Text::Multi::Block> uses L<Text::WikiCreole> to process
WikiCreole formatted text into HTML.  For more information on WikiCreole
syntax, see L<http://www.wikicreole.org/>.

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

L<Text::WikiCreole>

L<http://www.wikicreole.org/>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 AUTHOR

Jason Kohles C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

