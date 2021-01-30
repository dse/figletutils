package Font::Bitmap::Properties;
use warnings;
use strict;
use Moo;

has 'props'      => (is => 'rw', default => sub { return {}; });
has 'propsArray' => (is => 'rw', default => sub { return []; });

sub add {
    my ($self, $propName, $propValue) = @_;
    $propName = $self->camel($propName);
    my $prop = $self->props->{$propName};
    if (!$prop) {
        $prop = {
            name => $propName,
            value => $propValue,
            values => [$propValue]
        };
        push(@{$self->propsArray}, $prop);
        $self->props->{$propName} = $prop;
        return $propValue;
    }
    $prop->{value} = $propValue;
    push(@{$prop->{values}}, $propValue);
    return $propValue;
}

sub set {
    my ($self, $propName, $propValue) = @_;
    $propName = $self->camel($propName);
    my $prop = $self->props->{$propName};
    if (!$prop) {
        $prop = {
            name => $propName,
            value => $propValue,
            values => [$propValue]
        };
        push(@{$self->propsArray}, $prop);
        $self->props->{$propName} = $prop;
        return $propValue;
    }
    $prop->{value} = $propValue;
    $prop->{values} = [$propValue];
    return $propValue;
}

sub get {
    my ($self, $propName) = @_;
    $propName = $self->camel($propName);
    my $prop = $self->props->{$propName};
    return $prop->{value} if defined $prop;
    return;
}

sub getAll {
    my ($self, $propName) = @_;
    $propName = $self->camel($propName);
    my $prop = $self->props->{$propName};
    return @{$prop->{values}} if defined $prop;
    return;
}

sub hasProperty {
    my ($self, $propName) = @_;
    $propName = $self->camel($propName);
    return exists $self->props->{$propName};
}

sub camel {
    my ($self, $propName) = @_;

    $propName =~ s{__+}{_}g;
    $propName =~ s{([[:lower:]])_*([[:upper:]])}{$1_$2}g;
    $propName = lc($propName);
    $propName =~ s{_+([[:lower:]])}{uc($1)}ge;

    # check for all-uppercase or all-lowercase
    if ($propName =~ m{^[A-Z][A-Z0-9_]*$} || $propName =~ m{^[a-z][a-z0-9_]*$}) {
        $propName = lc($propName);
        $propName =~ s{_([a-z])}{uc($1)}ge;
        return $propName;
    }

    return $propName;
}

1;
