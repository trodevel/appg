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

sub generate_parser_php__to_enum__body($$)
{
    my ( $namespace, $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"function parse_${name}( & \$csv_arr, & \$offset )\n" .
"{\n" .
"    \$res = \\basic_parser\\parse_int( \$csv_arr, \$offset );\n" .
"\n" .
"    return \$res;\n" .
"}\n";

    return $res;
}

sub generate_parser_php__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res = $res . generate_parser_php__to_enum__body( get_namespace_name( $$file_ref ), $_ ) . "\n";
    }

    return $res;
}

sub generate_parser_php__to_object__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        $res = "    \$res->${name} = " . $obj->{data_type}->to_php__parse_func_name() . "( \$csv_arr, \$offset, '" . $obj->{data_type}->{value_type}->to_php__parse_func_name() . "' ); // Array";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        $res = "    \$res->${name} = " . $obj->{data_type}->to_php__parse_func_name() .
            "( \$csv_arr, \$offset, '" .
            $obj->{data_type}->{key_type}->to_php__parse_func_name() . "', '" .
            $obj->{data_type}->{mapped_type}->to_php__parse_func_name() . "' ); // Map";
    }
    else
    {
        $res = "    \$res->${name} = " . $obj->{data_type}->to_php__parse_func_name() . "( \$csv_arr, \$offset );";
    }

    return $res;
}

sub generate_parser_php__to_object__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res = $res . generate_parser_php__to_object__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_parser_php__to_object__body($$$$$)
{
    my ( $namespace, $msg, $is_message, $is_base_msg, $protocol ) = @_;

    my $name = $msg->{name};

    my $extra_param_1 = "";

    if( $is_base_msg == 1 )
    {
        $extra_param_1 = "& \$res, ";
    }

    my $extra_param = "";

    if( $is_message == 0 )
    {
        $extra_param = ", & \$offset";
    }

    my $res =

"function parse_${name}( ${extra_param_1}& \$csv_arr${extra_param} )\n" .
"{\n";

    if( $is_base_msg == 0 )
    {
        $res .=
"    \$res = new $name;\n" .
"\n";
    }

    if( $is_message )
    {
        $res .=
"    \$offset = 1;\n" .
"\n".
"    // base class\n" .
"    " . gtphp::to_function_call_with_namespace( $msg->get_base_class(), "parse" ). "( \$res, \$csv_arr, \$offset );\n" .
"\n";
    }

    $res .=
    generate_parser_php__to_object__body__init_members( $msg ) .
"\n";

    if( $is_base_msg == 0 )
    {
        $res .=

"    return \$res;\n";
    }

    $res .=
"}\n";

    return $res;
}

sub generate_parser_php__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_parser_php__to_object__body( get_namespace_name( $$file_ref ), $_, $is_message, $is_base_msg, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_parser_php__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_parser_php__to_object__core( $file_ref,  $$file_ref->{objs}, 0, 0 );
}

sub generate_parser_php__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_parser_php__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_parser_php__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_parser_php__to_object__core( $file_ref,  $$file_ref->{msgs}, 1, 0 );
}

sub generate_parser_php__write__body($$)
{
    my ( $namespace, $name ) = @_;

    return "'$namespace\\$name'         => 'parse_${name}'";
}

sub generate_parser_php__write($$)
{
    my ( $file_ref, $objs_ref ) = @_;

    my $namespace = get_namespace_name( $$file_ref );

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res = $res . generate_parser_php__write__body( $namespace, $_->{name} ) . ",\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_parser_php__write_objs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_parser_php__write( $file_ref, $$file_ref->{objs} );

    return $res;
}

sub generate_parser_php__write_msgs($)
{
    my ( $file_ref ) = @_;

    my $res = generate_parser_php__write( $file_ref, $$file_ref->{msgs} );

    return $res;
}

sub generate_parser_php__parse($)
{
    my ( $file_ref ) = @_;

    my $res =
"class Parser extends \\". $$file_ref->{base_prot} . "\\Parser\n".
"{\n" .
"\n" .
"protected static function parse_csv_array( \$csv_arr )\n" .
"{\n" .
"    if( sizeof( \$csv_arr ) < 1 )\n" .
"        return self::create_parse_error();\n" .
"\n" .
"    \$handler_map = array(\n" .
"        // messages\n".
    generate_parser_php__write_msgs( $file_ref ) .
"    );\n" .
"\n" .
"    \$type = \$csv_arr[0][0]\n" .
"\n" .
"    if( array_key_exists( \$type, \$handler_map ) )\n" .
"    {\n" .
"        \$func = '\\\\" . get_namespace_name( $$file_ref ) . "\\\\' . \$handler_map[ \$type ];\n" .
"        return \$func( \$obj );\n" .
"    }\n" .
"\n" .
"    return \\". $$file_ref->{base_prot} . "\\Parser::parse_csv_array( \$obj );\n" .
"}\n" .
"\n" .
"}\n" .
"\n";

    return $res;
}

sub generate_parser_php__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/parser" );
    }

    return @res;
}

sub generate_parser_php($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
"\n" .
    generate_parser_php__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_parser_php__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_parser_php__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_parser_php__to_message( $file_ref ) .
"// generic\n" .
"\n" .
    generate_parser_php__parse( $file_ref )
;

    my @includes;

    push( @includes, $$file_ref->{base_prot} . "/parser" );

    push( @includes, generate_parser_php__to_includes( $file_ref ) );

    push( @includes, "basic_parser/parser" );

    my $res = to_body( $$file_ref, $body, get_namespace_name( $$file_ref ),  \@includes, [ ] );

    return $res;
}

###############################################

1;
