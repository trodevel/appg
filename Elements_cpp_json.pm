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
# 1.0   - 16b05 - initial version

require Elements;
require DataTypes_cpp_json;

############################################################
package EnumElement;

sub to_cpp_json
{
    my( $self ) = @_;

    return "to_json( " . $self->{name} . " )";
}

############################################################
package Element;

sub to_cpp_json
{
    my( $self ) = @_;

    return  'json_helper::to_pair( "' . $self->{name} . '", ' . $self->{data_type}->to_cpp_json( $self->{name} ) . " )";
}

############################################################
