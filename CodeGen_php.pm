#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_php.
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
# SKV 20303

# 1.0 - 20303 - initial commit

###############################################

require CodeGen_php_protocol;
#require CodeGen_php_enums;
#require CodeGen_php_request_type_parser;
#require CodeGen_php_exported_parser;
#require CodeGen_php_exported_csv_helper;
#require CodeGen_php_exported_validator;
#require CodeGen_php_parser;
require CodeGen_php_object_initializer;
#require CodeGen_php_csv_helper;
require CodeGen_php_str_helper;
#require CodeGen_php_makefile;
#require CodeGen_php_example;
#
###############################################

package CodeGen_php;

use strict;
use warnings;
use 5.010;

###############################################

use constant PROTOCOL_FILE      => 'protocol.php';
use constant ENUMS_FILE         => 'enums.h';
use constant REQUEST_TYPE_PARSER_PHP_FILE      => 'request_type_parser.h';
use constant REQUEST_TYPE_PARSER_CPP_FILE    => 'request_type_parser.cpp';
use constant PARSER_PHP_FILE      => 'parser.h';
use constant PARSER_CPP_FILE    => 'parser.cpp';
use constant EXPORTED_PARSER_PHP_FILE     => 'exported_parser.h';
use constant EXPORTED_PARSER_CPP_FILE   => 'exported_parser.cpp';
use constant EXPORTED_CSV_HELPER_PHP_FILE        => 'exported_csv_helper.h';
use constant EXPORTED_CSV_HELPER_CPP_FILE      => 'exported_csv_helper.cpp';
use constant EXPORTED_VALIDATOR_PHP_FILE          => 'exported_validator.h';
use constant EXPORTED_VALIDATOR_CPP_FILE        => 'exported_validator.cpp';
use constant CSV_RESPONSE_ENCODER_PHP_FILE        => 'csv_helper.h';
use constant CSV_RESPONSE_ENCODER_CPP_FILE      => 'csv_helper.cpp';
use constant OBJECT_INITIALIZER_PHP_FILE          => 'object_initializer.php';
use constant OBJECT_INITIALIZER_CPP_FILE        => 'object_initializer.cpp';
use constant STR_HELPER_PHP_FILE                => 'str_helper.php';
use constant MAKEFILE_LIB_FILE                  => 'Makefile.lib.config';
use constant MAKEFILE_APP_FILE                  => 'Makefile.app.config';
use constant MAKEFILE_FILE                      => 'Makefile';
use constant EXAMPLE_FILE                       => 'example.cpp';

###############################################

sub write_to_file($$)
{
    my ( $s, $filename ) = @_;

    open my $FO, ">", $filename;

    print $FO $s;
}

###############################################

sub generate($)
{
    my ( $file_ref ) = @_;

    write_to_file( to_php_decl( $file_ref ), ${\PROTOCOL_FILE} );

#    write_to_file( generate_enums( $file_ref ), ${\ENUMS_FILE} );

#    write_to_file( generate_request_type_parser_h( $file_ref ), ${\REQUEST_TYPE_PARSER_PHP_FILE} );

#    write_to_file( generate_request_type_parser_cpp( $file_ref ), ${\REQUEST_TYPE_PARSER_CPP_FILE} );

#    write_to_file( generate_parser_h( $file_ref ), ${\PARSER_PHP_FILE} );

#    write_to_file( generate_parser_cpp( $file_ref ), ${\PARSER_CPP_FILE} );

#    write_to_file( generate_exported_parser_h( $file_ref ), ${\EXPORTED_PARSER_PHP_FILE} );

#    write_to_file( generate_exported_parser_cpp( $file_ref ), ${\EXPORTED_PARSER_CPP_FILE} );

#    write_to_file( generate_exported_csv_helper_h( $file_ref ), ${\EXPORTED_CSV_HELPER_PHP_FILE} );

#    write_to_file( generate_exported_csv_helper_cpp( $file_ref ), ${\EXPORTED_CSV_HELPER_CPP_FILE} );

#    write_to_file( generate_exported_validator_h( $file_ref ), ${\EXPORTED_VALIDATOR_PHP_FILE} );

#    write_to_file( generate_exported_validator_cpp( $file_ref ), ${\EXPORTED_VALIDATOR_CPP_FILE} );

#    write_to_file( generate_csv_helper_h( $file_ref ), ${\CSV_RESPONSE_ENCODER_PHP_FILE} );

#    write_to_file( generate_csv_helper_cpp( $file_ref ), ${\CSV_RESPONSE_ENCODER_CPP_FILE} );

    write_to_file( generate_object_initializer_php( $file_ref ), ${\OBJECT_INITIALIZER_PHP_FILE} );

#    write_to_file( generate_object_initializer_cpp( $file_ref ), ${\OBJECT_INITIALIZER_CPP_FILE} );

    write_to_file( generate_str_helper_php( $file_ref ), ${\STR_HELPER_PHP_FILE} );

#    write_to_file( generate_makefile_lib( $file_ref ), ${\MAKEFILE_LIB_FILE} );

#    write_to_file( generate_makefile_app( $file_ref ), ${\MAKEFILE_APP_FILE} );

#    write_to_file( generate_makefile( $file_ref ), ${\MAKEFILE_FILE} );

#    write_to_file( generate_example( $file_ref ), ${\EXAMPLE_FILE} );
}

###############################################

1;
