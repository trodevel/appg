#!/usr/bin/perl -w

# Objects
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

# $Revision: 5119 $ $Date:: 2016-12-01 #$ $Author: serge $
# 1.0   - 16b08 - initial version

require Objects;
require Elements_cpp_json;
require Objects_cpp;

############################################################
package IObject;

sub to_cpp_to_json_func_name
{
    my( $self ) = @_;

    return "std::string to_json( const " . $self->get_full_name_apg() . " & o )";
}

sub to_cpp_to_json_decl
{
    my( $self ) = @_;

    return $self->to_cpp_to_json_func_name() . ";";
}

sub to_cpp_to_json_impl
{
    my( $self ) = @_;

    my $body = $self->to_cpp_to_json_impl_body();

    my $res =  $self->to_cpp_to_json_func_name() . "\n"
        . main::bracketize( $body );

    return $res;
}

# must be overriden
sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    return "#error not implemented yet";
}
############################################################
package Enum;

sub to_cpp_to_json_func_name
{
    my( $self ) = @_;

    return "std::string to_json( const " . $self->get_full_name_apg() . " o )";
}

sub to_cpp_to_json_decl
{
    my( $self ) = @_;

    return $self->to_cpp_to_json_func_name() . ";";
}

sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    my $res =
        "std::ostringstream os;\n\n" .
        "os << static_cast<" . $self->{data_type}->to_cpp_decl() . ">( o );\n\n" .
        "return os.str();";

    return $res;
}
############################################################
package ObjectWithMembers;

sub to_cpp_to_json_impl_body_kern
{
    my( $self, $must_bracketize ) = @_;

    my $res =
        "std::ostringstream os;\n\n" .
        "os ";

    if( $self->{is_message} )
    {
        $res = $res . "<< json_helper::to_pair( \"Message\", json_helper::to_string( \"" . $self->get_full_name() . "\" ) )\n";
    }

    my $base = $self->get_full_base_class_apg();

    $res = $res . "<< " . gtcpp::base_class_to_json( $base ) . "\n";

    my @array = @{ $self->{members} };

    foreach( @array )
    {
        $res = $res . "<< " . $_->to_cpp_json() . "\n";
    }

    my $last_line = "os.str();";

    if( defined $must_bracketize && $must_bracketize ne 0 )
    {
        $last_line = "json_helper::bracketize( os.str() );";
    }

    $res = $res . ";\n\n" .
        "return " . $last_line;

    return $res;
}

sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    return $self->to_cpp_to_json_impl_body_kern( 0 );
}

############################################################
package Object;

sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    return $self->to_cpp_to_json_impl_body_kern( 1 );
}

############################################################
package BaseMessage;

############################################################
package Message;

sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    return $self->to_cpp_to_json_impl_body_kern( 1 );
}

############################################################
