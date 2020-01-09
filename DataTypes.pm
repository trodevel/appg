#!/usr/bin/perl -w

# DataTypes
#
# Copyright (C) 2016 Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# $Revision: 12591 $ $Date:: 2020-01-09 #$ $Author: serge $
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
package Boolean;

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

sub new($$)
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{name}  = $_[1];
    $self->{namespace}  = $_[2];
    bless $self, $class;
    return $self;
}

############################################################
package UserDefinedEnum;

use strict;
our @ISA = qw( Generic );

sub new($$)
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{name}  = $_[1];
    $self->{namespace}  = $_[2];
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

