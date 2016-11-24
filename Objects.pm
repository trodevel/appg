#!/usr/bin/perl -w

# $Revision: 5066 $ $Date:: 2016-11-24 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
package IObject;
use strict;
use warnings;

require Elements;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
    };


    bless $self, $class;
    return $self;
}


############################################################
package Enum;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1] );

    $self->{data_type}  = $_[2];
    $self->{elements}   = [];

    bless $self, $class;
    return $self;
}

sub add_element
{
    my ( $self, $elem ) = @_;

    push @{ $self->{elements} }, $elem;
}

############################################################
package ObjectWithMembers;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1] );

    $self->{enums}    = [];
    $self->{members}  = [];

    bless $self, $class;
    return $self;
}

sub add_enum
{
    my ( $self, $elem ) = @_;

    push @{ $self->{enums} }, $elem;
}

sub add_member
{
    my ( $self, $elem ) = @_;

    push @{ $self->{members} }, $elem;

}

sub set_base_class
{
    my ( $self, $elem ) = @_;

    $self->{base_class} = $elem;
}

############################################################
package Object;
use strict;
use warnings;

our @ISA = qw( ObjectWithMembers );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1] );

    $self->{base_class}  = $_[2];

    bless $self, $class;
    return $self;
}

############################################################
package BaseMessage;
use strict;
use warnings;

our @ISA = qw( ObjectWithMembers );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1] );

    $self->{base_class}  = $_[2];

    bless $self, $class;
    return $self;
}

############################################################
package Message;
use strict;
use warnings;

our @ISA = qw( ObjectWithMembers );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1] );

    $self->{base_class}  = $_[2];
    $self->{message_id}  = 0;

    bless $self, $class;
    return $self;
}

############################################################
