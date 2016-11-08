#!/usr/bin/perl -w

# $Revision: 4940 $ $Date:: 2016-11-08 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
require DataTypes;

package Generic;

sub to_cpp_json()
{
    my( $self, $value ) = @_;
    return "#error 'not implemented yet'";
}


############################################################
package Boolean;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value" ;
}

############################################################
package Integer;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value" ;
}

############################################################
package Float;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value" ;
}

############################################################
package String;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "$value";
}

############################################################
package UserDefined;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "json_helper::to_object( $value )";
}

############################################################
package Vector;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "json_helper::to_vector( $value )";
}

############################################################
package Map;

sub to_cpp_json()
{
    my( $self, $value ) = @_;

    return "json_helper::to_object( $value )";
}

############################################################

