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

    my $res = to_include_guards( $$file_ref, $body, "", "parser", 0, 0, [ "enums" ] );

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

    my $res = to_body( $$file_ref, $body, "", [ "parser" ], [ "map" ] );

    return $res;
}

###############################################

1;
