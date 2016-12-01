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

# $Revision: 5120 $ $Date:: 2016-12-01 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require File_cpp;
require Objects_cpp_json;
require "gen_tools_cpp.pl";

############################################################
package File;

sub to_cpp_to_json_decl
{
    my( $self ) = @_;

    my $body = "";

    my @includes  = @{ $self->{includes} };     # includes
    my @objs      = @{ $self->{objs} };         # objects
    my @base_msgs = @{ $self->{base_msgs} };    # base messages
    my @msgs      = @{ $self->{msgs} };         # messages

    my @enums     = @{ $self->get_all_enums() }; # all enums

    #$body = $body . "// DEBUG: size = " . scalar @enums . "\n";

    $body = $body . $self->{prot_object}->to_cpp_to_json_decl() . "\n";
    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@objs );
    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@base_msgs );
    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@msgs );
    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@enums );

    $body = $body . "\n";

    return $self->to_include_guards( $body, "to_json", 1, 1 );
}

############################################################
sub to_cpp_to_json_impl
{
    my( $self ) = @_;

    my $body = "";

    my @enums     = @{ $self->get_all_enums() }; # all enums

    $body = $body . $self->{prot_object}->to_cpp_to_json_impl() . "\n";
    $body = $body . gtcpp::array_to_cpp_to_json_impl( $self->{objs} );      # objects
    $body = $body . gtcpp::array_to_cpp_to_json_impl( $self->{base_msgs} ); # base messages
    $body = $body . gtcpp::array_to_cpp_to_json_impl( $self->{msgs} );      # messages
    $body = $body . gtcpp::array_to_cpp_to_json_impl( \@enums );

    $body = $body . "\n";

    $body = gtcpp::namespacize( 'json_helper', $body );

    $body =
        "#include <sstream>            // std::ostringstream\n\n" .
        "#include \"json_helper.h\"      // json_helper\n\n" .
        $body;

    my $incl = gtcpp::to_include_to_json( $self->{name} ) . "    // self\n\n";

    $incl = $incl . gtcpp::array_to_include_to_json( $self->{includes} ) . "\n";

    $body = $incl . $body;

    return $body;
}

############################################################
