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


sub generate_csv_response_encoder_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"std::ostream & write( std::ostream & os, const generic_protocol::MessageBase & r );\n" .
"std::string to_csv( const generic_protocol::MessageBase & r );\n" .
"\n";

    $body = gtcpp::namespacize( 'csv_response_encoder', $body );

    my $res = to_include_guards( $$file_ref, $body, "", "csv_response_encoder", 0, 0, [ "protocol" ], [ "sstream" ] );

    return $res;
}

###############################################

sub generate_csv_response_encoder_cpp__write__body($)
{
    my $name = shift;

    return "HANDLER_MAP_ENTRY( $name )";
}

sub generate_csv_response_encoder_cpp__write($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_csv_response_encoder_cpp__write__body( $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_csv_response_encoder_cpp__write_message__body($$)
{
    my ( $namespace, $msg ) = @_;

    my $name = $msg->{name};

    my $res =

"std::ostream & write_${name}( std::ostream & os, const generic_protocol::MessageBase & rr )\n" .
"{\n" .
"    auto & r = dynamic_cast< const $namespace::$name &>( rr );\n".
"\n" .
"    return ::basic_parser::csv_encoder::write( os, r );\n" .
"}\n";

    return $res;
}

sub generate_csv_response_encoder_cpp__write_message($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . generate_csv_response_encoder_cpp__write_message__body( get_namespace_name( $$file_ref ), $_ ) . "\n";
    }

    return $res;
}

sub generate_csv_response_encoder_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, "../" . $_ . "/exported_csv_response_encoder" );
    }

    return @res;
}

sub generate_csv_response_encoder_cpp__to_csv()
{
    my $res =
"std::string to_csv( const generic_protocol::MessageBase & r )\n" .
"{\n" .
"    std::ostringstream os;\n" .
"\n" .
"    write( os, l );\n" .
"\n" .
"    return os.str();\n" .
"}\n";

}

sub generate_csv_response_encoder_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

    generate_csv_response_encoder_cpp__write_message( $file_ref ) .
"\n" .
"std::ostream & write( std::ostream & os, const generic_protocol::MessageBase & r )\n" .
"{\n" .
"    typedef std::ostream & (Type::*PPMF)( std::ostream & os,  ); \n" .
"\n" .
"#define HANDLER_MAP_ENTRY(_v)       { typeid( ::" . get_namespace_name( $$file_ref ) . "::_v ),        & ::" . get_namespace_name( $$file_ref ) . "::csv_response_encoder::write_##_v }\n" .
"\n" .
"    static const std::map<std::type_index, PPMF> funcs =\n" .
"    {\n" .

    generate_csv_response_encoder_cpp__write( $file_ref ) .

"    };\n" .
"\n" .
"#undef HANDLER_MAP_ENTRY\n" .
"\n" .
"    auto it = funcs.find( type );\n" .
"\n" .
"    if( it != funcs.end() )\n" .
"        return it->second( os, r );\n" .
"\n" .
"    return ::generic_protocol::csv_response_encoder::write( os, r );\n" .
"}\n" .
"\n" .
    generate_csv_response_encoder_cpp__to_csv() .
"\n"
;

    $body = gtcpp::namespacize( 'csv_response_encoder', $body );

    my $res = to_body( $$file_ref, $body, "", [ "exported_csv_response_encoder", "generic_protocol/csv_response_encoder" ], [ "map" ] );

    return $res;
}

###############################################

1;
