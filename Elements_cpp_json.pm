#!/usr/bin/perl -w

# $Revision: 4951 $ $Date:: 2016-11-08 #$ $Author: serge $
# 1.0   - 16b05 - initial version

require Elements;
require DataTypes_cpp_json;

############################################################
package EnumElement;

sub to_cpp_json
{
    my( $self ) = @_;

    return $self->{name};
}

############################################################
package Element;

sub to_cpp_json
{
    my( $self ) = @_;

    return  'json_helper::to_pair( "' . $self->{name} . '", ' . $self->{data_type}->to_cpp_json( $self->{name} ) . " )";
}

############################################################
