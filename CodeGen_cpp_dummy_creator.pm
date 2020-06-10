#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_cpp.
#
# Copyright (C) 2020 Sergey Kolevatov
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

sub generate_dummy_creator_h__to_name($$)
{
    my ( $file_ref, $obj ) = @_;

    my $name = $obj->{name};

    my $res = "create_dummy__${name}()";

    return $res;
}

sub generate_dummy_creator_h_body_1_core($$)
{
    my ( $file_ref, $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_dummy_creator_h__to_name( $file_ref, $_ ) . ";\n";
    }

    return $res;
}

sub generate_dummy_creator_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_h_body_1_core( $file_ref, $$file_ref->{enums} );
}

sub generate_dummy_creator_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_h_body_1_core( $file_ref, $$file_ref->{objs} );
}

sub generate_dummy_creator_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_h_body_1_core( $file_ref, $$file_ref->{msgs} );
}

sub generate_dummy_creator_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n".
"\n" .
generate_dummy_creator_h_body_1( $file_ref ) .
"\n" .
"// objects\n".
"\n" .
generate_dummy_creator_h_body_2( $file_ref ) .
"\n" .
"// messages\n".
"\n" .
generate_dummy_creator_h_body_4( $file_ref ) .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "", "dummy_creator", 0, 0, [ "protocol" ], [] );

    return $res;
}

###############################################

sub generate_dummy_creator_cpp__to_body__init($)
{
    my ( $params_ref ) = @_;

    my $res = "";

    foreach( @{ $params_ref } )
    {
        $res .= ", " . $_->to_cpp__create_dummy_value() . "()\n";
    }

    return $res;
}

sub generate_dummy_creator_cpp__to_body($$$$)
{
    my ( $file_ref, $msg, $is_enum, $is_message ) = @_;

    my $name = $msg->{name};

    my $res = "";

    if( $is_enum )
    {
        $res .=
"\$res = 0;\n";
    }
    else
    {
        $res .=
"\$res = new ${name};\n";
    }

        $res .=
"\n";
    if( $is_enum )
    {
    }
    else
    {
        my @params = $$file_ref->get_obj_params__by_ref( \$msg );

        $res .= "initialize__${name}( \$res\n";

        $res .= main::tabulate( generate_dummy_creator_cpp__to_body__init( \@params ) );

        $res .= "    );\n";
    }

    $res .=
"return \$res;\n";

    my $func_name = generate_dummy_creator_h__to_name( $file_ref, $msg );

    $res =

"function $func_name\n" .
"{\n" .
        main::tabulate( $res ) .
"}\n";

    return $res;
}

sub generate_dummy_creator_cpp__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_enum, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_dummy_creator_cpp__to_body( $file_ref, $_, $is_enum, $is_message ) . "\n";
    }

    return $res;
}

sub generate_dummy_creator_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_cpp__to_object__core( $file_ref, $$file_ref->{enums}, 1, 0 );
}

sub generate_dummy_creator_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_cpp__to_object__core( $file_ref, $$file_ref->{objs}, 0, 0 );
}

sub generate_dummy_creator_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_cpp__to_object__core( $file_ref, $$file_ref->{msgs}, 0, 1 );
}

sub generate_dummy_creator_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_dummy_creator_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_dummy_creator_cpp__to_object( $file_ref ) .
"// messages\n" .
"\n" .
    generate_dummy_creator_cpp__to_message( $file_ref )
;

    my @includes = ( );

    push( @includes, "basic_parser/dummy_creator" );
    push( @includes, "object_initializer" );

    my $res = to_body( $$file_ref, $body, "", \@includes, [ ] );

    return $res;
}

###############################################

1;
