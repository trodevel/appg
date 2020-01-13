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

require CodeGen_cpp_protocol;
require CodeGen_cpp_enums;
require CodeGen_cpp_parser;
require CodeGen_cpp_request_parser;
require CodeGen_cpp_exported_request_parser;

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
use constant EXPORTED_REQUEST_PARSER_H_FILE     => 'exported_request_parser.h';
use constant EXPORTED_REQUEST_PARSER_CPP_FILE   => 'exported_request_parser.cpp';

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

    write_to_file( generate_exported_request_parser_h( $file_ref ), ${\EXPORTED_REQUEST_PARSER_H_FILE} );

    write_to_file( generate_exported_request_parser_cpp( $file_ref ), ${\EXPORTED_REQUEST_PARSER_CPP_FILE} );
}

###############################################

1;
