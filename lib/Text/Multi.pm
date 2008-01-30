package Text::Multi;
use strict;
use warnings;
our $VERSION = '0.01';
our $ID = '$Id: Multi.pm 9 2008-01-30 02:56:08Z jason $';
use Carp qw( croak );
use base qw( Class::Accessor::Grouped );
use Carp::Clan qw(^Text::Multi:: Text::Multi);

__PACKAGE__->mk_group_accessors( inherited => qw(
    default_type default_args block_type_map
) );
__PACKAGE__->mk_group_accessors( simple => qw( detailed blocks ) );

__PACKAGE__->default_type( 'Markdown' );
__PACKAGE__->default_args( {} );
__PACKAGE__->block_type_map( {} );

sub new {
    my $self = bless( {}, shift() );
    my %args = @_;
    for my $key ( keys %args ) { $self->$key( $args{ $key } ) }
    return $self;
}

sub import {
    my ( $self, @config ) = @_;

    while ( @config ) {
        my $block = shift( @config );
        my $conf = ref( $config[0] ) ? shift( @config ) : {};

        my $class = $self->block_class( $block );
        for my $key ( keys %{ $conf } ) {
            $class->$key( $conf->{ $key } );
        }
    }
}

sub process_file {
    my ( $self, $file ) = @_;

    open( my $fh, $file ) or croak "Cannot open $file: $!";
    $self->process_fh( $fh );
}

sub process_fh {
    my ( $self, $fh ) = @_;

    local $/;
    $self->make_blocks( <$fh> );
}

sub process_text {
    my ( $self, $text ) = @_;

    $self->make_blocks( $text );
}

sub render {
    my ( $self ) = @_;

    my $output = '';
    for my $block ( $self->get_blocks ) {
        if ( $self->detailed ) { $output .= $block->detail_comment }
        my $x = $block->render();
        if ( defined $x ) { $output .= $x }
    }
    return $output;
}

sub css_inline {
    my ( $self ) = @_;

    my %css = ();
    for my $block ( $self->get_blocks ) {
        next if exists $css{ ref( $block ) };
        $css{ ref( $block ) } = $block->css_inline;
    }
    return join( "\n", grep { $_ } values %css );
}

sub css_files {
    my ( $self ) = @_;

    my %css = ();
    for my $block ( $self->get_blocks ) {
        next if exists $css{ ref( $block ) };
        $css{ ref( $block ) } = $block->css_file;
    }
    return grep { $_ } values %css;
}

sub find_blocks {
    my ( $self, %args ) = @_;

    my @found = ();
    LOOP: for my $block ( $self->get_blocks ) {
        if ( %args ) {
            for my $key ( keys %args ) {
                next LOOP unless $block->$key eq $args{ $key };
            }
        }
        push( @found, $block );
    }

    return @found;
}

sub get_blocks {
    my ( $self ) = @_;

    if ( ! $self->{ 'blocks' } ) {
        die "Nothing loaded yet";
    }
    return @{ $self->{ 'blocks' } };
}

sub make_blocks {
    my ( $self, $text ) = @_;

    $text =~ s/\r//g;

    my @blocks = ();
    my @stack = ( [
        $self->block_class( $self->default_type ),
        $self->default_args,
    ] );

    my $current;
    my @parts = split( /^({{{.*?}}})$/sm, $text );
    for ( @parts ) {
        s/\A\n//;
        s/\n\z//;
        if ( /^{{{\s*(\w[\w:]*\w)\s*(.*?)\s*}}}$/ ) {
            push( @stack, [
                $self->block_class( $1 ),
                $self->make_meta( $2 ),
                $_,
            ] );
        } elsif ( /^{{{\s*}}}$/ ) {
            pop( @stack );
        } elsif ( /[^\s\n]/gsm ) {
            my ( $class, $args ) = @{ $stack[ $#stack ] };
            push( @blocks, $class->new( %{ $args || {} }, content => $_ ) );
        }
    }
    $self->{ 'blocks' } = \@blocks;
}

sub block_class {
    my ( $self, $type ) = @_;

    if ( $self->block_type_map->{ $type } ) {
        $type = $self->block_type_map->{ $type };
    }
    my $class;
    if ( $type =~ /^\+(.*?)$/ ) {
        $class = $1;
    } else {
        $class = join( '::', __PACKAGE__, 'Block', $type );
    }

    my $loaded = do {
        no strict 'refs';
        defined @{ $class . '::ISA' };
    };
    if ( not $loaded ) {
        eval "use $class";
        if ( $@ ) { croak "Could not load $class: $@" }
    }
    return $class;
}

sub make_meta {
    my ( $self, $text ) = @_;

    my $charmap = '\'\'""{}[]<>';
    my %charmap = split( '', $charmap );
    my $l_chars = join( '', keys %charmap );

    $text =~ s/\n/ /gsm;

    my $meta = {};
    while ( $text ) {
        $text =~ s/^\s*//; $text =~ s/\s*$//;
        if ( $text =~ s/^(\w+)\s*=\s*// ) {
            my $var = $1;
            if ( $text =~ /^([$l_chars])/ ) {
                my $lc = $1;
                my $rc = $charmap{ $lc };
                if ( $text =~ s/^$lc(.*?)$rc// ) {
                    $meta->{ $var } = $1;
                    next;
                }
            } elsif ( $text =~ s/^(\S+)// ) {
                $meta->{ $var } = $1;
                next;
            }
        }
        croak "Unable to parse meta: $text";
    }

    return $meta;
}

1;
__END__

=head1 NAME

Text::Multi - Transform a file containing a mixture of markup types into HTML

=head1 SYNOPSIS

  use Text::Multi;
  my $parser = Text::Multi->new(
    default_type => 'Markdown',
    detailed     => 1,
  );
  print $multi->render;

=head1 DESCRIPTION

This module formats text files that contain a mixture of different types of
text markup.  This allows, for example, for you to write a blog entry in
markdown, with sample code being formatted by an appropriate syntax-coloring
system.

Text::Multi itself only uses a single type of tag which indicates a change
in processor type.  It usually looks like this:

  {{{ BlockType }}}

or like this:

  {{{ BlockType param=option }}}

The first word is the type of block, and indicates the subclass of
L<Text::Multi::Block> that should be used to process the following section
of text.  Any parameters following the blocktype are optional, and the
options available depend on the processing module.  There are some options
common to all block processors, so check the documentation for
L<Text::Multi::Block> as well as for the individual subclasses.

You can also use a blank tag, like so:

  {{{ }}}

Any amount of whitespace in a blank tag is ignored.  A blank tag indicates
that the previous block is ending.  While processing a document, new tags
are kept on a stack so that as a block ends the previous block can continue.

An example would probably clarify that last paragraph.

  {{{ Markdown }}}
  
  Markdown text, describing the code that follows.
  
  {{{ Code lang=perl }}}
  #!/usr/bin/perl -w
  use strict;
  use warnings;
  # This is some dumb perl code
  print <<"END";
  {{{ Code lang=html }}}
  <html>
  <head>
  <title>HTML</title>
  </head>
  <body>
  This will be syntax-colored as HTML.
  </body>
  </html>
  {{{ }}}
  END
  # This is the end of the dumb perl code
  {{{ }}}

  This is more Markdown.

=head1 METHODS

=head2 new( %options );

Create a new L<Text::Multi> object.

=head2 import( $class, @configuration );

L<Text::Multi> defines an C<import()> method that accepts additional
configuration information both for itself and for the block types you
intend to use.  You can use it like this:

  use Text::Multi (
    { default_type => 'Code', detailed => 1 },
    'Code' => { starting_line_number => 1 },
  );

The configuration entries are processed according to these rules:

=over 4

=item 1.

If the first option is a hashref, it is C<shift()ed> off the array, and
the parameters it contains are used to configure L<Text::Multi> itself.

=item 2.

Each remaining element of the array is examined in turn.  If the value
is a scalar, it is assumed to contain a block type, and the corresponding
class will be loaded.  If the value is a hashref, it's parameters are used
to configure the preceding block type.

=back

For example, this C<use> line:

  use Text::Multi (
    { default_type => 'Code', detailed => 1 },
    'Code' => { starting_line_number => 1 },
    qw( Pod Metadata Markdown ),
  );

Is roughly equivalent to this code:

  use Text::Multi;
  Text::Multi->default_type( 'Code' );
  Text::Multi->detailed( 1 );
  use Text::Multi::Block::Code;
  Text::Multi::Block::Code->starting_line_number( 1 );
  use Text::Multi::Block::Pod;
  use Text::Multi::Block::Metadata;
  use Text::Multi::Block::Markdown;

=head2 default_type( $type );

Get or set a default block type.  This is used to determine what type of
block should be used for rendering any content that appears before the
first opening tag, or after the last closing tag.  For example...

  This text would be rendered using whatever the default_type type of
  block is.
  
  {{{ Markdown }}}
  
  This would be rendered as Markdown.
  
  {{{ }}}
  
  This is the default_type again.

You can think of the default_type as adding an implicit block around the
entire document.  If not specified, the default type is 'Markdown'.

=head2 default_args( $hashref );

For any content that is rendered using the default_type, this option
specifies any optional parameters to be used to configure the default object.

For example, this code would implicitly wrap the whole document in a default
C<{{{ Code starting_line_number=1 }}}> block.

  Text::Multi->default_type( 'Code' );
  Text::Multi->default_args( { starting_line_number => 1 } );

=head2 detailed( $value );

Get or set the value of the 'detailed' parameter.  If this is true then the
HTML output from render() will precede each rendered block with an HTML
comment containing the original text.  This is primarily a debugging
feature.

=head2 process_file( $filename );

Process the text in the provided filename.

=head2 process_fh( $filehandle );

Read the text to be processed from the provided filehandle.

=head2 process_text( $text );

Process the text contained in the provided scalar variable.

=head2 render();

The render method collects all the blocks from the source provided by
L</process_file>, L</process_fh>, or L</process_text> and returns the
formatted HTML.

=head2 css_inline();

Each L<Text::Multi::Block|block type> has the option to provide a CSS file
to be used in conjunction with the rendered HTML.  The css_inline method
collects the contents of these files for each block type used in the source
text, and returns them in a concatenated form, suitable for including in a
C<< <style> >> tag.

=head2 css_files();

Similar to L</css_inline>, this method returns the path to the css files
for each block type.

=head2 find_blocks( %params );

This method takes a hash of parameters, and returns as a list all the blocks
which have the parameters indicated.  For example, if called as

  my @blocks = $tm->find_blocks( type => 'Markdown', section => 'summary' )

Would return any block with a tag like

  {{{ Markdown section=summary }}}

=head2 get_blocks();

Returns the block objects that make up the current file.

=head2 block_type_map();

The block_type_map provides a means of changing the names or processors for
different block types.  By default a block marked like this:

  {{{ Markdown }}}

would be rendered using the L<Text::Multi::Block::Markdown> formatter.  If
you wanted to use a different formatter for Markdown syntax, you could remap
the Markdown type like this:

  $tm->block_type_map( { Markdown => 'MyMarkdown' } );

Then the call to 'Markdown' would use a formatter called
Text::Multi::Block::MyMarkdown instead.

If your block subclass does not live in the L<Text::Multi::Block> namespace,
you can prefix it's name with a C<+>, then it won't have "Text::Multi::Block"
prepended:

  $tm->block_type_map->{ 'Wiki' } = '+MyApp::Formatter::Text::Wiki';

=head1 INTERNAL METHODS

You generally don't need to do anything with these methods, they will be
called at the appropriate times.

=head2 make_blocks();

Called automatically by L</process_file>, L</process_fh>, and
L</process_text>.  This method does the actual processing of the text and
turns it into block objects.

=head2 block_class( $type );

Returns the class name for a given block type, ensuring that the class is
laoded first.

=head2 make_meta( $text );

Processes the arguments given to a block start tag, and returns a hashref
of the options.  For example, given the start tag

  {{{ Markdown section=summary }}}

make_meta would return (after running through L<Data::Dump/dump>).

  ( section => 'summary' )

=head1 SEE ALSO

L<Text::Multi::Block>

L<http://www.jasonkohles.com/software/Text-Multi/>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Multi

You can also look for information at:

=over 4

=item * Project home page

L<http://www.jasonkohles.com/software/Text-Multi>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Multi>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Multi>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Multi>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Multi>

=back

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-multi at
rt.cpan.org>, or through the web interface at L<http://rt.cpan.org>.  I
will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head2 KNOWN BUGS

=over

=item * There aren't really any tests yet.

=back

=head1 AUTHOR

Jason Kohles, C<< <email@jasonkohles.com> >>, L<http://www.jasonkohles.com/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007-2008 Jason Kohles.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

