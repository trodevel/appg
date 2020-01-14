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

###############################################

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_exported_request_parser_h__to_obj_name($$)
{
    my ( $namespace, $name ) = @_;

    return "void get_value_or_throw( $namespace::$name * res, const std::string & key, const generic_request::Request & r );";
}

sub generate_exported_request_parser_h_body_1_core($$)
{
    my ( $namespace, $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_request_parser_h__to_obj_name( $namespace, $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_request_parser_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{enums} );
}

sub generate_exported_request_parser_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{objs} );
}

sub generate_exported_request_parser_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

generate_exported_request_parser_h_body_1( $file_ref ) .
"\n" .
generate_exported_request_parser_h_body_2( $file_ref ) .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "basic_parser", "exported_request_parser", 0, 0, [ "protocol", "generic_request/request" ], [] );

    return $res;
}

###############################################

sub generate_exported_request_parser_cpp__to_body($$)
{
    my ( $namespace, $name ) = @_;

    my $res =

"void get_value_or_throw( ${namespace}::${name} * res, const std::string & key, const generic_request::Request & r )\n" .
"{\n" .
"    ${namespace}::RequestParser::get_value_or_throw( res, key, r );\n" .
"}\n";

    return $res;
}

sub generate_exported_request_parser_cpp__to_enum__core($$)
{
    my ( $namespace, $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_request_parser_cpp__to_body( $namespace, $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_request_parser_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_cpp__to_enum__core( get_namespace_name( $$file_ref ), $$file_ref->{enums} );
}

sub generate_exported_request_parser_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_cpp__to_enum__core( get_namespace_name( $$file_ref ), $$file_ref->{objs} );
}

sub generate_exported_request_parser_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_exported_request_parser_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_exported_request_parser_cpp__to_object( $file_ref )
;

    my $res = to_body( $$file_ref, $body, "basic_parser", [ "exported_request_parser", "request_parser" ], [ ] );

    return $res;
}

###############################################

1;
