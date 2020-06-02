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

# $Revision: 13177 $ $Date:: 2020-06-02 #$ $Author: serge $
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

sub has_base_class()
{
    my( $self ) = @_;

    die "not defined for object $self->{name}";
}

sub get_base_class()
{
    my( $self ) = @_;

    die "not defined for object $self->{name}";
}

sub get_full_base_class()
{
    my( $self ) = @_;

    return $self->get_protocol_name() . "::Object";
}

sub get_full_base_class_apg()
{
    my ( $self ) = @_;

    return "apg::" . $self->get_full_base_class();
}

sub get_protocol_name
{
    my ( $self ) = @_;

    if( not defined $self->{protocol} || ( defined $self->{protocol} && $self->{protocol} eq '' ) )
    {
        die "protocol is not defined for " . $self->{name} . "\n";
    }

    return $self->{protocol};
}

sub get_full_name
{
    my ( $self ) = @_;

    return $self->get_protocol_name() . "::" . $self->{name};
}

sub get_full_name_apg
{
    my ( $self ) = @_;

    return "apg::" . $self->get_full_name();
}

sub get_optional_base_class_suffix($$)
{
    my( $self ) = @_;

    if( $self->has_base_class() )
    {
        return ": public " . $self->get_base_class();
    }

    return "";
}

############################################################
package Enum;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $optional_dt = ( defined $self->{data_type} ) ?
        " : " . $self->{data_type}->to_cpp_decl() : "";

    my $res =
"// Enum\n" .
"enum class " . $self->{name} . $optional_dt . "\n";

    my $body = gtcpp::array_to_decl( $self->{elements} );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

# @return name with parent name
sub get_full_name
{
    my ( $self ) = @_;

    my $parent = "";

    if( defined $self->{parent} && $self->{parent} ne '' )
    {
        $parent = $self->{parent} . "::";
    }

    return $self->get_protocol_name() . "::" . $parent . $self->{name};
}

############################################################
package ObjectWithMembers;

sub has_base_class()
{
    my( $self ) = @_;

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        return 1;
    }

    return 0;
}

sub get_base_class()
{
    my( $self ) = @_;

    die "no base class for object $self->{name}" if ( $self->has_base_class() == 0 );

    return $self->{base_class};
}

############################################################
package Object;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Object\n" .
"struct " . $self->{name} . $self->get_optional_base_class_suffix() . "\n";

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
"struct " . $self->{name} . $self->get_optional_base_class_suffix() . "\n";

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
"struct " . $self->{name} . $self->get_optional_base_class_suffix() . "\n";

    my $body = "";

    $body = $body . "enum\n" . main::bracketize( "message_id = " . $self->{message_id} . "\n", 1 ) . "\n";

    my @array = @{ $self->{members} };

    $body = $body . gtcpp::array_to_decl( $self->{enums} );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
