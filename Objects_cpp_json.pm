#!/usr/bin/perl -w

# $Revision: 4952 $ $Date:: 2016-11-08 #$ $Author: serge $
# 1.0   - 16b08 - initial version

require Objects;
require Elements_cpp_json;
require Objects_cpp;

############################################################
package IObject;

sub to_cpp_json
{
    my( $self ) = @_;

    my $res = "";

    my @array = @{ $self->{members} };

    foreach( @array )
    {
        $res = $res . "<< " . $_->to_cpp_json() . "\n";
    }

    return $res;
}

############################################################
package Enum;

sub to_cpp_json
{
    my( $self ) = @_;

    return "";
}

############################################################
package Object;

############################################################
package BaseMessage;

sub to_cpp_json
{
    my( $self ) = @_;

    my $res = "";

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . "<< to_json( static_cast<const " . $self->{base_class} . "*> this )\n";
    }

    $res = $res . $self->SUPER::to_cpp_json();

    return $res;
}

############################################################
package Message;

sub to_cpp_json
{
    my( $self ) = @_;

    my $res = "";

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . "<< to_json( static_cast<const " . $self->{base_class} . "*> this )\n";
    }

    $res = $res . $self->SUPER::to_cpp_json();

    return $res;
}

############################################################
