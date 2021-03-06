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

require CodeGen_cpp_protocol;
require CodeGen_cpp_enums;
require CodeGen_cpp_request_type_parser;
require CodeGen_cpp_validator;
require CodeGen_cpp_parser;
require CodeGen_cpp_object_initializer;
require CodeGen_cpp_csv_helper;
require CodeGen_cpp_str_helper;
require CodeGen_cpp_dummy_creator;
require CodeGen_cpp_makefile;
require CodeGen_cpp_example;

###############################################

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

###############################################

use constant PROTOCOL_FILE      => 'protocol.h';
use constant ENUMS_FILE         => 'enums.h';
use constant REQUEST_TYPE_PARSER_H_FILE      => 'request_type_parser.h';
use constant REQUEST_TYPE_PARSER_CPP_FILE    => 'request_type_parser.cpp';
use constant PARSER_H_FILE      => 'parser.h';
use constant PARSER_CPP_FILE    => 'parser.cpp';
use constant VALIDATOR_H_FILE                   => 'validator.h';
use constant VALIDATOR_CPP_FILE                 => 'validator.cpp';
use constant CSV_RESPONSE_ENCODER_H_FILE        => 'csv_helper.h';
use constant CSV_RESPONSE_ENCODER_CPP_FILE      => 'csv_helper.cpp';
use constant OBJECT_INITIALIZER_H_FILE          => 'object_initializer.h';
use constant OBJECT_INITIALIZER_CPP_FILE        => 'object_initializer.cpp';
use constant STR_HELPER_H_FILE                  => 'str_helper.h';
use constant STR_HELPER_CPP_FILE                => 'str_helper.cpp';
use constant MAKEFILE_LIB_FILE                  => 'Makefile.lib.config';
use constant MAKEFILE_APP_FILE                  => 'Makefile.app.config';
use constant MAKEFILE_FILE                      => 'Makefile';
use constant DUMMY_CREATOR_H_FILE               => 'dummy_creator.h';
use constant DUMMY_CREATOR_CPP_FILE             => 'dummy_creator.cpp';
use constant EXAMPLE_FILE                       => 'example.cpp';

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

    write_to_file( generate_request_type_parser_h( $file_ref ), ${\REQUEST_TYPE_PARSER_H_FILE} );

    write_to_file( generate_request_type_parser_cpp( $file_ref ), ${\REQUEST_TYPE_PARSER_CPP_FILE} );

    write_to_file( generate_parser_h( $file_ref ), ${\PARSER_H_FILE} );

    write_to_file( generate_parser_cpp( $file_ref ), ${\PARSER_CPP_FILE} );

    write_to_file( generate_validator_h( $file_ref ), ${\VALIDATOR_H_FILE} );

    write_to_file( generate_validator_cpp( $file_ref ), ${\VALIDATOR_CPP_FILE} );

    write_to_file( generate_csv_helper_h( $file_ref ), ${\CSV_RESPONSE_ENCODER_H_FILE} );

    write_to_file( generate_csv_helper_cpp( $file_ref ), ${\CSV_RESPONSE_ENCODER_CPP_FILE} );

    write_to_file( generate_object_initializer_h( $file_ref ), ${\OBJECT_INITIALIZER_H_FILE} );

    write_to_file( generate_object_initializer_cpp( $file_ref ), ${\OBJECT_INITIALIZER_CPP_FILE} );

    write_to_file( generate_str_helper_h( $file_ref ), ${\STR_HELPER_H_FILE} );

    write_to_file( generate_str_helper_cpp( $file_ref ), ${\STR_HELPER_CPP_FILE} );

    write_to_file( generate_makefile_lib( $file_ref ), ${\MAKEFILE_LIB_FILE} );

    write_to_file( generate_makefile_app( $file_ref ), ${\MAKEFILE_APP_FILE} );

    write_to_file( generate_makefile( $file_ref ), ${\MAKEFILE_FILE} );

    write_to_file( generate_dummy_creator_h( $file_ref ), ${\DUMMY_CREATOR_H_FILE} );

    write_to_file( generate_dummy_creator_cpp( $file_ref ), ${\DUMMY_CREATOR_CPP_FILE} );

    write_to_file( generate_example( $file_ref ), ${\EXAMPLE_FILE} );
}

###############################################

1;
