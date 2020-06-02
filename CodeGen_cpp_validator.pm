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

sub generate_validator_h__to_obj_name($$$)
{
    my ( $name, $is_message, $is_base_msg ) = @_;

    my $prefix = ( ( $is_message == 1 ) || ( $is_base_msg == 1 ) ) ? "" : "const std::string & prefix, ";

    return "bool validate( ${prefix}const $name & r );";
}

sub generate_validator_h_body_1_core($$$)
{
    my ( $objs_ref, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_validator_h__to_obj_name( $_->{name}, $is_message, $is_base_msg ) . "\n";
    }

    return $res;
}

sub generate_validator_h_body_1($)
{
    my ( $file_ref ) = @_;

    return generate_validator_h_body_1_core( $$file_ref->{enums}, 0, 0 );
}

sub generate_validator_h_body_2($)
{
    my ( $file_ref ) = @_;

    return generate_validator_h_body_1_core( $$file_ref->{objs}, 0, 0 );
}

sub generate_validator_h_body_3($)
{
    my ( $file_ref ) = @_;

    return generate_validator_h_body_1_core( $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_validator_h_body_4($)
{
    my ( $file_ref ) = @_;

    return generate_validator_h_body_1_core( $$file_ref->{msgs}, 1, 0 );
}

sub generate_validator_h($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"// enums\n" .
generate_validator_h_body_1( $file_ref ) .
"\n" .
"// objects\n" .
generate_validator_h_body_2( $file_ref ) .
"\n" .
"// base messages\n" .
generate_validator_h_body_3( $file_ref ) .
"\n" .
"// messages\n" .
generate_validator_h_body_4( $file_ref ) .
"\n";

    $body = gtcpp::namespacize( 'validator', $body );

    my $res = to_include_guards( $$file_ref, $body, "", "validator", 0, 0, [ "protocol" ], [ ] );

    return $res;
}

###############################################

sub generate_validator_cpp__to_enum__body($)
{
    my ( $obj ) = @_;

    my $name = $obj->{name};

    my $type = "unsigned";

    if( defined $obj->{data_type} )
    {
        $type = $obj->{data_type}->to_cpp_decl();
    }

    my @elements = @{ $obj->{elements} };

    my $size = scalar @elements;

    my $extra_params = "";

    if( $size > 0 )
    {
        $extra_params = ", true, true, static_cast<$type>( $name::$elements[0]->{name} ), true, true, static_cast<$type>( $name::$elements[$size-1]->{name} )";
    }

    my $res =

"bool validate( const std::string & prefix, const $name & r )\n" .
"{\n" .
"    validate( prefix, static_cast<$type>( r )${extra_params} );\n" .
"\n" .
"    return true;\n" .
"}\n";

    return $res;
}

sub generate_validator_cpp__to_enum($)
{
    my ( $file_ref ) = @_;

    my $res = "";

    foreach( @{ $$file_ref->{enums} } )
    {
        $res .= generate_validator_cpp__to_enum__body( $_ ) . "\n";
    }

    return $res;
}

sub generate_validator_cpp__to_object__body__init_members__body($$$)
{
    my ( $obj, $is_message, $is_base_msg ) = @_;

    my $res;

    my $name        = $obj->{name};

    my $key_name    = uc( $name );

    my $full_key_name = ( ( $is_message == 1 ) || ( $is_base_msg == 1 ) ) ? '"' . $key_name . '"' : 'prefix + ".' . $key_name . '"';

    my $valid_range_or_size = "";

#    print "DEBUG: type = " . ::blessed( $obj->{data_type} ). "\n";

    if( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Vector' ))
    {
        if( defined $obj->{valid_range_or_size} && $obj->{valid_range_or_size} ne '' )
        {
            $valid_range_or_size = ", " . $obj->{valid_range_or_size}->to_cpp_func_params( "std::size_t" );
        }

        $res = "    " . $obj->{data_type}->to_cpp__validate_func_name() . "( $full_key_name, r.${name}, " . $obj->{data_type}->{value_type}->to_cpp__validate_func_ptr() . "$valid_range_or_size ); // Array";
    }
    elsif( ::blessed( $obj->{data_type} ) and $obj->{data_type}->isa( 'Map' ))
    {
        if( defined $obj->{valid_range_or_size} && $obj->{valid_range_or_size} ne '' )
        {
            $valid_range_or_size = ", " . $obj->{valid_range_or_size}->to_cpp_func_params( "std::size_t" );
        }

        $res = "    " . $obj->{data_type}->to_cpp__validate_func_name() .
            "( $full_key_name, r.${name}, " .
            $obj->{data_type}->{key_type}->to_cpp__validate_func_ptr() . ", " .
            $obj->{data_type}->{mapped_type}->to_cpp__validate_func_ptr() . "$valid_range_or_size ); // Map";
    }
    else
    {
        if( defined $obj->{valid_range_or_size} && $obj->{valid_range_or_size} ne '' )
        {
            $valid_range_or_size = ", " . $obj->{valid_range_or_size}->to_cpp_func_params( $obj->{data_type}->to_cpp_decl() );
        }

        $res = "    " . $obj->{data_type}->to_cpp__validate_func_name() . "( $full_key_name, r.${name}$valid_range_or_size );";
    }

    return $res;
}

sub generate_validator_cpp__to_object__body__init_members($$$)
{
    my ( $msg, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $msg->{members} } )
    {
        $res .= generate_validator_cpp__to_object__body__init_members__body( $_, $is_message, $is_base_msg ) . "\n";
    }

    return $res;
}

sub generate_validator_cpp__to_object__body($$$$)
{
    my ( $msg, $is_message, $is_base_msg, $protocol ) = @_;

    my $name = $msg->{name};

    my $prefix = ( ( $is_message == 1 ) || ( $is_base_msg == 1 ) ) ? "" : "const std::string & prefix, ";

    my $res =

"bool validate( ${prefix}const $name & r )\n" .
"{\n";

    if( $is_message )
    {
        if( $msg->has_base_class() )
        {
            $res .=
"    // base class\n" .
"    " . gtcpp::to_function_call_with_namespace( $msg->get_base_class(), "validator::validate" ). "( static_cast<const " . $msg->get_base_class() . "&>( r ) );\n" .
"\n";
        }
        else
        {
            $res .=
"    // no base class\n";
        }
    }

    $res .=
    generate_validator_cpp__to_object__body__init_members( $msg, $is_message, $is_base_msg ) .
"\n" .
"    return true;\n" .
"}\n";

    return $res;
}

sub generate_validator_cpp__to_object__core($$$$)
{
    my ( $file_ref, $objs_ref, $is_message, $is_base_msg ) = @_;

    my $res = "";

    foreach( @{ $objs_ref } )
    {
        $res .= generate_validator_cpp__to_object__body( $_, $is_message, $is_base_msg, $$file_ref->{name} ) . "\n";
    }

    return $res;
}

sub generate_validator_cpp__to_object($)
{
    my ( $file_ref ) = @_;

    return generate_validator_cpp__to_object__core( $file_ref,  $$file_ref->{objs}, 0, 0 );
}

sub generate_validator_cpp__to_base_message($)
{
    my ( $file_ref ) = @_;

    return generate_validator_cpp__to_object__core( $file_ref,  $$file_ref->{base_msgs}, 0, 1 );
}

sub generate_validator_cpp__to_message($)
{
    my ( $file_ref ) = @_;

    return generate_validator_cpp__to_object__core( $file_ref,  $$file_ref->{msgs}, 1, 0 );
}

sub generate_validator_cpp__to_includes($)
{
    my ( $file_ref ) = @_;

    my @res;

    foreach( @{ $$file_ref->{includes} } )
    {
        push( @res, $_ . "/validator" );
    }

    return @res;
}

sub generate_validator_cpp($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body =

"using ::basic_parser::validator::validate;\n" .
"using ::basic_parser::validator::validate_t;\n" .
"\n" .
"// enums\n" .
"\n" .
    generate_validator_cpp__to_enum( $file_ref ) .
"// objects\n" .
"\n" .
    generate_validator_cpp__to_object( $file_ref ) .
"// base messages\n" .
"\n" .
    generate_validator_cpp__to_base_message( $file_ref ) .
"// messages\n" .
"\n" .
    generate_validator_cpp__to_message( $file_ref )
;

    $body = gtcpp::namespacize( 'validator', $body );

    my @includes = ( "validator" );

    push( @includes, $$file_ref->{base_prot} . "/validator" );

    push( @includes, generate_validator_cpp__to_includes( $file_ref ) );

    push( @includes, "basic_parser/validator" );

    my $res = to_body( $$file_ref, $body, "",  \@includes, [ ] );

    return $res;
}

###############################################

1;
