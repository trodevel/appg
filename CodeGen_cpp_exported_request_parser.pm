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

sub generate_exported_request_parser_h__to_obj_name($$$)
{
    my ( $namespace, $name, $is_request ) = @_;

    my $extra_param = ( $is_request == 0 ) ? "const std::string & key, " : "";

    return "void get_value_or_throw( $namespace::$name * res, ${extra_param}const generic_request::Request & r );";
}

sub generate_exported_request_parser_h_body_1_core($$$)
{
    my ( $namespace, $objs_ref, $is_request ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_request_parser_h__to_obj_name( $namespace, $_->{name}, $is_request ) . "\n";
    }

    return $res;
}

sub generate_exported_request_parser_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{enums}, 0 );
}

sub generate_exported_request_parser_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{objs}, 0 );
}

sub generate_exported_request_parser_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs}, 1 );
}

sub generate_exported_request_parser_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{msgs}, 1 );
}

sub generate_exported_request_parser_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n".
"\n" .
generate_exported_request_parser_h_body_1( $file_ref ) .
"\n" .
"// objects\n".
"\n" .
generate_exported_request_parser_h_body_2( $file_ref ) .
"\n" .
"// base messages\n".
"\n" .
generate_exported_request_parser_h_body_3( $file_ref ) .
"\n" .
"// messages\n".
"\n" .
generate_exported_request_parser_h_body_4( $file_ref ) .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "basic_parser", "exported_request_parser", 0, 0, [ "protocol", "generic_request/request" ], [] );

    return $res;
}

###############################################

sub generate_exported_request_parser_cpp__to_enum__body($$)
{
    my ( $namespace, $name ) = @_;

    my $res =

"void get_value_or_throw( $namespace::${name} * res, const std::string & key, const generic_request::Request & r )\n" .
"{\n" .
"    uint32_t res_i;\n" .
"\n" .
"    get_value_or_throw( & res_i, key, r );\n" .
"\n" .
"    * res = static_cast<$name>( res_i );\n" .
"}\n";

    return $res;
}

sub generate_exported_request_parser_cpp__to_message__body__init_members__body($$)
{
    my ( $obj, $is_request ) = @_;

    my $res;

    my $name        = $obj->{name};

    my $key_name    = uc( $name );

    my $key_expr    = ( $is_request == 1 ) ? "\"${key_name}\"" : "key + \".${key_name}\"";

    $res = "    get_value_or_throw( & res->${name}, ${key_expr}, r );";

    return $res;
}

sub generate_exported_request_parser_cpp__to_message__body__init_members($$)
{
    my ( $msg, $is_request ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_exported_request_parser_cpp__to_message__body__init_members__body( $_, $is_request ) . "\n";
    }

    return $res;
}

sub generate_exported_request_parser_cpp__to_body($$$)
{
    my ( $namespace, $msg, $is_request ) = @_;

    my $name = $msg->{name};

    my $extra_param = ( $is_request == 0 ) ? "const std::string & key, " : "";

    my $res =

"void get_value_or_throw( ${namespace}::${name} * res, ${extra_param}const generic_request::Request & r )\n" .
"{\n";

    if( $is_request )
    {
        $res = $res .
"    get_value_or_throw( static_cast<" . $msg->get_base_class() . "*>( res ), r );\n" .
"\n";
    }

    $res = $res .
    generate_exported_request_parser_cpp__to_message__body__init_members( $msg, $is_request ) .
"}\n";

    return $res;
}

sub generate_exported_request_parser_cpp__to_object__core($$$)
{
    my ( $namespace, $objs_ref, $is_request ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_exported_request_parser_cpp__to_body( $namespace, $_, $is_request ) . "\n";
    }

    return $res;
}

sub generate_exported_request_parser_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_exported_request_parser_cpp__to_enum__body( get_namespace_name( $$file_ref ), $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_exported_request_parser_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_cpp__to_object__core( get_namespace_name( $$file_ref ), $$file_ref->{objs}, 0 );
}

sub generate_exported_request_parser_cpp__to_base_msg($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_cpp__to_object__core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs}, 1 );
}

sub generate_exported_request_parser_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_exported_request_parser_cpp__to_object__core( get_namespace_name( $$file_ref ), $$file_ref->{msgs}, 1 );
}

sub generate_exported_request_parser_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/exported_request_parser" );
    }

    return @res;
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
    generate_exported_request_parser_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_exported_request_parser_cpp__to_base_msg( $file_ref ) .
"// messages\n" .
"\n" .
    generate_exported_request_parser_cpp__to_message( $file_ref )
;

    my @includes = ( "exported_request_parser" );

    push( @includes, generate_exported_request_parser_cpp__to_includes( $file_ref ) );

    push( @includes, "basic_parser/exported_request_parser" );

    my $res = to_body( $$file_ref, $body, "basic_parser", \@includes, [ ] );

    return $res;
}

###############################################

1;
