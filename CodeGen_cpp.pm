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


use constant PROTOCOL_FILE      => 'protocol.h';
use constant ENUMS_FILE         => 'enums.h';
use constant PARSER_H_FILE      => 'parser.h';
use constant PARSER_CPP_FILE    => 'parser.cpp';
use constant REQUEST_PARSER_H_FILE      => 'request_parser.h';
use constant REQUEST_PARSER_CPP_FILE    => 'request_parser.cpp';

###############################################

sub get_namespace_name($)
{
    my( $file ) = @_;

    return $file->{name} . "_protocol";
}

###############################################

sub namespacize($$)
{
    my( $file, $body ) = @_;

    my $res = gtcpp::namespacize( get_namespace_name( $file ), $body );

    if( $file->{must_use_ns} )
    {
        $res = gtcpp::namespacize( 'apg', $res );
    }

    return $res;
}

############################################################

sub to_include_guards($$$$$$)
{
    my( $file, $body, $prefix, $must_include_myself, $must_include_userdef, $other_incl_ref ) = @_;

    $body = namespacize( $file, $body );

    if( defined $must_include_myself && $must_include_myself == 1 )
    {
        $body =
            gtcpp::to_include( $file->{name}, 0 ) . "    // self\n\n" . $body;
    }

    if( defined $must_include_userdef && $must_include_userdef == 1 )
    {
        my @includes  = @{ $file->{includes} };     # includes

        $body = "// includes\n" .
            gtcpp::array_to_include( \@includes, 0 ) . "\n" . $body;
    }

    if( defined $other_incl_ref && scalar @$other_incl_ref > 0 )
    {
        $body = "// includes\n" .
            gtcpp::array_to_include( $other_incl_ref, 0 ) . "\n" . $body;
    }

    my $res = gtcpp::ifndef_define_prot( $file->{name}, $prefix, $body );

    return $res;
}

############################################################

sub to_body($$$$)
{
    my( $file, $body, $other_incl_ref, $system_incl_ref ) = @_;

    $body = namespacize( $file, $body );

    if( defined $other_incl_ref && scalar @$other_incl_ref > 0 )
    {
        $body = "// includes\n" .
            gtcpp::array_to_include( $other_incl_ref, 0 ) . "\n" . $body;
    }

    if( defined $system_incl_ref && scalar @$system_incl_ref > 0 )
    {
        $body = "// system includes\n" .
            gtcpp::array_to_include( $system_incl_ref, 1 ) . "\n" . $body;
    }

    return $body;
}

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

    my $res = to_include_guards( $file, $body, "decl", 0, 1, [] );

    $res = $res . "\n";

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
    my( $file ) = @_;

    my @res;

    push( @res, @{ $file->{enums} } );
    push( @res, @{ get_enums_from_object_list( $file->{objs} ) } );
    push( @res, @{ get_enums_from_object_list( $file->{base_msgs} ) } );
    push( @res, @{ get_enums_from_object_list( $file->{msgs} ) } );

    return \@res;
}

############################################################

sub generate_enums($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body = "enum class request_type_e\n";

    my $msgs = "UNDEF,\n";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $msgs = $msgs . $_->{name} . ",\n";
    }

    $body = $body . main::bracketize( $msgs, 1 ) . "\n";

    my $res = to_include_guards( $$file_ref, $body, "enums", 0, 0, [] );

    return $res;
}

###############################################

sub generate_parser_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"class Parser\n" .
"{\n" .
"public:\n" .
"    static request_type_e   to_request_type( const std::string & s );\n" .
"};\n";

    my $res = to_include_guards( $$file_ref, $body, "parser", 0, 0, [ "enums" ] );

    return $res;
}

###############################################

sub generate_parser_cpp_body__to_make_pair($)
{
    my $name = shift;

    return "make_inverse_pair( Type:: TUPLE_VAL_STR( $name ) )";
}

sub generate_parser_cpp_body($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_parser_cpp_body__to_make_pair( $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_parser_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

'#define TUPLE_VAL_STR(_x_)  _x_,"' . $$file_ref->{name} . '/"' . "+std::string(#_x_)\n" .
"\n" .
"template< typename _U, typename _V >\n" .
"std::pair<_V,_U> make_inverse_pair( _U first, _V second )\n" .
"{\n" .
"    return std::make_pair( second, first );\n" .
"}\n" .
"\n" .
"request_type_e Parser::to_request_type( const std::string & s )\n" .
"{\n" .
"    typedef std::string KeyType;\n" .
"    typedef request_type_e Type;\n" .
"\n" .
"    typedef std::map< KeyType, Type > Map;\n" .
"    static const Map m =\n" .
"    {\n" .
    generate_parser_cpp_body( $file_ref ) .

"    };\n" .
"\n" .
"    auto it = m.find( s );\n" .
"\n" .
"    if( it == m.end() )\n" .
"        return request_type_e::UNDEF;\n" .
"\n" .
"    return it->second;\n" .
"}\n";

    my $res = to_body( $$file_ref, $body, [ "parser" ], [ "map" ] );

    return $res;
}

###############################################

sub generate_request_parser_h__to_obj_name($)
{
    my $name = shift;
    return "static void                 get_value_or_throw( $name * res, const std::string & key, const generic_request::Request & r )";
}

sub generate_request_parser_h__to_base_msg_name($)
{
    my $name = shift;
    return "static void                 get_value_or_throw( $name * res, const generic_request::Request & r )";
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

    my $res = to_include_guards( $$file_ref, $body, "request_parser", 0, 0, [ "generic_request/request", "basic_parser/malformed_request", "enums", "protocol" ] );

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
"    get_value_or_throw( & res_i, key, r );\n" .
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

sub generate_request_parser_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"using basic_parser::get_value_or_throw;\n" .
"using basic_parser::get_value_or_throw_uint32;\n" .
"using basic_parser::get_value_or_throw_double;\n" .
"\n" .
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

    my $res = to_body( $$file_ref, $body, [ "parser" ], [ "map" ] );

    return $res;
}

###############################################

sub write_to_file($$)
{
    my ( $s, $filename ) = @_;

    open my $FO, ">", $filename;

    print $FO $s;
}

###############################################

sub generate($$)
{
    my ( $file_ref, $output_name ) = @_;

    write_to_file( to_cpp_decl( $file_ref ), ${\PROTOCOL_FILE} );

    write_to_file( generate_enums( $file_ref ), ${\ENUMS_FILE} );

    write_to_file( generate_parser_h( $file_ref ), ${\PARSER_H_FILE} );

    write_to_file( generate_parser_cpp( $file_ref ), ${\PARSER_CPP_FILE} );

    write_to_file( generate_request_parser_h( $file_ref ), ${\REQUEST_PARSER_H_FILE} );

    write_to_file( generate_request_parser_cpp( $file_ref ), ${\REQUEST_PARSER_CPP_FILE} );
}

###############################################

1;
