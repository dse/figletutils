package Font::Bitmap::Character;
use warnings;
use strict;
use Moo;

has 'font'               => (is => 'rw');

# STARTCHAR <string>
# ENCODING <integer> <integer>

has 'codepoint'          => (is => 'rw');
has 'encoding2'          => (is => 'rw');

# SWIDTH <x> <y>
# DWIDTH <x> <y>
# SWIDTH1 <x> <y>
# DWIDTH1 <x> <y>
# VVECTOR <x> <y>
has 'sWidthX'            => (is => 'rw'); # in units of <pointSize>/1000 pts.
has 'sWidthY'            => (is => 'rw'); # "
has 'dWidthX'            => (is => 'rw'); # in pixels
has 'dWidthY'            => (is => 'rw'); # "
has 'sWidth1X'           => (is => 'rw'); # in units of <pointSize>/1000 pts.
has 'sWidth1Y'           => (is => 'rw'); # "
has 'dWidth1X'           => (is => 'rw'); # in pixels
has 'dWidth1Y'           => (is => 'rw'); # "
has 'vVectorX'           => (is => 'rw'); # in pixels
has 'vVectorY'           => (is => 'rw'); # "

# BBX <width> <height> <xOffset> <yOffset>
has 'boundingBoxWidth'   => (is => 'rw'); # in pixels
has 'boundingBoxHeight'  => (is => 'rw'); # "
has 'boundingBoxXOffset' => (is => 'rw'); # "
has 'boundingBoxYOffset' => (is => 'rw'); # "

has 'data' => (is => 'rw', default => sub { return []; });

1;


# swidth * p / 1000 * r / 72 = dwidth
# swidth * p / 1000 = dwidth * 72 / r
# swidth = dwidth * 72 / r * 1000 / p
# p = <size of glyph in points>
# r = <number of pixels per inch>

# dwidth          = <glyph width in pixels>
# dwidth * 72     = <glyph width in units of 1/72 pixel>
# dwidth * 72 / r = <glyph width in units of r/72 pixels>
# dwidth * 72 / r * 1000 = <glyph width in units of r / 72000 pixels>
# dwidth * 72 / r * 1000 / p = <glyph width in units of p * r / 72000 pixels>
    = <glyph width in units of p / 72000 inches>
    = <glyph width in units of p / 1000 points>
