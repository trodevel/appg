#!/usr/bin/perl -w

# $Revision: 4907 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
package Generic;

sub new
{
    my $class = shift;
    my $self =
    {
    };

    bless $self, $class;
    return $self;
}


############################################################
package Integer;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{is_unsigned}  = $_[1];
    $self->{bit_width}    = $_[2];
    bless $self, $class;
    return $self;
}

############################################################
package Float;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{is_double}  = $_[1];
    bless $self, $class;
    return $self;
}

############################################################
package String;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    bless $self, $class;
    return $self;
}

############################################################
package UserDefined;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{name}  = $_[1];
    bless $self, $class;
    return $self;
}

############################################################
package Vector;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{value_type}  = $_[1];
    bless $self, $class;
    return $self;
}

############################################################
package Map;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{key_type}         = $_[1];
    $self->{mapped_type}      = $_[2];
    bless $self, $class;
    return $self;
}

############################################################

