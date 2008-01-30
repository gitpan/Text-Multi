package Text::Multi::Block::Trac;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: Trac.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Text::Multi::Block );
use Text::Trac ();

my @formatter_arguments = qw(
    trac_url
    trac_attachment_url trac_changeset_url trac_log_url trac_milestone_url
    trac_report_url trac_source_url trac_ticket_url trac_wiki_url
    enable_links disable_links
);
__PACKAGE__->mk_group_accessors( inherited => @formatter_arguments );

sub as_html {
    my ( $self ) = @_;

    my %opts = ();
    for my $opt ( @formatter_arguments ) {
        my $val = $self->$opt();
        if ( defined $val ) { $opts{ $opt } = $val }
    }
    return Text::Trac->new( %opts )->parse( $self->content )->html;
}

1;
__END__

=head1 NAME

Text::Multi::Block::Trac - Text::Multi processor for Trac blocks

=head1 SYNOPSIS

  {{{ Trac }}}

=head1 DESCRIPTION

This subclass of L<Text::Multi::Block> uses L<Text::Trac> to process
Trac formatted text into HTML.  For more information on Trac's
syntax, see L<http://projects.edgewall.com/trac/wiki/WikiFormatting>.

=head1 PARAMETERS

These are parameters that can be set in the L<Text::Multi|Text::Multi>
tag in your text document, to provide additional information to formatter
modules, and potentially to influence how the content is rendered.  Also see
L<Text::Multi::Block/PARAMETERS> for inherited parameters that can be used
by this formatter.

=head2 trac_url

Base URL for TracLinks.  See L<Text::Trac/trac_url>.

The URL for individual types of TracLinks can also be set, using
L<Text::Trac/trac_attachment_url>,
L<Text::Trac/trac_changeset_url>,
L<Text::Trac/trac_log_url>,
L<Text::Trac/trac_milestone_url>,
L<Text::Trac/trac_report_url>,
L<Text::Trac/trac_source_url>,
L<Text::Trac/trac_ticket_url>,
L<Text::Trac/trac_wiki_url>. See L<Text::Trac> for more details.

=head2 enable_links / disable_links

See L<Text::Trac/enable_links> and L<Text::Trac/disable_links>.

=head1 INTERNAL METHODS

=head2 as_html()

See L<Text::Multi::Block/as_html>.

=head1 SEE ALSO

L<Text::Multi>

L<Text::Multi::Block>

L<Text::Trac>

L<http://www.edgewall.com/trac/>

L<http://projects.edgewall.com/trac/wiki/WikiFormatting>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 AUTHOR

Jason Kohles C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

