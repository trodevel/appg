#!/usr/bin/perl -w

# Elements
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

# $Revision: 5076 $ $Date:: 2016-11-28 #$ $Author: serge $
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
