BEGIN { use lib "$ENV{HOME}/lib" }
use inc::Module::Install;

name 'Text-Multi';
all_from 'lib/Text/Multi.pm';

author 'Jason Kohles <email@jasonkohles.com>';

requires 'Carp';
requires 'Carp::Clan';
requires 'Class::Accessor::Grouped';
requires 'Class::Inspector';
requires 'Getopt::Long';
requires 'Test::More';
requires 'Text::Markdown';

recommends 'Syntax::Highlight::Engine::Kate';
recommends 'Text::Markdown';

JasonsModInstallStuff;

auto_install;
WriteAll;
