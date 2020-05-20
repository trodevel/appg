#!/usr/bin/perl -w

# DataTypes
#
# Copyright (C) 2016 Sergey Kolevatov
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

# $Revision: 13100 $ $Date:: 2020-05-20 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
require DataTypes;

package Generic;

sub to_php_decl()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}

sub to_php_func_param()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;
    die "#error 'not implemented yet'";
}

#sub to_php__to_html_func_name()
#{
#    my( $self ) = @_;
#    return "#error 'not implemented yet'";
#}

############################################################
package Boolean;

sub to_php_decl()
{
    my( $self ) = @_;

    return "bool";
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;
    return "basic_parser::get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_string__bool";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\parse_bool";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_generic_request__bool";
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_html__bool";
}

############################################################
package Integer;

sub to_php_decl()
{
    my( $self ) = @_;

    my $prefix = "";

    if( $self->{is_unsigned} == 1 )
    {
        $prefix = "u";
    }
    return "${prefix}int" . $self->{bit_width} . "_t";
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;

    return "basic_parser::get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_string__int";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\parse_int";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_generic_request__int";
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_html__int";
}

############################################################
package Float;

sub to_php_decl()
{
    my( $self ) = @_;
    if( $self->{is_double} == 1 )
    {
        return "double";
    }
    return "float";
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;
    return "basic_parser::get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_string__float";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\parse_float";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_generic_request__float";
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_html__float";
}

############################################################
package String;

sub to_php_decl()
{
    my( $self ) = @_;
    return "string";
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;
    return "basic_parser::get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_string__string";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\parse_string";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_generic_request__string";
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;
    return "\\basic_parser\\to_html__string";
}

############################################################
package UserDefined;

sub to_php_decl()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( $self->{namespace} . "\\" ) : "";

    return $pref . $self->{name};
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( $self->{namespace} . "\\" ) : "";

    return "${pref}get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}to_string__" . $self->{name};
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}parse_" . $self->{name};
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}to_generic_request__" . $self->{name};
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}to_html__" . $self->{name};
}

############################################################
package UserDefinedEnum;

sub to_php_decl()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( $self->{namespace} . "\\" ) : "";

    return $pref . $self->{name};
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( $self->{namespace} . "\\" ) : "";

    return "${pref}get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}to_string__" . $self->{name};
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}parse_" . $self->{name};
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}to_generic_request__" . $self->{name};
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;

    my $pref = ( $self->{namespace} ne '' ) ? ( "\\" . $self->{namespace} . "\\" ) : "";

    return "${pref}to_html__" . $self->{name};
}

############################################################

package Vector;

sub to_php_decl()
{
    my( $self ) = @_;
    return "array<" . $self->{value_type}->to_php_decl() . ">";
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;
    return "basic_parser::get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;

    return "to_string__vector";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;

    return "\\basic_parser\\parse_vector";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;

    return "\\basic_parser\\to_generic_request__vector";
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;

    return "\\basic_parser\\to_html__vector";
}

############################################################
package Map;

sub to_php_decl()
{
    my( $self ) = @_;
    return "map<" . $self->{key_type}->to_php_decl() . ", " . $self->{mapped_type}->to_php_decl() . ">";
}

sub to_php_func_param()
{
    my( $self ) = @_;

    return "";
}

sub to_php__to_parse_function_name()
{
    my( $self ) = @_;
    return "basic_parser::get_value_or_throw";
}

sub to_php__to_string_func_name()
{
    my( $self ) = @_;

    return "to_string__map";
}

sub to_php__parse_func_name()
{
    my( $self ) = @_;

    return "\\basic_parser\\parse_map";
}

sub to_php__to_generic_request_func_name()
{
    my( $self ) = @_;

    return "\\basic_parser\\to_generic_request__map";
}

sub to_php__to_html_func_name()
{
    my( $self ) = @_;

    return "\\basic_parser\\to_html__map";
}

############################################################
