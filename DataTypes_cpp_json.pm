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

# $Revision: 5101 $ $Date:: 2016-11-30 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
require DataTypes;

package Generic;

sub to_cpp_json()
{
    my( $self, $value ) = @_;
    return "#error 'not implemented yet'";
}


############################################################
package Boolean;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value" ;
}

############################################################
package Integer;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value" ;
}

############################################################
package Float;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value" ;
}

############################################################
package String;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "json_helper::to_string( $value )";
}

############################################################
package UserDefined;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "to_json( $value )";
}

############################################################
package UserDefinedEnum;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "to_json( $value )";
}

############################################################
package Vector;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "json_helper::to_vector( $value )";
}

############################################################
package Map;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "json_helper::to_map( $value )";
}

############################################################

