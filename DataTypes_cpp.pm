#!/usr/bin/perl -w

# $Revision: 5063 $ $Date:: 2016-11-24 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
require DataTypes;

package Generic;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}


############################################################
package Boolean;

sub to_cpp_decl()
{
    my( $self ) = @_;

    return "bool";
}

############################################################
package Integer;

sub to_cpp_decl()
{
    my( $self ) = @_;

    my $prefix = "";

    if( $self->{is_unsigned} == 1 )
    {
        $prefix = "u";
    }
    return "${prefix}int" . $self->{bit_width} . "_t";
}

############################################################
package Float;

sub to_cpp_decl()
{
    my( $self ) = @_;
    if( $self->{is_double} == 1 )
    {
        return "double";
    }
    return "float";
}

############################################################
package String;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::string";
}

############################################################
package UserDefined;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return $self->{name};
}

############################################################
package UserDefinedEnum;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return $self->{name};
}

############################################################
package Vector;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::vector<" . $self->{value_type}->to_cpp_decl() . ">";
}

############################################################
package Map;

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::map<" . $self->{key_type}->to_cpp_decl() . ", " . $self->{mapped_type}->to_cpp_decl() . ">";
}

############################################################

