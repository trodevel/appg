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

sub generate_str_helper_h__to_obj_name($)
{
    my ( $name ) = @_;

    return "static std::ostream & write( std::ostream & os, const $name & r );";
}

sub generate_str_helper_h_body_1_core($)
{
    my ( $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_str_helper_h__to_obj_name( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_str_helper_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{enums} );
}

sub generate_str_helper_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{objs} );
}

sub generate_str_helper_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{base_msgs} );
}

sub generate_str_helper_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{msgs} );
}

sub generate_str_helper_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
generate_str_helper_h_body_1( $file_ref ) .
"\n" .
"// objects\n" .
generate_str_helper_h_body_2( $file_ref ) .
"\n" .
"// base messages\n" .
generate_str_helper_h_body_3( $file_ref ) .
"\n" .
"// messages\n" .
generate_str_helper_h_body_4( $file_ref ) .
"\n" .
"template<class T>\n" .
"static std::string to_string( const T & l )\n" .
"{\n" .
"    std::ostringstream os;\n" .
"\n" .
"    write( os, l );\n" .
"\n" .
"    return os.str();\n" .
"}\n" .
"\n";

    $body = gtcpp::namespacize( 'str_helper', $body );

    my $res = to_include_guards( $$file_ref, $body, "", "str_helper", 0, 0, [ "protocol" ], [ "sstream" ] );

    return $res;
}

###############################################


sub generate_str_helper_cpp__to_object__body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"std::ostream & write( std::ostream & os, const $name & r )\n" .
"{\n" .
"    return ::basic_parser::str_helper::write( os, r );\n".
"}\n";

    return $res;
}

sub generate_str_helper_cpp__to_object__core($)
{
    my ( $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_str_helper_cpp__to_object__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_str_helper_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $$file_ref->{objs} );
}

sub generate_str_helper_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $$file_ref->{enums} );
}

sub generate_str_helper_cpp__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $$file_ref->{base_msgs} );
}

sub generate_str_helper_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $$file_ref->{msgs} );
}

sub generate_str_helper_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_str_helper_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_str_helper_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_str_helper_cpp__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_str_helper_cpp__to_message( $file_ref )
;

    $body = gtcpp::namespacize( 'str_helper', $body );

    my $res = to_body( $$file_ref, $body, "",  [ "str_helper", "exported_str_helper" ], [ ] );

    return $res;
}

###############################################

1;
