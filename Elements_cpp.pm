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

# $Revision: 13016 $ $Date:: 2020-05-12 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Elements;
require DataTypes_cpp;

############################################################
package EnumElement;

sub to_cpp_decl
{
    my( $self ) = @_;

    if( defined $self->{value} && $self->{value} ne '' )
    {
        return sprintf( "%-20s = %s,", $self->{name}, $self->{value} );
    }

    return $self->{name} . ",";
}

############################################################
package ConstElement;

sub to_cpp_decl
{
    my( $self ) = @_;

    return sprintf( "static const %-20s %-10s = %s;", $self->{data_type}->to_cpp_decl(), $self->{name}, $self->{value} );
}

############################################################
package Element;

sub to_cpp_decl
{
    my( $self ) = @_;
    return sprintf( "%-20s %-10s;", $self->{data_type}->to_cpp_decl(), $self->{name} );
}

############################################################
package ValidRange;

sub to_cpp_comment
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

sub to_cpp_func_params
{
    my( $self ) = @_;

    my $has_from = "false";
    my $has_to   = "false";
    my $is_inclusive_from = "false";
    my $is_inclusive_to   = "false";
    my $from = "0";
    my $to   = "0";

    if( $self->{has_from} == 1 )
    {
        $has_from = "true";

        $from = $self->{from};

        if( $self->{is_inclusive_from} == 1 )
        {
            $is_inclusive_from = "true";
        }
    }

    if( $self->{has_to} == 1 )
    {
        $has_to = "true";

        $to = $self->{to};

        if( $self->{is_inclusive_to} == 1 )
        {
            $is_inclusive_to = "true";
        }
    }


    return "$has_from, $is_inclusive_from, $from, $has_to, $is_inclusive_to, $to";
}

############################################################
package ElementExt;

sub to_cpp_decl
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

        $add = " // $comment: " . $self->{valid_range_or_size}->to_cpp_comment();
    }

    return $self->SUPER::to_cpp_decl() . $add;
}

############################################################
