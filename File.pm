#!/usr/bin/perl -w

# $Revision: 4991 $ $Date:: 2016-11-14 #$ $Author: serge $
# 1.0   - 16b09 - initial version

############################################################

require "mycrc32.pl";

package File;
use strict;
use warnings;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        includes  => [],    # includes
        enums     => [],    # enums
        objs      => [],    # objects
        base_msgs => [],    # base messages
        msgs      => [],    # messages
    };

    bless $self, $class;
    return $self;
}

sub add_include
{
    my ( $self, $elem ) = @_;

    push @{ $self->{includes} }, $elem;
}

sub add_enum
{
    my ( $self, $elem ) = @_;

    push @{ $self->{enums} }, $elem;
}

sub add_obj
{
    my ( $self, $elem ) = @_;

    push @{ $self->{objs} }, $elem;
}

sub add_base_msg
{
    my ( $self, $elem ) = @_;

    push @{ $self->{base_msgs} }, $elem;
}

sub add_msg
{
    my ( $self, $elem ) = @_;

    $elem->{message_id} = main::mycrc32( $self->{name} . ':' . $elem->{name} );

    push @{ $self->{msgs} }, $elem;
}

############################################################

1;
