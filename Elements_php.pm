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

# $Revision: 13290 $ $Date:: 2020-06-17 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Elements;
require DataTypes_php;

############################################################
package EnumElement;

sub to_php_decl($)
{
    my( $self, $enum_name ) = @_;

    if( defined $self->{value} && $self->{value} ne '' )
    {
        return sprintf( "const %s__%-20s = %s;", $enum_name, $self->{name}, $self->{value} );
    }

    return sprintf( "const %s__%-20s = 0;", $enum_name, $self->{name} );
}

############################################################
package ConstElement;

sub to_php_decl
{
    my( $self ) = @_;

    return sprintf( "const %-10s = %s; // type: %s", $self->{name}, $self->{value}, $self->{data_type}->to_php_decl() );
}

############################################################
package Element;

sub to_php_decl
{
    my( $self ) = @_;
    return sprintf( "public \$%-20s; // type: %s", $self->{name}, $self->{data_type}->to_php_decl() );
}

############################################################
package ValidRange;

sub to_php_comment
{
    my( $self ) = @_;

    my $from = "-inf";
    my $to   = "+inf";

    my $prefix = "";
    my $suffix = "";

    if( $self->{has_from} == 1 )
    {
        $from = $self->{from};

        if( $self->{is_inclusive_from} == 1 )
        {
            $prefix = "[";
        }
        else
        {
            $prefix = "(";
        }
    }

    if( $self->{has_to} == 1 )
    {
        $to = $self->{to};

        if( $self->{is_inclusive_to} == 1 )
        {
            $suffix = "]";
        }
        else
        {
            $suffix = ")";
        }
    }
    return "$prefix$from, $to$suffix";
}

############################################################
package ElementExt;

sub to_php_decl
{
    my( $self ) = @_;

    my $add = "";

    if( defined $self->{valid_range_or_size} && $self->{valid_range_or_size} ne '' )
    {
        my $comment = "valid range";

        if( $self->{is_array} == 1 )
        {
            $comment = "size constrain";
        }

        $add = " // $comment: " . $self->{valid_range_or_size}->to_php_comment();
    }

    return $self->SUPER::to_php_decl() . $add;
}

############################################################
