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

sub generate_dummy_creator_h__to_name($$)
{
    my ( $file_ref, $obj ) = @_;

    my $name = $obj->{name};

    my $res = "create_dummy__${name}()";

    return $res;
}

sub generate_dummy_creator_h_body_1_core($$)
{
    my ( $file_ref, $objs_ref ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_dummy_creator_h__to_name( $file_ref, $_ ) . ";\n";
    }

    return $res;
}

sub generate_dummy_creator_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_h_body_1_core( $file_ref, $$file_ref->{objs} );
}

sub generate_dummy_creator_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_h_body_1_core( $file_ref, $$file_ref->{msgs} );
}

sub generate_dummy_creator_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// objects\n".
"\n" .
generate_dummy_creator_h_body_2( $file_ref ) .
"\n" .
"// messages\n".
"\n" .
generate_dummy_creator_h_body_4( $file_ref ) .
"\n";

    my $res = to_include_guards( $$file_ref, $body, "", "dummy_creator", 0, 0, [ "protocol" ], [] );

    return $res;
}

###############################################

sub generate_dummy_creator_php__to_message__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

    $res = "    \$res->${name} = \$${name};";

    return $res;
}

sub generate_dummy_creator_php__to_message__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_dummy_creator_php__to_message__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_dummy_creator_php__to_message__body__call_init__body($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res .= ", \$" . $_->{name};
    }

    return $res;
}

sub generate_dummy_creator_php__base_params($);

sub generate_dummy_creator_php__to_message__body__call_init($$)
{
    my ( $msg, $base_params_ref ) = @_;

    my $name = $msg->{name};

    my $res =
"\$res = new ${name};\n" .
"\n" .
"initialize__${name}( \$res" .
        generate_dummy_creator_php__base_params( $base_params_ref ) .
        generate_dummy_creator_php__to_message__body__call_init__body( $msg ) . " );\n" .
"\n";

    $res .= "return \$res;\n";

    return main::tabulate( $res );
}

sub generate_dummy_creator_php__base_params($)
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

sub generate_dummy_creator_php__to_body($$$$)
{
    my ( $file_ref, $msg, $is_enum, $is_message ) = @_;

    my @base_params;

    if( defined $msg->{base_class} )
    {
        @base_params = $$file_ref->get_base_msg_params( $msg->{base_class} );

        my $num_params = scalar @base_params;

        print STDERR "generate: $msg->{name} $msg->{base_class} params $num_params\n";
    }

    my $func_name = generate_dummy_creator_h__to_name( $file_ref, $msg );

    my $res =

"function $func_name\n" .
"{\n";

    if( $is_message and $is_create == 0 )
    {
        if( $msg->has_base_class() )
        {
            $res .=
"    // base class\n" .
"    " . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "initialize_" ) . "( \$res" . generate_dummy_creator_php__base_params( \@base_params ) . " );\n" .
"\n";
        }
        else
        {
            $res .=
"    // no base class\n";
        }
    }


    $res .=
        $is_create ?
        generate_dummy_creator_php__to_message__body__call_init( $msg, \@base_params ) :
        generate_dummy_creator_php__to_message__body__init_members( $msg );

    $res .=
"}\n";

    return $res;
}

sub generate_dummy_creator_php__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_enum, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_dummy_creator_php__to_body( $file_ref, $_, $is_enum, $is_message ) . "\n";
    }

    return $res;
}

sub generate_dummy_creator_php__to_enum($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_php__to_object__core( $file_ref, $$file_ref->{enums}, 1, 0 );
}

sub generate_dummy_creator_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_php__to_object__core( $file_ref, $$file_ref->{objs}, 0, 0 );
}

sub generate_dummy_creator_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_dummy_creator_php__to_object__core( $file_ref, $$file_ref->{msgs}, 0, 1 );
}

sub generate_dummy_creator_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_dummy_creator_php__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_dummy_creator_php__to_object( $file_ref ) .
"// messages\n" .
"\n" .
    generate_dummy_creator_php__to_message( $file_ref )
;

    my @includes = ( );

    my $res = to_body( $$file_ref, $body, "", \@includes, [ ] );

    return $res;
}

###############################################

1;
