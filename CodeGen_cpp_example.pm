#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_cpp.
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

###############################################

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_example__to_object__body($$$$)
{
    my ( $namespace, $msg, $is_message, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"void example_${name}()\n" .
"{\n" .
"    $namespace::$name obj;\n" .
"}\n";

    return $res;
}

sub generate_example__to_object__core($$$)
{
    my ( $file_ref, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_example__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_example__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_example__to_object__core( $file_ref,  $$file_ref->{objs}, 0 );
}

sub generate_example__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_example__to_object__core( $file_ref,  $$file_ref->{msgs}, 1 );
}

sub generate_example($)
{
    my ( $file_ref ) = @_;

    my $res =

"#include \"protocol.h\"\n" .
"\n" .
"// objects\n" .
"\n" .
    generate_example__to_object( $file_ref ) .
"\n" .
"// messages\n" .
"\n" .
    generate_example__to_message( $file_ref ) .
"\n" .
"int main()\n" .
"{\n" .
"    return 0;\n" .
"}\n" .
"\n";

    return $res;
}

###############################################

1;
