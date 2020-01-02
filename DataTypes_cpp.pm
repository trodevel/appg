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

# $Revision: 12580 $ $Date:: 2020-01-02 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
require DataTypes;

package Generic;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}


############################################################
package Boolean;

sub to_cpp_decl()
{
    my( $self ) = @_;

    return "bool";
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "get_value_or_throw_bool";
}

############################################################
package Integer;

sub to_cpp_decl()
{
    my( $self ) = @_;

    my $prefix = "";

    if( $self->{is_unsigned} == 1 )
    {
        $prefix = "u";
    }
    return "${prefix}int" . $self->{bit_width} . "_t";
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;

    my $prefix = "";

    if( $self->{is_unsigned} == 1 )
    {
        $prefix = "u";
    }

    return "get_value_or_throw_${prefix}int" . $self->{bit_width};
}

############################################################
package Float;

sub to_cpp_decl()
{
    my( $self ) = @_;
    if( $self->{is_double} == 1 )
    {
        return "double";
    }
    return "float";
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "get_value_or_throw_" . ( $self->{is_double} == 1 ) ? "double" : "float";
}

############################################################
package String;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::string";
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "get_value_or_throw";
}

############################################################
package UserDefined;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return $self->{name};
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "to_" . $self->{name};
}

############################################################
package UserDefinedEnum;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return $self->{name};
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "to_" . $self->{name};
}

############################################################
package Vector;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::vector<" . $self->{value_type}->to_cpp_decl() . ">";
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "to_vector_" . $self->{value_type}->to_cpp_decl();
}

############################################################
package Map;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::map<" . $self->{key_type}->to_cpp_decl() . ", " . $self->{mapped_type}->to_cpp_decl() . ">";
}

sub to_cpp__to_parse_function_name()
{
    my( $self ) = @_;
    return "to_map_" . $self->{key_type}->to_cpp_decl() . "_" . $self->{mapped_type}->to_cpp_decl();
}

############################################################

