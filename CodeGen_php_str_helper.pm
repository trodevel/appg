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

sub generate_str_helper_php__to_enum__body__init_members__body($$)
{
    my ( $enum_name, $name ) = @_;

    return "${enum_name}__${name} => '$name',";
}

sub generate_str_helper_php__to_enum__body__init_members($)
{
    my ( $enum ) = @_;

    my $res = "";

    foreach( @{ $enum->{elements} } )
    {
        $res .= generate_str_helper_php__to_enum__body__init_members__body( $enum->{name}, $_->{name} ) . "\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}


sub generate_str_helper_php__to_enum__body($$)
{
    my ( $namespace, $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"function to_string__${name}( \$r )\n" .
"{\n" .
"    \$map = array\n" .
"    (\n";

    $res .= generate_str_helper_php__to_enum__body__init_members( $enum );

    $res .=
"    );\n" .
"\n" .
"    if( array_key_exists( \$r, \$map ) )\n" .
"    {\n" .
"        return \$map[ \$r ];\n" .
"    }\n" .
"\n" .
"    return '?';\n" .
"}\n";

    return $res;
}

sub generate_str_helper_php__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_str_helper_php__to_enum__body( get_namespace_name( $$file_ref ), $_ ) . "\n";
    }

    return $res;
}

sub generate_str_helper_php__to_object__body__init_members__body($$)
{
    my ( $obj, $namespace ) = @_;

    my $res;

    my $name        = $obj->{name};

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        $res = "    \$res .= \" ${name}=\" . " . $obj->{data_type}->to_php__to_string_func_name() . "( \$r->${name}, '" . $obj->{data_type}->{value_type}->to_php__to_string_func_name( $namespace ) . "' ); // Array";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        $res = "    \$res .= \" ${name}=\" . " . $obj->{data_type}->to_php__to_string_func_name() .
            "( \$r->${name}, '" .
            $obj->{data_type}->{key_type}->to_php__to_string_func_name( $namespace ) . "', '" .
            $obj->{data_type}->{mapped_type}->to_php__to_string_func_name( $namespace ) . "' ); // Map";
    }
    else
    {
        $res = "    \$res .= \" ${name}=\" . " . $obj->{data_type}->to_php__to_string_func_name( undef ) . "( \$r->${name} );";
    }

    return $res;
}

sub generate_str_helper_php__to_object__body__init_members($$)
{
    my ( $msg, $namespace ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_str_helper_php__to_object__body__init_members__body( $_, $namespace ) . "\n";
    }

    return $res;
}

sub generate_str_helper_php__to_object__body($$$$)
{
    my ( $namespace, $msg, $is_message, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"function to_string__${name}( & \$r )\n" .
"{\n";

    $res .=
"    \$res = \"\";";

    if( $is_message )
    {
        if( $msg->has_base_class() )
        {
            $res .=
"    // base class\n" .
"    \$res .= " . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "to_string_" ). "( \$r );\n" .
"\n";
        }
        else
        {
            $res .=
"    // no base class\n";
        }
    }


    if( $is_message == 0 )
    {
        $res .= "    \$res .= \"(\";\n\n";
    }

    $res .=
    generate_str_helper_php__to_object__body__init_members( $msg, $namespace ) .
"\n";

    if( $is_message == 0 )
    {
        $res .= "    \$res .= \")\";\n\n";
    }

    $res .=

"    return \$res;\n" .
"}\n";

    return $res;
}

sub generate_str_helper_php__to_object__core($$$)
{
    my ( $file_ref, $objs_ref, $is_message ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_str_helper_php__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_str_helper_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_php__to_object__core( $file_ref,  $$file_ref->{objs}, 0 );
}

sub generate_str_helper_php__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_php__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0 );
}

sub generate_str_helper_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_php__to_object__core( $file_ref,  $$file_ref->{msgs}, 1 );
}

sub generate_str_helper_php__write__body($$)
{
    my ( $namespace, $name ) = @_;

    return "'$namespace\\$name'         => 'to_string__${name}'";
}

sub generate_str_helper_php__write($$)
{
    my ( $file_ref, $objs_ref ) = @_;

    my $namespace = get_namespace_name( $$file_ref );

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_str_helper_php__write__body( $namespace, $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_str_helper_php__write_objs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_str_helper_php__write( $file_ref, $$file_ref->{objs} );

    return $res;
}

sub generate_str_helper_php__write_msgs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_str_helper_php__write( $file_ref, $$file_ref->{msgs} );

    return $res;
}

sub generate_str_helper_php__to_string($)
{
    my ( $file_ref ) = @_;

    my $res =
"function to_string( \$obj )\n" .
"{\n" .
"    \$handler_map = array(\n" .
"        // objects\n".
    generate_str_helper_php__write_objs( $file_ref ) .
"        // messages\n".
    generate_str_helper_php__write_msgs( $file_ref ) .
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
"    return " . ( $$file_ref->has_base_prot() ? ( "\\". $$file_ref->{base_prot} . "\\to_string( \$obj )" ) : "NULL" ) . ";\n" .
"}\n" .
"\n";

    return $res;
}

sub generate_str_helper_php__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/str_helper" );
    }

    return @res;
}

sub generate_str_helper_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_str_helper_php__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_str_helper_php__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_str_helper_php__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_str_helper_php__to_message( $file_ref ) .
"// generic\n" .
"\n" .
    generate_str_helper_php__to_string( $file_ref )
;

    my @includes;

    push( @includes, $$file_ref->{base_prot} . "/str_helper" ) if $$file_ref->has_base_prot();

    push( @includes, generate_str_helper_php__to_includes( $file_ref ) );

    push( @includes, "basic_parser/str_helper" );

    my $res = to_body( $$file_ref, $body, get_namespace_name( $$file_ref ),  \@includes, [ ] );

    return $res;
}

###############################################

1;
