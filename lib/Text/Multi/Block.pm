package Text::Multi::Block;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: Block.pm 6 2008-01-22 17:21:02Z jason $';
use base qw( Class::Accessor::Grouped );
use Class::Inspector ();
use File::ShareDir qw( module_dir );
use Path::Class qw( file );
use Carp::Clan qw( ^Text::Multi:: ^Text::Multi croak );

__PACKAGE__->mk_group_accessors( simple => qw( content section ) );
__PACKAGE__->mk_group_accessors( inherited => qw(
    wrap_element trim
) );
__PACKAGE__->wrap_element( 'div' );
__PACKAGE__->trim( 1 );

sub type {
    my ( $self ) = @_;

    my $class = ref( $self ) || $self;
    my $pkg = __PACKAGE__;
    $class =~ s/^${pkg}:://;
    return $class;
}

sub new {
    my $self = bless( { content => '' }, shift() );
    my %args = @_;
    for my $key ( keys %args ) { $self->$key( $args{ $key } ) }
    return $self;
}

sub detail_comment { return "<!-- ".shift->content." -->\n" }

sub wrap_content {
    my ( $self, $content ) = @_;

    return '' unless $content;

    my @classes = $self->wrap_classes;
    my $elem = $self->wrap_element;
    return qq{<$elem class="@classes">\n$content\n</$elem>\n};
}

sub css_my_class {
    my ( $self, @extra ) = @_;

    my $class = ref( $self ) || $self;
    $class =~ s/^Text::Multi::Block:://;
    $class =~ s/::/-/g;
    return lc( join( '-', 'text-multi', $class, @extra ) );
}

sub wrap_classes {
    my ( $self ) = @_;

    return ( 'text-multi', $self->css_my_class );
}

sub render {
    my ( $self ) = @_;

    if ( my $output = $self->as_html() ) {
        return $self->wrap_content( $output );
    } else {
        return '';
    }
}

sub as_html { }

#sub block_dir {
#    my ( $self ) = @_;
#
#    my $name = __PACKAGE__.'.pm';
#    $name =~ s#::#/#g;
#    return dir( $INC{ $name } );
#}

sub block_file {
    my ( $self, @path ) = @_;

    my $name = ref( $self ) || $self;
    $name =~ s#::#/#g; $name .= ".pm";
    my $loc = $INC{ $name }; $loc =~ s/\.pm$//;

    if ( @path == 1 && $path[0] =~ /^\./ ) { $loc .= shift( @path ) }
    my $file = file( $loc, @path );
    if ( -e $file ) { return $file }
}

sub css_file {
    my ( $self ) = @_;

    return $self->block_file( '.css' );
}

sub css_inline {
    my ( $self ) = @_;

    my $file = $self->css_file || return '';
    return $file->slurp;
}

1;
__END__

=head1 NAME

Text::Multi::Block - Text::Multi BlockType superclass

=head1 SYNOPSIS

  package Text::Multi::Block::Foo;
  use strict;
  use warnings;
  use base qw( Text::Multi::Block );
  use Text::Foo;
  
  sub as_html { Text::Foo::transform( shift->content ) }

=head1 DESCRIPTION

This module serves as a base class for L<Text::Multi|Text::Multi> block
classes.  L<Text::Multi|Text::Multi> formats text using a variety of
formatters (as explained in it's documentation) and each of these
formatters is implemented as a subclass of
L<Text::Multi::Block|Text::Multi::Block>.  In most cases these subclasses are
simple wrappers around other, more complicated, text formatting modules.

=head1 PARAMETERS

These are parameters that can be set in the L<Text::Multi|Text::Multi> tag
in your text document, to provide additional information to formatter
modules, and potentially to influence how the content is rendered.

=head2 section

This is a superclass paramter, that can be passed to any block type in the
start tag.  This is a superclass parameter so that sections can be defined
for any type of block, and used to identify different sections for the
application.  For example, a blog application might use code like this to
indicate which block contains summary information.

  {{{ Markdown section=summary }}}
  
  This is the summary block to be displayed on the main page
  
  {{{ Markdown }}}
  
  This block contains text that will only be seen after you click the
  'Read More...' link on the main page.

=head2 trim( $value );

If set to a true value, any blank lines at the beginning or end of the
block will be removed prior to formatting.  This allows the source file
to contain extra whitespace for readability without having it affect the
output.  With this set to true (which is the default) these two source
documents are rendered identically.

  {{{ Markdown }}}
  Some Test here
  {{{ }}}

  {{{ Markdown }}}
  
  Some Test here
  
  {{{ }}}

=head1 METHODS

=head2 as_html

The as_html method is the only method that a L<Text::Multi::Block> subclass
is required to implement.  This method should take the content of the block
and return it rendered as HTML.  This method returns an empty string if not
overridden in the subclass.

=head2 type

This is a read-only method, which returns the block type.  It is mainly
useful in conjunction with L<Text::Multi/find_blocks>, for searching for
blocks of a specific type.

=head2 content

Returns the original, unprocessed contents of the block.

=head1 INTERNAL METHODS

These are methods you would not normally call on your own, as L<Text::Multi>
will take care of calling them during it's normal processing.  You do need
to know about these if you are writing subclasses of L<Text::Multi::Block>,
however.

=head2 new

Creates a new object.

=head2 detail_comment

Returns the comment that will be inserted at the beginning of the blocks
output when the 'detailed' option is set (see L<Text::Multi/detailed>).

=head2 wrap_content( $content );

Used by L</render>, this method Returns the text passed in wrapped in a
suitable HTML wrapper (see L</wrap_element> and L</wrap_classes> for how
to affect the rendering of the wrapper.)

The default is to wrap the content in a C<< <div> >> with the class
attribute set to the results of the L</wrap_classes> method.

=head2 wrap_classes();

Returns the CSS classes that should be applied to the L</wrap_element>
when L</wrap_content> is called.  By default this returns 'text-multi' and
'text-multi-C<< <blocktype> >>', although you may wish to override it to
add additional classes.  See L<Text::Multi::Block::Code> for an example of
a class that overrides it.

=head2 block_file( $filename );

This method returns the path (as a L<Path::Class::File> object) to a file
associated with this module.  The file distribution is fairly simplistic,
supporting files are simply installed into @INC alongside the modules they
support.  If C<$filename> begins with a dot, it is assumed to be an extension,
and the file with that extension that is found alongside the class will be
returned.  If C<$filename> does not begin with a dot, then it is assumed
it will be found in a subdirectory named after the block class.

For example, for the L<Text::Multi::Block::Code>, if Code.pm is installed in
C<$PERL/Text/Multi/Block/Code.pm>, then C<block_file( '.css' )> would return
C<$PERL/Text/Multi/Block/Code.css> and C<block_file( 'support.txt' )> would
return C<$PERL/Text/Multi/Block/Code/support.txt>.

=head2 css_file();

Returns the CSS file associated with this block type.

=head2 css_inline();

Returns the contents of the CSS file associated with this block type.

=head2 css_my_class( @extra );

Returns an appropriately formatted CSS class for this block type.  If any
arguments are passed, they are added to the end of the class name, separated
by dashes.

Examples:

  # returns text-multi-code
  Text::Multi::Block::Code->css_my_class();
  
  # returns text-multi-code-perl
  Text::Multi::Block::Code->css_my_class( 'perl' );

=head2 render();

Renders the content of the block as HTML and returns it.

=head1 SEE ALSO

L<Text::Multi>

L<http://www.jasonkohles.com/software/Text-Multi/>.

=head1 AUTHOR

Jason Kohles, C<< <email@jasonkohles.com> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Jason Kohles

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

