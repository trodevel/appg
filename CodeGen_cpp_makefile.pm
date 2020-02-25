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

sub generate_makefile_lib__to_includes($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{includes} } )
    {
        $res .= "\t" . $_ . " \\\n";
    }

    return $res;
}

sub generate_makefile_lib($)
{
    my ( $file_ref ) = @_;

    my $res;

    my $name = get_namespace_name( $$file_ref );

    $res =

"# Makefile for lib${name}\n" .
"# automatically generated file\n" .
"\n" .
"###################################################################\n" .
"\n" .
"VER = 0\n" .
"\n" .
"LIB_PROJECT = $name\n" .
"\n" .
"LIB_BOOST_LIB_NAMES :=\n" .
"\n" .
"LIB_SRCC = \\\n" .
"\tcsv_helper.cpp \\\n" .
"\texported_csv_helper.cpp \\\n" .
"\texported_parser.cpp \\\n" .
"\texported_str_helper.cpp \\\n" .
"\texported_validator.cpp \\\n" .
"\trequest_type_parser.cpp \\\n" .
"\tparser.cpp \\\n" .
"\tstr_helper.cpp \\\n" .
"\n" .
"LIB_EXT_LIB_NAMES = \\\n" .
"\tbasic_parser \\\n" .
"\tgeneric_protocol \\\n" .
"\tgeneric_request \\\n" .
"\tutils \\\n" .
    generate_makefile_lib__to_includes( $file_ref ) .
"\n";

    return $res;
}

###############################################

sub generate_makefile_app($)
{
    my ( $file_ref ) = @_;

    my $res;

    my $name = get_namespace_name( $$file_ref );

    $res =

"# Makefile for lib${name}\n" .
"# automatically generated file\n" .
"\n" .
"###################################################################\n" .
"\n" .
"VER = 0\n" .
"\n" .
"APP_PROJECT := example\n" .
"\n" .
"APP_BOOST_LIB_NAMES := system regex\n" .
"\n" .
"APP_THIRDPARTY_LIBS = -lm\n" .
"\n" .
"APP_SRCC = example.cpp\n" .
"\n" .
"APP_EXT_LIB_NAMES = \\\n" .
"\tbasic_parser \\\n" .
"\tgeneric_protocol \\\n" .
"\tgeneric_request \\\n" .
"\tutils \\\n" .
    generate_makefile_lib__to_includes( $file_ref ) .
"\n";

    return $res;
}

###############################################

sub generate_makefile($)
{
    my ( $file_ref ) = @_;

    my $res =

"export MAKETOOLS_PATH := \$(CURDIR)/../make_tools\n" .
"\n" .
"include \$(MAKETOOLS_PATH)/Makefile.common.mak\n" .
"\n";

    return $res;
}

###############################################


1;
