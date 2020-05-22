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

use Scalar::Util qw(blessed);        # blessed

require File;
require Objects_php;
require "gen_tools_php.pl";

###############################################

package CodeGen_php;

use strict;
use warnings;
use 5.010;

###############################################

sub generate_request_encoder_php__to_enum__body($$)
{
    my ( $namespace, $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"function to_generic_request__${name}( \$prefix, \$r )\n" .
"{\n" .
"    \$res = \\basic_parser\\to_generic_request__int( \$prefix, \$r );\n" .
"\n" .
"    return \$res;\n" .
"}\n";

    return $res;
}

sub generate_request_encoder_php__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_request_encoder_php__to_enum__body( get_namespace_name( $$file_ref ), $_ ) . "\n";
    }

    return $res;
}

sub generate_request_encoder_php__to_object__body__init_members__body($$$)
{
    my ( $is_message, $is_base_msg, $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

    my $key_name    = uc( $name );

    my $full_key_name = ( ( $is_message == 1 ) || ( $is_base_msg == 1 ) ) ? '"' . $key_name . '"' : '$prefix . ".' . $key_name . '"';

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        $res = "    \$res .= \"&\" . " . $obj->{data_type}->to_php__to_generic_request_func_name() . "( $full_key_name, \$r->${name}, '" . $obj->{data_type}->{value_type}->to_php__to_generic_request_func_name() . "' ); // Array";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        $res = "    \$res .= \"&\" . " . $obj->{data_type}->to_php__to_generic_request_func_name() .
            "( $full_key_name, \$r->${name}, '" .
            $obj->{data_type}->{key_type}->to_php__to_generic_request_func_name() . "', '" .
            $obj->{data_type}->{mapped_type}->to_php__to_generic_request_func_name() . "' ); // Map";
    }
    else
    {
        $res = "    \$res .= \"&\" . " . $obj->{data_type}->to_php__to_generic_request_func_name() . "( $full_key_name, \$r->${name} );";
    }

    return $res;
}

sub generate_request_encoder_php__to_object__body__init_members($$$)
{
    my ( $is_message, $is_base_msg, $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_request_encoder_php__to_object__body__init_members__body( $is_message, $is_base_msg, $_ ) . "\n";
    }

    return $res;
}

sub generate_request_encoder_php__to_object__body($$$$$)
{
    my ( $namespace, $msg, $is_message, $is_base_msg, $protocol ) = @_;

    my $name = $msg->{name};

    my $prefix = ( ( $is_message == 1 ) || ( $is_base_msg == 1 ) ) ? "" : "\$prefix, ";

    my $res =

"function to_generic_request__${name}( $prefix& \$r )\n" .
"{\n";

    if( $is_message )
    {

        $res .=
"    // name\n" .
"    \$res = \\basic_parser\\to_generic_request__string( \"CMD\", \"$protocol/$name\" );\n" .
"\n";

        $res .=
"    // base class\n" .
"    \$res .= " . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "to_generic_request_" ). "( \$r );\n" .
"\n";
    }
    else
    {
        $res .=
"    \$res = \"\";\n";
    }


    $res .=
    generate_request_encoder_php__to_object__body__init_members( $is_message, $is_base_msg, $msg ) .
"\n";

    $res .=

"    return \$res;\n" .
"}\n";

    return $res;
}

sub generate_request_encoder_php__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_request_encoder_php__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $is_base_msg, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_request_encoder_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_request_encoder_php__to_object__core( $file_ref,  $$file_ref->{objs}, 0, 0 );
}

sub generate_request_encoder_php__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_request_encoder_php__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_request_encoder_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_request_encoder_php__to_object__core( $file_ref,  $$file_ref->{msgs}, 1, 0 );
}

sub generate_request_encoder_php__write__body($$)
{
    my ( $namespace, $name ) = @_;

    return "'$namespace\\$name'         => 'to_generic_request__${name}'";
}

sub generate_request_encoder_php__write($$)
{
    my ( $file_ref, $objs_ref ) = @_;

    my $namespace = get_namespace_name( $$file_ref );

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_request_encoder_php__write__body( $namespace, $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_request_encoder_php__write_objs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_request_encoder_php__write( $file_ref, $$file_ref->{objs} );

    return $res;
}

sub generate_request_encoder_php__write_msgs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_request_encoder_php__write( $file_ref, $$file_ref->{msgs} );

    return $res;
}

sub generate_request_encoder_php__to_generic_request($)
{
    my ( $file_ref ) = @_;

    my $res =
"function to_generic_request( \$obj )\n" .
"{\n" .
"    \$handler_map = array(\n" .
"        // messages\n".
    generate_request_encoder_php__write_msgs( $file_ref ) .
"    );\n" .
"\n" .
"    \$type = get_class( \$obj );\n" .
"\n" .
"    if( array_key_exists( \$type, \$handler_map ) )\n" .
"    {\n" .
"        \$func = '\\\\" . get_namespace_name( $$file_ref ) . "\\\\' . \$handler_map[ \$type ];\n" .
"        return \$func( \$obj );\n" .
"    }\n" .
"\n" .
"    return \\". $$file_ref->{base_prot} . "\\to_generic_request( \$obj );\n" .
"}\n" .
"\n";

    return $res;
}

sub generate_request_encoder_php__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/request_encoder" );
    }

    return @res;
}

sub generate_request_encoder_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_request_encoder_php__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_request_encoder_php__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_request_encoder_php__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_request_encoder_php__to_message( $file_ref ) .
"// generic\n" .
"\n" .
    generate_request_encoder_php__to_generic_request( $file_ref )
;

    my @includes;

    push( @includes, $$file_ref->{base_prot} . "/request_encoder" );

    push( @includes, generate_request_encoder_php__to_includes( $file_ref ) );

    push( @includes, "basic_parser/request_encoder" );

    my $res = to_body( $$file_ref, $body, get_namespace_name( $$file_ref ),  \@includes, [ ] );

    return $res;
}

###############################################

1;
