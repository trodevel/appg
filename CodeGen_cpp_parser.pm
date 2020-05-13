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

sub generate_parser_h__to_obj_name($$)
{
    my ( $name, $is_message ) = @_;

    my $extra_param = ( $is_message == 0 ) ? "const std::string & key, " : "";

    return "void get_value_or_throw( $name * res, ${extra_param}const generic_request::Request & r );";
}

sub generate_parser_h_body_1_core($$)
{
    my ( $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_parser_h__to_obj_name( $_->{name}, $is_message ) . "\n";
    }

    return $res;
}

sub generate_parser_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( $$file_ref->{enums}, 0 );
}

sub generate_parser_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( $$file_ref->{objs}, 0 );
}

sub generate_parser_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( $$file_ref->{base_msgs}, 1 );
}

sub generate_parser_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_parser_h_body_1_core( $$file_ref->{msgs}, 1 );
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

sub generate_parser_cpp__to_enum__body($)
{
    my ( $name ) = @_;

    my $res =

"void get_value_or_throw( ${name} * res, const std::string & key, const generic_request::Request & r )\n" .
"{\n" .
"    uint32_t res_i;\n" .
"\n" .
"    get_value_or_throw( & res_i, key, r );\n" .
"\n" .
"    * res = static_cast<$name>( res_i );\n" .
"}\n";

    return $res;
}

sub generate_parser_cpp__to_message__body__init_members__body($$)
{
    my ( $obj, $is_message ) = @_;

    my $res;

    my $name        = $obj->{name};

    my $key_name    = uc( $name );

    my $key_expr    = ( $is_message == 1 ) ? "\"${key_name}\"" : "key + \".${key_name}\"";

    $res = "    get_value_or_throw( & res->${name}, ${key_expr}, r );";

    return $res;
}

sub generate_parser_cpp__to_message__body__init_members($$)
{
    my ( $msg, $is_message ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_parser_cpp__to_message__body__init_members__body( $_, $is_message ) . "\n";
    }

    return $res;
}

sub generate_parser_cpp__to_body($$)
{
    my ( $msg, $is_message ) = @_;

    my $name = $msg->{name};

    my $extra_param = ( $is_message == 0 ) ? "const std::string & key, " : "";

    my $res =

"void get_value_or_throw( ${name} * res, ${extra_param}const generic_request::Request & r )\n" .
"{\n";

    if( $is_message )
    {
        $res = $res .
"    get_value_or_throw( static_cast<" . $msg->get_base_class() . "*>( res ), r );\n" .
"\n";
    }

    $res = $res .
    generate_parser_cpp__to_message__body__init_members( $msg, $is_message ) .
"}\n";

    return $res;
}

sub generate_parser_cpp__to_object__core($$)
{
    my ( $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_parser_cpp__to_body( $_, $is_message ) . "\n";
    }

    return $res;
}

sub generate_parser_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_parser_cpp__to_enum__body( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_parser_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_parser_cpp__to_object__core( $$file_ref->{objs}, 0 );
}

sub generate_parser_cpp__to_base_msg($)
{
    my ( $file_ref ) = @_;

    return generate_parser_cpp__to_object__core( $$file_ref->{base_msgs}, 1 );
}

sub generate_parser_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_parser_cpp__to_object__core( $$file_ref->{msgs}, 1 );
}

sub generate_parser_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/parser" );
    }

    return @res;
}

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

sub generate_parser_cpp__to_message_2__body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"Object * to_${name}( const generic_request::Request & r )\n" .
"{\n" .
"    auto * res = new $name;\n" .
"\n" .
"    get_value_or_throw( res, r );\n" .
"\n" .
"    validator::validate( * res );\n" .
"\n" .
"    return res;\n" .
"}\n";

    return $res;
}

sub generate_parser_cpp__to_message_2($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_parser_cpp__to_message_2__body( $_ ) . "\n";
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
"// enums\n" .
"\n" .
    generate_parser_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_parser_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_parser_cpp__to_base_msg( $file_ref ) .
"// messages\n" .
"\n" .
    generate_parser_cpp__to_message( $file_ref ) .
"\n" .
"generic_protocol::Object* to_forward_message( const generic_request::Request & r )\n" .
"{\n" .
"    auto type = Parser::detect_request_type( r );\n" .
"\n" .
"    typedef request_type_e KeyType;\n" .
"\n" .
"    typedef Object* (*PPMF)( const generic_request::Request & r );\n" .
"\n" .
"#define HANDLER_MAP_ENTRY(_v)       { KeyType::_v,    & to_##_v }\n" .
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
"request_type_e  detect_request_type( const generic_request::Request & r )\n" .
"{\n" .
"    std::string cmd;\n" .
"\n" .
"    if( r.get_value( \"CMD\", cmd ) == false )\n" .
"        throw MalformedRequest( \"CMD is not defined\" );\n" .
"\n" .
"    return RequestTypeParser::to_request_type( cmd );\n" .
"}\n" .
"\n" .
    generate_parser_cpp__to_message_2( $file_ref )
;

    $body = gtcpp::namespacize( 'parser', $body );

    my @includes = ( "parser" );

    push( @includes, $$file_ref->{base_prot} . "/parser" );

    push( @includes, generate_parser_cpp__to_includes( $file_ref ) );

    push( @includes, "basic_parser/parser" );
    push( @includes, "basic_parser/malformed_request" );
    push( @includes, "validator" );
    push( @includes, "request_type_parser" );

    my $res = to_body( $$file_ref, $body, "", \@includes, [ "map" ] );

    return $res;
}

###############################################

1;
