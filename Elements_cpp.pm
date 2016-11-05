#!/usr/bin/perl -w

# $Revision: 4910 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Elements;
require DataTypes_cpp;

############################################################
package EnumElement;

sub to_cpp_decl
{
    my( $self ) = @_;

    if( defined $self->{value} && $self->{value} ne '' )
    {
        return sprintf( "%-20s = %s,", $self->{name}, $self->{value} );
    }

    return $self->{name} . ",";
}

############################################################
package Element;

sub to_cpp_decl
{
    my( $self ) = @_;
    return sprintf( "%-20s %-10s;", $self->{data_type}->to_cpp_decl(), $self->{name} );
}

############################################################
package ValidRange;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $from = "-inf";
    my $to   = "+inf";

    my $prefix = "";
    my $suffix = "";

    if( $self->{has_from} == 1 )
    {
        $from = $self->{from};

        if( $self->{is_inclusive_from} == 1 )
        {
            $prefix = "[";
        }
        else
        {
            $prefix = "(";
        }
    }

    if( $self->{has_to} == 1 )
    {
        $to = $self->{to};

        if( $self->{is_inclusive_to} == 1 )
        {
            $suffix = "]";
        }
        else
        {
            $suffix = ")";
        }
    }
    return "$prefix$from, $to$suffix";
}

############################################################
package ElementExt;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $add = "";

    if( defined $self->{valid_range_or_size} && $self->{valid_range_or_size} ne '' )
    {
        my $comment = "valid range";

        if( $self->{is_array} == 1 )
        {
            $comment = "size constrain";
        }

        $add = " // $comment: " . $self->{valid_range_or_size}->to_cpp_decl();
    }

    return $self->SUPER::to_cpp_decl() . $add;
}

############################################################
