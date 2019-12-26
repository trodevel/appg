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

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

###############################################

use constant PROTOCOL_FILE      => 'protocol.h';
use constant ENUMS_FILE         => 'enums.h';
use constant PARSER_H_FILE      => 'parser.h';

###############################################

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

    write_to_file( $$file_ref->to_cpp_decl() . "\n", ${\PROTOCOL_FILE} );
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

    my $res = $$file_ref->to_include_guards( $body, "enums" );

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

    my $res = $$file_ref->to_include_guards( $body, "parser" );

    write_to_file( $res, ${\PARSER_H_FILE} );
}

###############################################

sub generate($$)
{
    my ( $file_ref, $output_name ) = @_;

    generate_decl( $file_ref );

    generate_enums( $file_ref );

    generate_parser_h( $file_ref );
}

###############################################

1;
