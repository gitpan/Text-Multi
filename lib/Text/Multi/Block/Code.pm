package Text::Multi::Block::Code;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: Code.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Text::Multi::Block );
use Syntax::Highlight::Engine::Kate;

__PACKAGE__->mk_group_accessors( inherited => qw(
    language starting_line_number tab_width line_number_pad
) );
__PACKAGE__->language( 'Perl' );
__PACKAGE__->starting_line_number( 0 );
__PACKAGE__->tab_width( 4 );
__PACKAGE__->wrap_element( 'pre' );

sub lang;
*lang = \&language;
sub line;
*line = \&starting_line_number;
sub tabwidth;
*tabwidth = \&tab_width;

my $format_table = {
    map { ( $_ => [ qq{<span class="$_">}, qq{</span>} ] ) } qw(
        Alert BaseN BString Char Comment DataType DecVal Error
        Float Function IString Keyword Normal Operator Others
        RegionMarker Reserved String Variable Warning
    )
};

sub as_html {
    my ( $self ) = @_;

    my $subs = {
        '<'     => '&lt;',
        '>'     => '&gt;',
        '&'     => '&amp;',
        ' '     => '&nbsp;',
        #"\n"    => "<br />\n",
    };

    if ( my $w = $self->tab_width ) { $subs->{ "\t" } = '&nbsp;' x $w }

    my $hl = Syntax::Highlight::Engine::Kate->new(
        language        => $self->lang,
        substitutions   => $subs,
        format_table    => $format_table,
    );

    my @content = split( "\n", $hl->highlightText( $self->content ) );
    if ( my $line = $self->starting_line_number ) {
        my $wide = length( $line + scalar( @content ) );
        my $lnl = qq{<span class="LineNo">};
        my $lnr = qq{</span>};
        for ( @content ) {
            my $x = ( '&nbsp;' x ( $wide - length( $line ) ) ).$line;
            
            s/^/${lnl}${x}${lnr}/;
            $line++;
        }
    }
    return join( "\n", @content );
}

sub wrap_classes {
    my ( $self ) = @_;

    return (
        $self->SUPER::wrap_classes, 
        $self->css_my_class( $self->lang ),
    );
}

1;
__END__

=head1 NAME

Text::Multi::Block::Code - Text::Multi processor for code blocks

=head1 SYNOPSIS

  {{{ Code lang=C<< <language> >> }}}

=head1 DESCRIPTION

This subclass of L<Text::Multi::Block|Text::Multi::Block> implements a
formatter for various types of source code using the
L<Syntax::Highlight::Engine::Kate|Syntax::Highlight::Engine::Kate> code
coloring library.

=head1 PARAMETERS

These are parameters that can be set in the L<Text::Multi|Text::Multi>
tag in your text document, to provide additional information to formatter
modules, and potentially to influence how the content is rendered.  Also see
L<Text::Multi::Block/PARAMETERS> for inherited parameters that can be used
by this formatter.

=head2 language

Sets the language that the code should be rendered as.  The language setting
affects things like what words are considered to be keywords.  See
L<Syntax::Highlight::Engine::Kate/PLUGINS> for a list of supported languages.

Use as a class method to set the default for all L<Text::Multi::Block::Code>
blocks.

  Text::Multi::Block::Code->language( 'Bash' );

The default value is 'Perl'.

=head2 lang

The 'language' parameter can also be abbreviated 'lang'.

=head2 starting_line_number( $number );

Set to a numeric value greater than 0 in order to include line numbers for
the code listing.  The value you set it to will be the number of the first
line.  When set to 0, line numbering will not be included.  The default value
0.

Use as a class method to set the default for all L<Text::Multi::Block::Code>
blocks.

  Text::Multi::Block::Code->starting_line_number( 1 );

=head2 line( $number );

The 'starting_line_number' parameter can also be abbreviated 'line'.

=head2 tab_width( $number );

Set to an integer value to indicate how many spaces a tab should be replaced
with (tabs are actually replaced with a series of '&nbsp;' entities, rather
than actual spaces.)

The default value is 4.  Use as a class method to set the default for all
L<Text::Multi::Block::Code> blocks.

  Text::Multi::Block::Code->tab_width( 8 );

=head2 tabwidth( $number );

The 'tab_width' parameter can also be abbreviated 'tabwidth'.

=head1 INTERNAL METHODS

=head2 as_html()

See L<Text::Multi::Block/as_html>.

=head2 wrap_classes()

This method is overloaded to return a class including the language being
rendered in addition to the values documented in
L<Text::Multi::Block/wrap_classes>.  For example, when language=perl, the
overloaded method adds 'text-multi-code-perl' to the list of classes
returned.

=head1 SEE ALSO

L<Text::Multi>

L<Text::Multi::Block>

L<Syntax::Highlight::Engine::Kate>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 AUTHOR

Jason Kohles C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

