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

sub generate_object_initializer_h__base_params($$)
{
    my ( $is_create, $base_params_ref ) = @_;

    my $res = "";

    if( scalar @{ $base_params_ref } == 0 )
    {
        return $res;
    }

    if( $is_create == 0 )
    {
        $res .= ", ";
    }

    my $i = 1;

    foreach( @{ $base_params_ref } )
    {
        if( $i > 1 )
        {
            $res .= ", ";
        }

        $res .= "\$base_class_param_" . $i . " // " . $_->to_php_decl() . "\n";

        $i++;
    }

    return $res;
}

sub generate_object_initializer_h__to_name_members($$$)
{
    my ( $obj, $is_create, $base_params_ref ) = @_;

    my $res = generate_object_initializer_h__base_params( $is_create, $base_params_ref );

    foreach( @{ $obj->{members} } )
    {
        if( $res ne '' or $is_create == 0 )
        {
            $res .= ", ";
        }

        $res .= "\$" . $_->{name} . " // " . $_->{data_type}->to_php_decl() . "\n";
    }

    return $res;
}

sub generate_object_initializer_h__to_name__name($$$)
{
    my ( $obj, $is_create, $is_message ) = @_;

    my $name = $obj->{name};

    my $res = $is_create ?

"create__${name}(" :
"initialize__${name}( & \$res";

    $res .= "\n";

    return $res;
}

sub generate_object_initializer_h__to_name($$$$)
{
    my ( $file_ref, $obj, $is_create, $is_message ) = @_;

    my @base_params;

    if( defined $obj->{base_class} )
    {
        @base_params = $$file_ref->get_base_msg_params( $obj->{base_class} );

        my $num_params = scalar @base_params;

        print STDERR "generate: $obj->{name} $obj->{base_class} params $num_params\n";
    }

    my $res = generate_object_initializer_h__to_name__name( $obj, $is_create, $is_message );

    my $params = generate_object_initializer_h__to_name_members( $obj, $is_create, \@base_params );

    if( $params ne "" )
    {
        $res .= main::tabulate( $params );
    }

    $res .= " )";

    return $res;
}

sub generate_object_initializer_h_body_1_core($$$$)
{
    my ( $file_ref, $objs_ref, $is_create, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_h__to_name( $file_ref, $_, $is_create, $is_message ) . ";\n";
    }

    return $res;
}

sub generate_object_initializer_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $file_ref, $$file_ref->{objs}, 0, 0 );
}

sub generate_object_initializer_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $file_ref, $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_object_initializer_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $file_ref, $$file_ref->{msgs}, 0, 1 );
}

sub generate_object_initializer_h_body_5($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_h_body_1_core( $file_ref, $$file_ref->{msgs}, 1, 1 );
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

sub generate_object_initializer_php__base_params($);

sub generate_object_initializer_php__to_message__body__call_init($$)
{
    my ( $msg, $base_params_ref ) = @_;

    my $name = $msg->{name};

    my $res =
"\$res = new ${name};\n" .
"\n" .
"initialize__${name}( \$res" .
        generate_object_initializer_php__base_params( $base_params_ref ) .
        generate_object_initializer_php__to_message__body__call_init__body( $msg ) . " );\n" .
"\n";

    $res .= "return \$res;\n";

    return main::tabulate( $res );
}

sub generate_object_initializer_php__base_params($)
{
    my ( $base_params_ref ) = @_;

    my $res = "";

    my $i = 1;

    foreach( @{ $base_params_ref } )
    {
        $res .= ", \$base_class_param_" . $i;

        $i++;
    }

    return $res;
}

sub generate_object_initializer_php__to_body($$$$)
{
    my ( $file_ref, $msg, $is_create, $is_message ) = @_;

    my @base_params;

    if( defined $msg->{base_class} )
    {
        @base_params = $$file_ref->get_base_msg_params( $msg->{base_class} );

        my $num_params = scalar @base_params;

        print STDERR "generate: $msg->{name} $msg->{base_class} params $num_params\n";
    }

    my $func_name = generate_object_initializer_h__to_name( $file_ref, $msg, $is_create, $is_message );

    my $res =

"function $func_name\n" .
"{\n";

    if( $is_message and $is_create == 0 )
    {
        $res .=
"    // base class\n" .
"    " . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "initialize_" ) . "( \$res" . generate_object_initializer_php__base_params( \@base_params ) . " );\n" .
"\n";
    }


    $res .=
        $is_create ?
        generate_object_initializer_php__to_message__body__call_init( $msg, \@base_params ) :
        generate_object_initializer_php__to_message__body__init_members( $msg );

    $res .=
"}\n";

    return $res;
}

sub generate_object_initializer_php__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_create, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_object_initializer_php__to_body( $file_ref, $_, $is_create, $is_message ) . "\n";
    }

    return $res;
}

sub generate_object_initializer_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $file_ref, $$file_ref->{objs}, 0, 0 );
}

sub generate_object_initializer_php__to_base_msg($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $file_ref, $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_object_initializer_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $file_ref, $$file_ref->{msgs}, 0, 1 );
}

sub generate_object_initializer_php__to_message_ctor($)
{
    my ( $file_ref ) = @_;

    return generate_object_initializer_php__to_object__core( $file_ref, $$file_ref->{msgs}, 1, 1 );
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
