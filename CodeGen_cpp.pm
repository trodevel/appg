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
            gtcpp::to_include( $file->{name} ) . "    // self\n\n" . $body;
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
    my( $file ) = @_;

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

sub write_to_file($$)
{
    my ( $s, $filename ) = @_;

    open my $FO, ">", $filename;

    print $FO $s;
}

###############################################

sub generate_decl($)
{
    my ( $file_ref ) = @_;

    write_to_file( to_cpp_decl( $$file_ref ) . "\n", ${\PROTOCOL_FILE} );
}

###############################################

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

    write_to_file( $res, ${\ENUMS_FILE} );
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

    write_to_file( $res, ${\PARSER_H_FILE} );
}

###############################################

sub generate_parser_cpp_body($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $res = $res . 'make_inverse_pair( Type:: TUPLE_VAL_STR( ' . $_->{name} . " ) ),\n";
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

    write_to_file( $res, ${\PARSER_CPP_FILE} );
}

###############################################

sub generate($$)
{
    my ( $file_ref, $output_name ) = @_;

    generate_decl( $file_ref );

    generate_enums( $file_ref );

    generate_parser_h( $file_ref );

    generate_parser_cpp( $file_ref );
}

###############################################

1;
