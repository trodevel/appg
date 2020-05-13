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

sub generate_parser_h__to_msg_name($)
{
    my $name = shift;
    return "static Object *     to_" . $name . "( const generic_request::Request & r );";
}

sub generate_parser_h_body_4($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_parser_h__to_msg_name( $_->{name} ) . "\n";
    }

    return main::tabulate( $res );
}

sub generate_parser_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"class Parser\n" .
"{\n" .
"public:\n" .
"    typedef generic_protocol::Object    Object;\n" .
"\n" .
"public:\n" .
"\n" .
"    static generic_protocol::Object*    to_forward_message( const generic_request::Request & r );\n" .
"\n" .
"private:\n" .
"\n" .
"    static request_type_e   detect_request_type( const generic_request::Request & r );\n" .
"\n" .
generate_parser_h_body_4( $file_ref ) .
"\n" .
"};\n" .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "", "parser", 0, 0, [ "generic_request/request", "enums", "protocol" ], [] );

    return $res;
}

###############################################

sub generate_parser_cpp__to_forward_message__body($)
{
    my $name = shift;

    return "HANDLER_MAP_ENTRY( $name )";
}

sub generate_parser_cpp__to_forward_message($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_parser_cpp__to_forward_message__body( $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_parser_cpp__to_message__body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"Parser::Object * Parser::to_${name}( const generic_request::Request & r )\n" .
"{\n" .
"    auto * res = new $name;\n" .
"\n" .
"    ::basic_parser::get_value_or_throw( res, r );\n" .
"\n" .
"    validator::validate( * res );\n" .
"\n" .
"    return res;\n" .
"}\n";

    return $res;
}

sub generate_parser_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_parser_cpp__to_message__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_parser_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =
"using basic_parser::MalformedRequest;\n" .
"\n" .
"generic_protocol::Object* Parser::to_forward_message( const generic_request::Request & r )\n" .
"{\n" .
"    auto type = Parser::detect_request_type( r );\n" .
"\n" .
"    typedef request_type_e KeyType;\n" .
"    typedef Parser Type;\n" .
"\n" .
"    typedef Object* (*PPMF)( const generic_request::Request & r );\n" .
"\n" .
"#define HANDLER_MAP_ENTRY(_v)       { KeyType::_v,    & Type::to_##_v }\n" .
"\n" .
"    static const std::map<KeyType, PPMF> funcs =\n" .
"    {\n" .

    generate_parser_cpp__to_forward_message( $file_ref ) .

"    };\n" .
"\n" .
"#undef HANDLER_MAP_ENTRY\n" .
"\n" .
"    auto it = funcs.find( type );\n" .
"\n" .
"    if( it != funcs.end() )\n" .
"        return it->second( r );\n" .
"\n" .
"    return nullptr;\n" .
"}\n" .
"\n" .
"request_type_e  Parser::detect_request_type( const generic_request::Request & r )\n" .
"{\n" .
"    std::string cmd;\n" .
"\n" .
"    if( r.get_value( \"CMD\", cmd ) == false )\n" .
"        throw MalformedRequest( \"CMD is not defined\" );\n" .
"\n" .
"    return RequestTypeParser::to_request_type( cmd );\n" .
"}\n" .
"\n" .
    generate_parser_cpp__to_message( $file_ref )
;

    my $res = to_body( $$file_ref, $body, "", [ "parser", "exported_parser", "validator", "request_type_parser", "basic_parser/malformed_request" ], [ "map" ] );

    return $res;
}

###############################################

1;
