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

# $Revision: 5076 $ $Date:: 2016-11-28 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Objects;
require Elements_cpp;
require "gen_tools.pl";
require "gen_tools_cpp.pl";

############################################################
package IObject;

sub to_cpp_decl
{
    my( $self ) = @_;
    return '#error not implemented yet';
}

sub get_base_class()
{
    my( $self ) = @_;

    return "Object";
}

sub append_base_class()
{
    my( $self, $body ) = @_;

    my $base = $self->get_base_class();

    return $body . ": public $base";
}

############################################################
package Enum;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Enum\n" .
"enum class " . $self->{name} ." : " . $self->{data_type}->to_cpp_decl() . "\n";

    my $body = gtcpp::array_to_decl( $self->{elements} );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package ObjectWithMembers;

sub get_base_class()
{
    my( $self ) = @_;

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        return $self->{base_class};
    }

    return $self->SUPER::get_base_class();
}

############################################################
package Object;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Object\n" .
"struct " . $self->{name};

    $res = $self->append_base_class( $res ) . "\n";

    my @array = @{ $self->{members} };

    my $body = gtcpp::array_to_decl( $self->{enums} );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package BaseMessage;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Base message\n" .
"struct " . $self->{name};

    $res = $self->append_base_class( $res ) . "\n";

    my @array = @{ $self->{members} };

    my $body = gtcpp::array_to_decl( $self->{enums} );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package Message;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Message\n" .
"struct " . $self->{name};

    $res = $self->append_base_class( $res ) . "\n";

    my $body = "";

    $body = $body . "enum\n" . main::bracketize( "message_id = " . $self->{message_id} . "\n", 1 ) . "\n";

    my @array = @{ $self->{members} };

    $body = $body . gtcpp::array_to_decl( $self->{enums} );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
