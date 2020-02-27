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

sub generate_object_initializer_h__to_obj_name($$$)
{
    my ( $namespace, $name, $is_message ) = @_;

    my $extra_param = ( $is_message == 0 ) ? "const std::string & key, " : "";

    return "void initialize( $namespace::$name * res, ${extra_param}const generic_request::Request & r );";
}

sub generate_object_initializer_h_body_1_core($$$)
{
    my ( $namespace, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_h__to_obj_name( $namespace, $_->{name}, $is_message ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{enums}, 0 );
}

sub generate_object_initializer_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{objs}, 0 );
}

sub generate_object_initializer_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs}, 1 );
}

sub generate_object_initializer_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( get_namespace_name( $$file_ref ), $$file_ref->{msgs}, 1 );
}

sub generate_object_initializer_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// objects\n".
"\n" .
generate_object_initializer_h_body_2( $file_ref ) .
"\n" .
"// base messages\n".
"\n" .
generate_object_initializer_h_body_3( $file_ref ) .
"\n" .
"// messages\n".
"\n" .
generate_object_initializer_h_body_4( $file_ref ) .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "", "object_initializer", 0, 0, [ "protocol" ], [] );

    return $res;
}

###############################################

sub generate_object_initializer_cpp__to_enum__body($$)
{
    my ( $namespace, $name ) = @_;

    my $res =

"void initialize( $namespace::${name} * res, const std::string & key, const generic_request::Request & r )\n" .
"{\n" .
"    uint32_t res_i;\n" .
"\n" .
"    initialize( & res_i, key, r );\n" .
"\n" .
"    * res = static_cast<$name>( res_i );\n" .
"}\n";

    return $res;
}

sub generate_object_initializer_cpp__to_message__body__init_members__body($$)
{
    my ( $obj, $is_message ) = @_;

    my $res;

    my $name        = $obj->{name};

    $res = "    res->${name} = ${name};";

    return $res;
}

sub generate_object_initializer_cpp__to_message__body__init_members($$)
{
    my ( $msg, $is_message ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_object_initializer_cpp__to_message__body__init_members__body( $_, $is_message ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_cpp__to_name($)
{
    my ( $obj ) = @_;

    my $name = $obj->{name};

    my $res =

"void initialize( ${name} * res";

    foreach( @{ $obj->{members} } )
    {
        $res .= "\n, " . $_->{data_type}->to_cpp_decl() . " " . $_->{name};
    }

    $res .= " )";

    return $res;
}

sub generate_object_initializer_cpp__to_body($$$)
{
    my ( $namespace, $msg, $is_message ) = @_;

    my $name = $msg->{name};

    my $extra_param = ( $is_message == 0 ) ? "const std::string & key, " : "";

    my $func_name = generate_object_initializer_cpp__to_name( $msg );

    my $res =

"$func_name\n" .
"{\n";

    if( $is_message )
    {
        $res = $res .
"    //initialize( static_cast<" . $msg->get_base_class() . "*>( res ), r );\n" .
"\n";
    }

    $res = $res .
    generate_object_initializer_cpp__to_message__body__init_members( $msg, $is_message ) .
"}\n";

    return $res;
}

sub generate_object_initializer_cpp__to_object__core($$$)
{
    my ( $namespace, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_cpp__to_body( $namespace, $_, $is_message ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_object_initializer_cpp__to_enum__body( get_namespace_name( $$file_ref ), $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_cpp__to_object__core( get_namespace_name( $$file_ref ), $$file_ref->{objs}, 0 );
}

sub generate_object_initializer_cpp__to_base_msg($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_cpp__to_object__core( get_namespace_name( $$file_ref ), $$file_ref->{base_msgs}, 1 );
}

sub generate_object_initializer_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_cpp__to_object__core( get_namespace_name( $$file_ref ), $$file_ref->{msgs}, 1 );
}

sub generate_object_initializer_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/object_initializer" );
    }

    return @res;
}

sub generate_object_initializer_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// objects\n" .
"\n" .
    generate_object_initializer_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_object_initializer_cpp__to_base_msg( $file_ref ) .
"// messages\n" .
"\n" .
    generate_object_initializer_cpp__to_message( $file_ref )
;

    my @includes = ( "object_initializer" );

    push( @includes, $$file_ref->{base_prot} . "/object_initializer" );

    push( @includes, generate_object_initializer_cpp__to_includes( $file_ref ) );

    my $res = to_body( $$file_ref, $body, "", \@includes, [ ] );

    return $res;
}

###############################################

1;
