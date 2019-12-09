#!/usr/bin/perl -w

# File
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

# $Revision: 12449 $ $Date:: 2019-12-09 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require File;
require Objects_cpp;
require "gen_tools_cpp.pl";

############################################################
package File;

############################################################
sub namespacize($)
{
    my( $self, $body ) = @_;

    my $res = gtcpp::namespacize( $self->{name}, $body );

    if( $self->{must_use_ns} )
    {
        $res = gtcpp::namespacize( 'apg', $res );
    }

    return $res;
}
############################################################
sub to_include_guards
{
    my( $self, $body, $prefix, $must_include_myself, $must_include_helper ) = @_;

    my @includes  = @{ $self->{includes} };     # includes

    if( defined $must_include_helper && $must_include_helper == 1 )
    {
        $body = gtcpp::namespacize( 'json_helper', $body );
    }
    else
    {
        $body = $self->namespacize( $body );
    }

    if( defined $must_include_myself && $must_include_myself == 1 )
    {
        $body =
            gtcpp::to_include( $self->{name} ) . "    // self\n\n" . $body;
    }
    else
    {
        $body = "// includes\n" .
            gtcpp::array_to_include( \@includes ) . "\n" . $body;
    }

    my $res = gtcpp::ifndef_define_prot( $self->{name}, $prefix, $body );

    return $res;
}

############################################################

sub to_cpp_decl
{
    my( $self ) = @_;

    my $body = "";

    # protocol object
    $body = $body . $self->{prot_object}->to_cpp_decl() . "\n";

    my @enums     = @{ $self->{enums} };        # enums
    my @objs      = @{ $self->{objs} };         # objects
    my @base_msgs = @{ $self->{base_msgs} };    # base messages
    my @msgs      = @{ $self->{msgs} };         # messages

    $body = $body . gtcpp::array_to_decl( \@enums );
    $body = $body . gtcpp::array_to_decl( \@objs );
    $body = $body . gtcpp::array_to_decl( \@base_msgs );
    $body = $body . gtcpp::array_to_decl( \@msgs );

    my $res = $self->to_include_guards( $body, "decl" );

    return $res;
}

############################################################
sub get_enums_from_object
{
    my( $obj_ref ) = @_;

    my @res;

    if( @{ $obj_ref->{enums} } )
    {
        push( @res, @{ $obj_ref->{enums} } );
    }

    return \@res;
}
############################################################
sub get_enums_from_object_list
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my @res;

    foreach( @array )
    {
        my $enums_ref = get_enums_from_object( $_ );

        push( @res, @{ $enums_ref } );
    }

    return \@res;
}
############################################################
sub get_all_enums
{
    my( $self ) = @_;

    my @res;

    push( @res, @{ $self->{enums} } );
    push( @res, @{ get_enums_from_object_list( $self->{objs} ) } );
    push( @res, @{ get_enums_from_object_list( $self->{base_msgs} ) } );
    push( @res, @{ get_enums_from_object_list( $self->{msgs} ) } );

    return \@res;
}
############################################################
