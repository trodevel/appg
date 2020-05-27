#!/usr/bin/perl -w

# File
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

# $Revision: 13152 $ $Date:: 2020-05-27 #$ $Author: serge $
# 1.0   - 16b09 - initial version

############################################################

require "mycrc32.pl";
require "Objects.pm";

############################################################

package File;
use strict;
use warnings;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        base_prot   => undef, # base protocol
        prot_object => Object->new( "Object", "apg::Object" ), # protocol base object
        includes  => [],    # includes
        consts    => [],    # constants
        enums     => [],    # enums
        objs      => [],    # objects
        base_msgs => [],    # base messages
        msgs      => [],    # messages
        extern_base_msgs => [],   # external base messages
        must_use_ns     => 0,     # should use APG namespace
    };

    bless $self, $class;
    return $self;
}

sub set_name($)
{
    my ( $self, $name ) = @_;

    $self->{name}       = $name;
}

sub set_base_prot
{
    my ( $self, $elem ) = @_;

    $self->{base_prot}   = $elem;

    $self->{prot_object}->set_base_class( $elem . "::Object" );
    $self->{prot_object}->set_protocol( $self->{name} );
}

sub add_include
{
    my ( $self, $elem ) = @_;

    push @{ $self->{includes} }, $elem;
}

sub add_const($)
{
    my ( $self, $elem ) = @_;

    #$elem->set_protocol( $self->{name} );

    push @{ $self->{consts} }, $elem;
}

sub add_enum
{
    my ( $self, $elem ) = @_;

    $elem->set_protocol( $self->{name} );

    push @{ $self->{enums} }, $elem;
}

sub add_obj
{
    my ( $self, $elem ) = @_;

    $elem->set_protocol( $self->{name} );

    push @{ $self->{objs} }, $elem;
}

sub add_base_msg
{
    my ( $self, $elem ) = @_;

    $elem->set_protocol( $self->{name} );

    push @{ $self->{base_msgs} }, $elem;
}

sub add_msg
{
    my ( $self, $elem ) = @_;

    $elem->{message_id} = main::mycrc32( $self->{name} . ':' . $elem->{name} );
    $elem->set_protocol( $self->{name} );

    push @{ $self->{msgs} }, $elem;
}

sub add_extern_base_msg($)
{
    my ( $self, $elem ) = @_;

    push @{ $self->{extern_base_msgs} }, $elem;
}

sub set_use_ns($)
{
    my ( $self, $v ) = @_;

    $self->{must_use_ns} = $v;
}

sub find_base_msg($)
{
    my ( $self, $name ) = @_;

    foreach( @{ $self->{base_msgs} } )
    {
        my $obj = $_;

        if( $obj->{name} eq $name )
        {
            return \$obj;
        }
    }

    return 0;
}

sub find_extern_base_msg($)
{
    my ( $self, $name ) = @_;

    foreach( @{ $self->{extern_base_msgs} } )
    {
        my $obj = $_;

        if( $obj->{name} eq $name )
        {
            return \$obj;
        }
    }

    return 0;
}

############################################################

sub get_base_msg_params__for_extern($)
{
    my ( $self, $obj_ref ) = @_;

    my @res;

    foreach( @{ $obj_ref->{members} } )
    {
        push @res, $_;
    }

    return @res;
}

############################################################

sub get_base_msg_params($$);

sub get_base_msg_params__for_intern($)
{
    my ( $self, $obj_ref ) = @_;

    my @res;

    if( defined $obj_ref->{base_class} )
    {
        @res = $self->get_base_msg_params( $obj_ref->{base_class} );
    }

    foreach( @{ $obj_ref->{members} } )
    {
        push @res, $_->{data_type};
    }

    return @res;
}

############################################################

sub get_base_msg_params($$)
{
    my ( $self, $name ) = @_;

    if( my $obj_ref = $self->find_extern_base_msg( $name ) != 0 )
    {
        return $self->get_base_msg_params__for_extern( $obj_ref );
    }

    if( $self->find_base_msg( $name ) == 0 )
    {
    }

    my @res;

    return @res;
}

############################################################

1;
