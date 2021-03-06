package Font::Bitmap::Parser::Figlet;
use warnings;
use strict;
use Moo;

use Text::Tabs qw(expand);
use charnames qw();
use List::Util qw(max);
our $CODEPOINTS;

BEGIN {
    $CODEPOINTS = [32 .. 126, 0xc4, 0xd6, 0xdc, 0xe4, 0xf6, 0xfc, 0xdf];
}

has 'stage'        => (is => 'rw', default => 0);
has 'charHeight'   => (is => 'rw');
has 'baseline'     => (is => 'rw');
has 'maxLength'    => (is => 'rw');
has 'smush'        => (is => 'rw');
has 'commentLines' => (is => 'rw');
has 'encoding'     => (is => 'rw', default => 0);
has 'maxEncoding'  => (is => 'rw', default => -1);
has 'lineNumber'   => (is => 'rw', default => 0);
has 'charLines'    => (is => 'rw', default => sub { return {}; });
has 'encodings'    => (is => 'rw', default => sub { return []; });

sub parse {
    my ($self, $line) = @_;
    $line =~ s{\R\z}{};
    $line = expand($line);
    if ($self->stage == 0) {
        $self->parse0($line);
    } elsif ($self->stage == 1) {
        $self->parse1($line);
    } elsif ($self->stage == 2) {
        $self->parse2($line);
    }
}

sub parse0 {                    # first line
    my ($self, $line) = @_;
    if ($line !~ m{^tlf2..
                   \s+(-?\d+)
                   \s+(-?\d+)
                   \s+(-?\d+)
                   \s+(-?\d+)
                   \s+(-?\d+)}x) {
        $self->stage(-1);
        return;
    }
    my ($charHeight, $baseline, $maxLength, $smush, $commentLines) =
        ($1, $2, $3, $4, $5);
    $self->charHeight($charHeight);
    $self->baseline($baseline);
    $self->maxLength($maxLength);
    $self->smush($smush);
    $self->commentLines($commentLines);
    $self->stage(1);
}

sub parse1 {                    # any comment lines
    my ($self, $line) = @_;
    if ($self->commentLines <= 0) {
        $self->stage(2);
        $self->parse2($line);
    }
    $self->commentLines($self->commentLines - 1);
}

sub parse2 {
    my ($self, $line) = @_;
    if ($self->lineNumber == $self->charHeight) {
        $self->lineNumber(0);
        $self->encoding($self->encoding + 1);
    }
    if ($self->lineNumber == 0) {
        $self->maxEncoding($self->encoding);
        $self->charLines->{$self->encoding} = [];
    }
    if (length($line)) {
        my $lastChar = substr($line, -1);
        while (length($line) && substr($line, -1) eq $lastChar) {
            substr($line, -1) = "";
        }
    }
    push(@{$self->charLines->{$self->encoding}}, $line);
    $self->lineNumber($self->lineNumber + 1);
}

sub braille {
    my ($self) = @_;
    my $newCharHeight = int(($self->charHeight + 3) / 4);
    my $newBaseline   = int(($self->baseline + 3) / 4);
    my $newMaxLength  = int($self->maxLength / 2 + 1);
    printf("tlf2a\$ %d %d %d %d %d 0 0 0\n",
           $newCharHeight, $newBaseline, $newMaxLength, -1, 3);
    print("/**\n");
    print(" * generated by tlfbraille\n");
    print(" */\n");
    foreach my $encoding (0 .. $self->maxEncoding) {
        my @charLines = @{$self->charLines->{$encoding}};
        foreach (@charLines) {
            $_ .= ' ' if length($_) % 2 == 1;
        }
        while (scalar(@charLines) % 4 != 0) {
            push(@charLines, '');
        }
        my @newCharLines;
        foreach my $newLineNumber (0 .. ($newCharHeight - 1)) {
            my $i1 = $newLineNumber * 4 + 0;
            my $i2 = $newLineNumber * 4 + 1;
            my $i3 = $newLineNumber * 4 + 2;
            my $i4 = $newLineNumber * 4 + 3;
            my $l1 = $charLines[$i1];
            my $l2 = $charLines[$i2];
            my $l3 = $charLines[$i3];
            my $l4 = $charLines[$i4];
            while (length($l1) || length($l2) || length($l3) || length($l4)) {
                my $c1 = length($l1) ? substr($l1, 0, 2) : '  ';
                my $c2 = length($l2) ? substr($l2, 0, 2) : '  ';
                my $c3 = length($l3) ? substr($l3, 0, 2) : '  ';
                my $c4 = length($l4) ? substr($l4, 0, 2) : '  ';
                $l1 = length($l1) >= 2 ? substr($l1, 2) : '';
                $l2 = length($l2) >= 2 ? substr($l2, 2) : '';
                $l3 = length($l3) >= 2 ? substr($l3, 2) : '';
                $l4 = length($l4) >= 2 ? substr($l4, 2) : '';
                if ($l1 eq '' && $l2 eq '' && $l3 eq '' && $l4 eq '' && $c1 eq '  ' && $c2 eq '  ' && $c3 eq '  ' && $c4 eq '  ') {
                    # regular spaces for end padding
                    $newCharLines[$newLineNumber] .= ' ';
                    next;
                }
                my $dots = '';
                $dots .= '1' if substr($c1, 0, 1) ne ' ';
                $dots .= '2' if substr($c2, 0, 1) ne ' ';
                $dots .= '3' if substr($c3, 0, 1) ne ' ';
                $dots .= '4' if substr($c1, 1, 1) ne ' ';
                $dots .= '5' if substr($c2, 1, 1) ne ' ';
                $dots .= '6' if substr($c3, 1, 1) ne ' ';
                $dots .= '7' if substr($c4, 0, 1) ne ' ';
                $dots .= '8' if substr($c4, 1, 1) ne ' ';
                my $charName = 'BRAILLE PATTERN BLANK';
                if ($dots ne '') {
                    $charName = 'BRAILLE PATTERN DOTS-' . $dots;
                }
                my $codepoint = charnames::vianame(uc $charName);
                if (defined $codepoint) {
                    $newCharLines[$newLineNumber] .= chr($codepoint);
                } else {
                    $newCharLines[$newLineNumber] .= ' ';
                }
            }
        }
        my $maxLength = max map { length($_) } @newCharLines;
        @newCharLines = map { $_ . (' ' x ($maxLength - length($_))) } @newCharLines;
        my $i = 0;
        foreach my $line (@newCharLines) {
            $i += 1;
            if ($i == scalar @newCharLines) {
                print("$line@@\n");
            } else {
                print("$line@\n");
            }
        }
    }
}

sub eof {
    my ($self, $line) = @_;
}

1;
