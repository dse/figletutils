package Font::Bitmap::Parser::BDF;
use warnings;
use strict;
use Moo;

use Text::Tabs qw(expand);

has 'font' => (is => 'rw');

sub parse {
    my ($self, $line) = @_;
    $line =~ s{\R\z}{};
    $line = expand($line);
}

1;
