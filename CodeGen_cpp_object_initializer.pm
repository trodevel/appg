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

sub generate_object_initializer_h__to_name_members($)
{
    my ( $obj ) = @_;

    my $res = "";

    foreach( @{ $obj->{members} } )
    {
        $res .= ", " . $_->{data_type}->to_cpp_func_param() . " " . $_->{name} . "\n";
    }

    return $res;
}

sub generate_object_initializer_h__to_name($)
{
    my ( $obj ) = @_;

    my $name = $obj->{name};

    my $res =

"void initialize( ${name} * res";

    my $params = generate_object_initializer_h__to_name_members( $obj );

    if( $params ne "" )
    {
        $res .= "\n" . main::tabulate( $params );
    }

    $res .= " )";

    return $res;
}

sub generate_object_initializer_h_body_1_core($)
{
    my ( $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_h__to_name( $_ ) . ";\n";
    }

    return $res;
}
sub generate_object_initializer_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{objs} );
}

sub generate_object_initializer_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{base_msgs} );
}

sub generate_object_initializer_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{msgs} );
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

sub generate_object_initializer_cpp__to_message__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

    $res = "    res->${name} = ${name};";

    return $res;
}

sub generate_object_initializer_cpp__to_message__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_object_initializer_cpp__to_message__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_cpp__to_body($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $func_name = generate_object_initializer_h__to_name( $msg );

    my $res =

"$func_name\n" .
"{\n";

    $res = $res .
    generate_object_initializer_cpp__to_message__body__init_members( $msg ) .
"}\n";

    return $res;
}

sub generate_object_initializer_cpp__to_object__core($)
{
    my ( $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_cpp__to_body( $_ ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_object_initializer_cpp__to_enum__body( $_->{name} ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_cpp__to_object__core( $$file_ref->{objs} );
}

sub generate_object_initializer_cpp__to_base_msg($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_cpp__to_object__core( $$file_ref->{base_msgs} );
}

sub generate_object_initializer_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_cpp__to_object__core( $$file_ref->{msgs}  );
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

    my $res = to_body( $$file_ref, $body, "", \@includes, [ ] );

    return $res;
}

###############################################

1;
