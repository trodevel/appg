#!/usr/bin/perl -w

# $Revision: 4964 $ $Date:: 2016-11-10 #$ $Author: serge $
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
        decls     => [],     # reference to an annonymous array
    };

    bless $self, $class;
    return $self;
}

sub add_decl
{
    my ( $self, $elem ) = @_;

    push @{ $self->{decls} }, $elem;

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

    bless $self, $class;
    return $self;
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

    $self->{members}  = [];

    bless $self, $class;
    return $self;
}

sub add_member
{
    my ( $self, $elem ) = @_;

    push @{ $self->{members} }, $elem;

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
