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

sub generate_request_parser_h__to_obj_name($)
{
    my $name = shift;
    return "static void                 get_value_or_throw( $name * res, const std::string & key, const generic_request::Request & r );";
}

sub generate_request_parser_h__to_base_msg_name($)
{
    my $name = shift;
    return "static void                 get_value_or_throw( $name * res, const generic_request::Request & r );";
}

sub generate_request_parser_h_body_1_core($)
{
    my ( $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_request_parser_h__to_obj_name( $_->{name} ) . "\n";
    }

    return main::tabulate( $res );
}

sub generate_request_parser_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_request_parser_h_body_1_core( $$file_ref->{objs} );
}

sub generate_request_parser_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_request_parser_h_body_1_core( $$file_ref->{enums} );
}

sub generate_request_parser_h_body_3($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{base_msgs} } )
    {
        $res = $res . generate_request_parser_h__to_base_msg_name( $_->{name} ) . "\n";
    }

    return main::tabulate( $res );
}

sub generate_request_parser_h__to_msg_name($)
{
    my $name = shift;
    return "static ForwardMessage *     to_" . $name . "( const generic_request::Request & r );";
}

sub generate_request_parser_h_body_4($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_request_parser_h__to_msg_name( $_->{name} ) . "\n";
    }

    return main::tabulate( $res );
}

sub generate_request_parser_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"class RequestParser\n" .
"{\n" .
"public:\n" .
"    typedef basic_parser::MalformedRequest      MalformedRequest;\n" .
"    typedef generic_protocol::ForwardMessage    ForwardMessage;\n" .
"\n" .
"public:\n" .
"\n" .
"    static generic_protocol::ForwardMessage*    to_forward_message( const generic_request::Request & r );\n" .
"\n" .
generate_request_parser_h_body_1( $file_ref ) .
"\n" .
generate_request_parser_h_body_2( $file_ref ) .
"\n" .
generate_request_parser_h_body_3( $file_ref ) .
"\n" .
"private:\n" .
"\n" .
"    static request_type_e   detect_request_type( const generic_request::Request & r );\n" .
"\n" .
generate_request_parser_h_body_4( $file_ref ) .
"\n" .
"};\n";

    my $res = to_include_guards( $$file_ref, $body, "", "request_parser", 0, 0, [ "generic_request/request", "basic_parser/malformed_request", "enums", "protocol" ], [] );

    return $res;
}

###############################################

sub generate_request_parser_cpp__to_forward_message__body($)
{
    my $name = shift;

    return "HANDLER_MAP_ENTRY( $name )";
}

sub generate_request_parser_cpp__to_forward_message($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_request_parser_cpp__to_forward_message__body( $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_request_parser_cpp__to_enum__body($)
{
    my ( $name ) = @_;

    my $res =

"void RequestParser::get_value_or_throw( ${name} * res, const std::string & key, const generic_request::Request & r )\n" .
"{\n" .
"    uint32_t res_i;\n" .
"\n" .
"    basic_parser::get_value_or_throw( & res_i, key, r );\n" .
"\n" .
"    * res = static_cast<$name>( res_i );\n" .
"}\n";

    return $res;
}

sub generate_request_parser_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_request_parser_cpp__to_enum__body( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_request_parser_cpp__to_message__body__init_members__body($$)
{
    my ( $obj, $is_request ) = @_;

    my $res;

    my $name        = $obj->{name};

    my $key_name    = uc( $name );

    my $key_expr    = ( $is_request == 1 ) ? "\"${key_name}\"" : "key + \".${key_name}\"";

    my $func = $obj->{data_type}->to_cpp__to_parse_function_name();

    $res = "    ${func}( & res->${name}, ${key_expr}, r );";

    return $res;
}

sub generate_request_parser_cpp__to_message__body__init_members($$)
{
    my ( $msg, $is_request ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_request_parser_cpp__to_message__body__init_members__body( $_, $is_request ) . "\n";
    }

    return $res;
}

sub generate_request_parser_cpp__to_message__body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"RequestParser::ForwardMessage * RequestParser::to_${name}( const generic_request::Request & r )\n" .
"{\n" .
"    auto * res = new $name;\n" .
"\n" .
"    generic_protocol::RequestParser::to_request( res, r );\n" .
"\n" .
    generate_request_parser_cpp__to_message__body__init_members( $msg, 1 ) .
"\n" .
"    RequestValidator::validate( * res );\n" .
"\n" .
"    return res;\n" .
"}\n";

    return $res;
}

sub generate_request_parser_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_request_parser_cpp__to_message__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_request_parser_cpp__to_object__body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"void RequestParser::get_value_or_throw( ${name} * res, const std::string & key, const generic_request::Request & r )\n" .
"{\n" .
    generate_request_parser_cpp__to_message__body__init_members( $msg, 0 ) .
"}\n";

    return $res;
}

sub generate_request_parser_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{objs} } )
    {
        $res = $res . generate_request_parser_cpp__to_object__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_request_parser_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, "../" . $_ . "/exported_request_parser" );
    }

    return @res;
}

sub generate_request_parser_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"generic_protocol::ForwardMessage* RequestParser::to_forward_message( const generic_request::Request & r )\n" .
"{\n" .
"    auto type = RequestParser::detect_request_type( r );\n" .
"\n" .
"    typedef request_type_e KeyType;\n" .
"    typedef RequestParser Type;\n" .
"\n" .
"    typedef ForwardMessage* (*PPMF)( const generic_request::Request & r );\n" .
"\n" .
"#define HANDLER_MAP_ENTRY(_v)       { KeyType::_v,    & Type::to_##_v }\n" .
"\n" .
"    static const std::map<KeyType, PPMF> funcs =\n" .
"    {\n" .

    generate_request_parser_cpp__to_forward_message( $file_ref ) .

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
"request_type_e  RequestParser::detect_request_type( const generic_request::Request & r )\n" .
"{\n" .
"    std::string cmd;\n" .
"\n" .
"    if( r.get_value( \"CMD\", cmd ) == false )\n" .
"        throw MalformedRequest( \"CMD is not defined\" );\n" .
"\n" .
"    return Parser::to_request_type( cmd );\n" .
"}\n" .
"\n" .
    generate_request_parser_cpp__to_enum( $file_ref ) .
"\n" .
    generate_request_parser_cpp__to_message( $file_ref ) .
"\n" .
    generate_request_parser_cpp__to_object( $file_ref ) .
"\n"
;

    my @includes = ( "parser", "exported_request_parser"  );

    push( @includes, generate_request_parser_cpp__to_includes( $file_ref ) );

    push( @includes, "../basic_parser/get_value" );

    my $res = to_body( $$file_ref, $body, "", \@includes, [ "map" ] );

    return $res;
}

###############################################

1;
