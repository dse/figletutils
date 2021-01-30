package Font::Bitmap;
use warnings;
use strict;
use Moo;

# STARTFONT <bdfVersion>
has 'bdfVersion'         => (is => 'rw', default => '2.2');

# COMMENT <string>
has 'comments'           => (is => 'rw', default => sub { return []; });

# CONTENTVERSION <integer>
has 'contentVersion'     => (is => 'rw');

# FONT <string>
has 'fontName'           => (is => 'rw');

# SIZE <pointSize> <xResolution> <yResolution>
has 'pointSize'          => (is => 'rw'); # points (1/72 inch)
has 'xResolution'        => (is => 'rw'); # pixels per inch
has 'yResolution'        => (is => 'rw'); # pixels per inch

# FONTBOUNDINGBOX <width> <height> <xOffset> <yOffset>
has 'boundingBoxWidth'   => (is => 'rw');
has 'boundingBoxHeight'  => (is => 'rw');
has 'boundingBoxXOffset' => (is => 'rw');
has 'boundingBoxYOffset' => (is => 'rw');

# METRICSSET <metricsSet>
has 'metricsSet'         => (is => 'rw', default => 0);
# 0 = writing direction 0 only
# 1 = writing direction 1 only
# 2 = both

# same as in Font::Bitmap::Character
# SWIDTH <x> <y>
# DWIDTH <x> <y>
# SWIDTH1 <x> <y>
# DWIDTH1 <x> <y>
# VVECTOR <x> <y>
has 'sWidthX'            => (is => 'rw');
has 'sWidthY'            => (is => 'rw');
has 'dWidthX'            => (is => 'rw');
has 'dWidthY'            => (is => 'rw');
has 'sWidth1X'           => (is => 'rw');
has 'sWidth1Y'           => (is => 'rw');
has 'dWidth1X'           => (is => 'rw');
has 'dWidth1Y'           => (is => 'rw');
has 'vVectorX'           => (is => 'rw');
has 'vVectorY'           => (is => 'rw');

# STARTPROPERTIES <nprops>
# ENDPROPERTIES
has 'properties'         => (is => 'rw', default => sub { return {}; });
has 'characters'         => (is => 'rw', default => sub { return {}; });
has 'charactersList'     => (is => 'rw', default => sub { return []; });

# figlet font specific properties
has 'figletSmush'        => (is => 'rw', default => -1);
has 'figletSmush2'       => (is => 'rw', default => 0);
has 'commentLines'       => (is => 'rw', default => sub { return []; });

1;
