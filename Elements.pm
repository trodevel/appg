#!/usr/bin/perl -w

# $Revision: 4955 $ $Date:: 2016-11-08 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
package EnumElement;
use strict;
use warnings;

require DataTypes;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        value     => shift,
    };

    bless $self, $class;
    return $self;
}

############################################################
package ConstElement;
use strict;
use warnings;

require DataTypes;

sub new
{
    my $class = shift;
    my $self =
    {
        data_type => shift,
        name      => shift,
        value     => shift,
    };

    bless $self, $class;
    return $self;
}

############################################################
package Element;
use strict;
use warnings;

require DataTypes;

sub new
{
    my $class = shift;
    my $self =
    {
        data_type => shift,
        name      => shift,
    };

    bless $self, $class;
    return $self;
}

############################################################
package ValidRange;

sub new
{
    my $class = shift;
    my $self =
    {
        has_from          => shift,
        from              => shift,
        is_inclusive_from => shift,
        has_to            => shift,
        to                => shift,
        is_inclusive_to   => shift,
    };

    bless $self, $class;
    return $self;
}

############################################################
package ElementExt;
use strict;
use warnings;

our @ISA = qw( Element );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[2] );

    $self->{valid_range_or_size} = $_[3];
    $self->{is_array}            = $_[4];

    bless $self, $class;
    return $self;
}

############################################################
