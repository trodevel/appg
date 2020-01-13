#!/usr/bin/perl -w

#
# Automatic Protocol Generator - CodeGen_cpp.
#
# Copyright (C) 2019 Sergey Kolevatov
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

# $Id $
# SKV 19c25

# 1.0 - 19c25 - initial commit

###############################################

require File;
require Objects_cpp;
require "gen_tools_cpp.pl";
require CodeGen_cpp_common;

###############################################

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

############################################################

sub to_cpp_decl
{
    my( $file_ref ) = @_;

    my $file = $$file_ref;

    my $body = "";

    # protocol object
    $body = $body . $file->{prot_object}->to_cpp_decl() . "\n";

    my @consts    = @{ $file->{consts} };       # consts
    my @enums     = @{ $file->{enums} };        # enums
    my @objs      = @{ $file->{objs} };         # objects
    my @base_msgs = @{ $file->{base_msgs} };    # base messages
    my @msgs      = @{ $file->{msgs} };         # messages

    $body = $body . gtcpp::array_to_decl( \@consts );
    $body = $body . gtcpp::array_to_decl( \@enums );
    $body = $body . gtcpp::array_to_decl( \@objs );
    $body = $body . gtcpp::array_to_decl( \@base_msgs );
    $body = $body . gtcpp::array_to_decl( \@msgs );

    my $res = to_include_guards( $file, $body, "", "decl", 0, 1, [] );

    $res = $res . "\n";

    return $res;
}

############################################################

1;
