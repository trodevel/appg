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

sub generate_str_helper_h__to_obj_name($$)
{
    my ( $name, $is_enum ) = @_;

    my $prefix = $is_enum ? "" : "& ";

    return "std::ostream & write( std::ostream & os, const $name ${prefix}r );";
}

sub generate_str_helper_h_body_1_core($$)
{
    my ( $objs_ref, $is_enum ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_str_helper_h__to_obj_name( $_->{name}, $is_enum ) . "\n";
    }

    return $res;
}

sub generate_str_helper_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{enums}, 1 );
}

sub generate_str_helper_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{objs}, 0 );
}

sub generate_str_helper_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{base_msgs}, 0 );
}

sub generate_str_helper_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_h_body_1_core( $$file_ref->{msgs}, 0 );
}

sub generate_str_helper_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
generate_str_helper_h_body_1( $file_ref ) .
"\n" .
"// objects\n" .
generate_str_helper_h_body_2( $file_ref ) .
"\n" .
"// base messages\n" .
generate_str_helper_h_body_3( $file_ref ) .
"\n" .
"// messages\n" .
generate_str_helper_h_body_4( $file_ref ) .
"\n" .
"template<class T>\n" .
"std::string to_string( const T & l )\n" .
"{\n" .
"    std::ostringstream os;\n" .
"\n" .
"    write( os, l );\n" .
"\n" .
"    return os.str();\n" .
"}\n" .
"\n";

    $body = gtcpp::namespacize( 'str_helper', $body );

    my $res = to_include_guards( $$file_ref, $body, "", "str_helper", 0, 0, [ "protocol" ], [ "sstream" ] );

    return $res;
}

###############################################

sub generate_str_helper_cpp__to_enum__body__init_members__body($)
{
    my ( $name ) = @_;

    return "{ Type:: TUPLE_VAL_STR( $name ) },";
}

sub generate_str_helper_cpp__to_enum__body__init_members($)
{
    my ( $enum ) = @_;

    my $res = "";

    foreach( @{ $enum->{elements} } )
    {
        $res .= generate_str_helper_cpp__to_enum__body__init_members__body( $_->{name} ) . "\n";
    }

    return main::tabulate( main::tabulate( $res ) );
}

sub generate_str_helper_cpp__to_enum__body($)
{
    my ( $enum ) = @_;

    my $name = $enum->{name};

    my $res =

"std::ostream & write( std::ostream & os, const $name r )\n" .
"{\n" .
"    typedef $name Type;\n" .
"    static const std::map< Type, std::string > m =\n" .
"    {\n";

    $res .= generate_str_helper_cpp__to_enum__body__init_members( $enum );

    $res .=
"    };\n" .
"\n" .
"    auto it = m.find( r );\n" .
"\n" .
"    static const std::string undef( \"undef\" );\n" .
"\n" .
"    if( it != m.end() )\n" .
"        return write( os, it->second );\n" .
"\n" .
"    return write( os, undef );\n" .
"}\n";

    return $res;
}

sub generate_str_helper_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res .= generate_str_helper_cpp__to_enum__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_str_helper_cpp__to_object__body__init_members__body($)
{
    my ( $obj ) = @_;

    my $res;

    my $name        = $obj->{name};

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        $res = "    os << \" ${name}=\"; " . $obj->{data_type}->to_cpp__to_string_func_name() . "( os, r.${name}, " . $obj->{data_type}->{value_type}->to_cpp__to_string_func_ptr() . " ); // Array";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        $res = "    os << \" ${name}=\"; " . $obj->{data_type}->to_cpp__to_string_func_name() .
            "( os, r.${name}, " .
            $obj->{data_type}->{key_type}->to_cpp__to_string_func_ptr() . ", " .
            $obj->{data_type}->{mapped_type}->to_cpp__to_string_func_ptr() . " ); // Map";
    }
    else
    {
        $res = "    os << \" ${name}=\"; " . $obj->{data_type}->to_cpp__to_string_func_name() . "( os, r.${name} );";
    }

    return $res;
}

sub generate_str_helper_cpp__to_object__body__init_members($)
{
    my ( $msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res .= generate_str_helper_cpp__to_object__body__init_members__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_str_helper_cpp__to_object__body($$$$)
{
    my ( $msg, $is_message, $is_base_msg, $protocol ) = @_;

    my $name = $msg->{name};

    my $res =

"std::ostream & write( std::ostream & os, const $name & r )\n" .
"{\n";

    if( $is_message || $is_base_msg )
    {
        if( $msg->has_base_class() )
        {
            $res .=
"    // base class\n" .
"    " . gtcpp::to_function_call_with_namespace( $msg->get_base_class(), "str_helper::write" ). "( os, static_cast<const " . $msg->get_base_class() . "&>( r ) );\n" .
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
        $res .= "    os << \"(\";\n\n";
    }

    $res .=
    generate_str_helper_cpp__to_object__body__init_members( $msg ) .
"\n";

    if( $is_message == 0 )
    {
        $res .= "    os << \")\";\n\n";
    }

    $res .=
"    return os;\n" .
"}\n";

    return $res;
}

sub generate_str_helper_cpp__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_str_helper_cpp__to_object__body( $_, $is_message, $is_base_msg, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_str_helper_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $file_ref, $$file_ref->{objs}, 0, 0 );
}

sub generate_str_helper_cpp__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $file_ref, $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_str_helper_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_str_helper_cpp__to_object__core( $file_ref, $$file_ref->{msgs}, 1, 0 );
}

sub generate_str_helper_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/str_helper" );
    }

    return @res;
}

sub generate_str_helper_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"using ::basic_parser::str_helper::write;\n" .
"using ::basic_parser::str_helper::write_t;\n" .
"\n" .
"// enums\n" .
"\n" .
"#define TUPLE_VAL_STR(_x_)  _x_,#_x_\n" .
"\n" .
    generate_str_helper_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_str_helper_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_str_helper_cpp__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_str_helper_cpp__to_message( $file_ref )
;

    $body = gtcpp::namespacize( 'str_helper', $body );

    my @includes = ( "str_helper" );

    push( @includes, $$file_ref->{base_prot} . "/str_helper" ) if $$file_ref->has_base_prot();

    push( @includes, generate_str_helper_cpp__to_includes( $file_ref ) );

    push( @includes, "basic_parser/str_helper" );

    my $res = to_body( $$file_ref, $body, "",  \@includes, [ "map" ] );

    return $res;
}

###############################################

1;
