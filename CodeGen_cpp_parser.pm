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

sub generate_parser_h__to_obj_name($$$)
{
    my ( $namespace, $name, $is_message ) = @_;

    my $extra_param = ( $is_message == 0 ) ? "const std::string & key, " : "";

    return "void get_value_or_throw( $namespace::$name * res, ${extra_param}const generic_request::Request & r );";
}

sub generate_parser_h_body_1_core($$$)
{
    my ( $namespace, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_parser_h__to_obj_name( $namespace, $_->{name}, $is_message ) . "\n";
    }

    return $res;
}

sub generate_parser_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{enums}, 0 );
}

sub generate_parser_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{objs}, 0 );
}

sub generate_parser_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs}, 1 );
}

sub generate_parser_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{msgs}, 1 );
}

sub generate_parser_h__to_msg_name($)
{
    my $name = shift;
    return "Object * to_" . $name . "( const generic_request::Request & r );";
}

sub generate_parser_h_body_5($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res .= generate_parser_h__to_msg_name( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_parser_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"typedef generic_protocol::Object    Object;\n" .
"\n" .
"generic_protocol::Object * to_forward_message( const generic_request::Request & r );\n" .
"\n" .
"request_type_e detect_request_type( const generic_request::Request & r );\n" .
"\n" .
"// enums\n".
"\n" .
generate_parser_h_body_1( $file_ref ) .
"\n" .
"// objects\n".
"\n" .
generate_parser_h_body_2( $file_ref ) .
"\n" .
"// base messages\n".
"\n" .
generate_parser_h_body_3( $file_ref ) .
"\n" .
"// messages\n".
"\n" .
generate_parser_h_body_4( $file_ref ) .
"\n" .
"// to_... functions\n".
"\n" .
generate_parser_h_body_5( $file_ref ) .
"\n";

    $body = gtcpp::namespacize( 'parser', $body );

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

    my $res = to_body( $$file_ref, $body, "", [ "parser", "validator", "request_type_parser", "basic_parser/malformed_request" ], [ "map" ] );

    return $res;
}

###############################################

1;
