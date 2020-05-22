#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_php.
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
require Objects_php;
require "gen_tools_php.pl";

###############################################

package CodeGen_php;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_object_initializer_h__to_name_members($$)
{
    my ( $obj, $is_create ) = @_;

    my $res = "";

    my $must_put_comma = $is_create ? 0 : 1;

    foreach( @{ $obj->{members} } )
    {
        $res .= ( $must_put_comma ? ", " : "" ) . $_->{data_type}->to_php_func_param() . " \$" . $_->{name} . " // " . $_->{data_type}->to_php_decl() . "\n";

        if( $must_put_comma == 0 )
        {
            $must_put_comma = 1;
        }
    }

    return $res;
}

sub generate_object_initializer_h__to_name__name($$)
{
    my ( $obj, $is_create ) = @_;

    my $name = $obj->{name};

    my $res = $is_create ?

"create__${name}(" :
"initialize__${name}( & \$res";

    return $res;
}

sub generate_object_initializer_h__to_name($$)
{
    my ( $obj, $is_create ) = @_;

    my $res = generate_object_initializer_h__to_name__name( $obj, $is_create );

    my $params = generate_object_initializer_h__to_name_members( $obj, $is_create );

    if( $params ne "" )
    {
        $res .= "\n" . main::tabulate( $params );
    }

    $res .= " )";

    return $res;
}

sub generate_object_initializer_h_body_1_core($$)
{
    my ( $objs_ref, $is_create ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_h__to_name( $_, $is_create ) . ";\n";
    }

    return $res;
}

sub generate_object_initializer_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{objs}, 0 );
}

sub generate_object_initializer_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{base_msgs}, 0 );
}

sub generate_object_initializer_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{msgs}, 0 );
}

sub generate_object_initializer_h_body_5($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $$file_ref->{msgs}, 1 );
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
"\n" .
"// messages (constructors)\n".
"\n" .
generate_object_initializer_h_body_5( $file_ref ) .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "", "object_initializer", 0, 0, [ "protocol" ], [] );

    return $res;
}

###############################################

sub generate_object_initializer_php__to_message__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

    $res = "    \$res->${name} = \$${name};";

    return $res;
}

sub generate_object_initializer_php__to_message__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_object_initializer_php__to_message__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_php__to_message__body__call_init__body($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res .= ", \$" . $_->{name};
    }

    return $res;
}

sub generate_object_initializer_php__to_message__body__call_init($)
{
    my ( $msg ) = @_;

    my $name = $msg->{name};

    my $res =
"\$res = new ${name};\n" .
"\n" .
"initialize__${name}( \$res" . generate_object_initializer_php__to_message__body__call_init__body( $msg ) . " );\n" .
"\n";

    $res .= "return \$res;\n";

    return main::tabulate( $res );
}

sub generate_object_initializer_php__to_body($$)
{
    my ( $msg, $is_create ) = @_;

    my $func_name = generate_object_initializer_h__to_name( $msg, $is_create );

    my $res =

"function $func_name\n" .
"{\n";

    $res .=
        $is_create ?
        generate_object_initializer_php__to_message__body__call_init( $msg ) :
        generate_object_initializer_php__to_message__body__init_members( $msg );

    $res .=
"}\n";

    return $res;
}

sub generate_object_initializer_php__to_object__core($$)
{
    my ( $objs_ref, $is_create ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_php__to_body( $_, $is_create ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $$file_ref->{objs}, 0 );
}

sub generate_object_initializer_php__to_base_msg($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $$file_ref->{base_msgs}, 0 );
}

sub generate_object_initializer_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $$file_ref->{msgs}, 0 );
}

sub generate_object_initializer_php__to_message_ctor($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $$file_ref->{msgs}, 1 );
}

sub generate_object_initializer_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// objects\n" .
"\n" .
    generate_object_initializer_php__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_object_initializer_php__to_base_msg( $file_ref ) .
"// messages\n" .
"\n" .
    generate_object_initializer_php__to_message( $file_ref ) .
"// messages (constructors)\n" .
"\n" .
    generate_object_initializer_php__to_message_ctor( $file_ref )
;

    my @includes = ( );

    my $res = to_body( $$file_ref, $body, "", \@includes, [ ] );

    return $res;
}

###############################################

1;
