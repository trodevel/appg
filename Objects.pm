#!/usr/bin/perl -w

# Objects
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

# $Revision: 13137 $ $Date:: 2020-05-26 #$ $Author: serge $
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

    $self->{protocol} = undef;

    bless $self, $class;
    return $self;
}

sub set_protocol
{
    my ( $self, $elem ) = @_;

    $self->{protocol} = $elem;
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
    $self->{parent}     = undef;

    bless $self, $class;
    return $self;
}

sub add_element
{
    my ( $self, $elem ) = @_;

    push @{ $self->{elements} }, $elem;
}

sub set_parent
{
    my ( $self, $v ) = @_;

    $self->{parent} = $v;
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

    $self->{enums}      = [];
    $self->{members}    = [];
    $self->{is_message} = 0;

    bless $self, $class;
    return $self;
}

sub add_enum
{
    my ( $self, $elem ) = @_;

    $elem->set_parent( $self->{name} );

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

# @descr need to set protocol for all declarations
sub set_protocol
{
    my ( $self, $elem ) = @_;

    $self->SUPER::set_protocol( $elem );

    foreach( @{ $self->{enums} } )
    {
        $_->set_protocol( $elem );
    }
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
    $self->{is_message}  = 1;

    bless $self, $class;
    return $self;
}

############################################################
package ExternBaseMessage;
use strict;
use warnings;

our @ISA = qw( ObjectWithMembers );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1] );

    bless $self, $class;
    return $self;
}

############################################################
