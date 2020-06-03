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

# $Revision: 13186 $ $Date:: 2020-06-04 #$ $Author: serge $
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

sub find_obj($)
{
    my ( $self, $name ) = @_;

    foreach( @{ $self->{objs} } )
    {
        my $obj = $_;

        if( $obj->{name} eq $name )
        {
            return \$obj;
        }
    }

    return 0;
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

sub find_msg($)
{
    my ( $self, $name ) = @_;

    foreach( @{ $self->{msgs} } )
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

    foreach( @{ $$obj_ref->{members} } )
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

    if( defined $$obj_ref->{base_class} )
    {
        @res = $self->get_base_msg_params( $$obj_ref->{base_class} );
    }

    foreach( @{ $$obj_ref->{members} } )
    {
        push @res, $_->{data_type};
    }

    return @res;
}

############################################################

sub get_base_msg_params($$)
{
    my ( $self, $name ) = @_;

    my $obj_ref = $self->find_extern_base_msg( $name );

    if( $obj_ref != 0 )
    {
        #print STDERR "get_base_msg_params: $name - extern $obj_ref\n";

        return $self->get_base_msg_params__for_extern( $obj_ref );
    }

    $obj_ref = $self->find_base_msg( $name );

    if( $obj_ref != 0 )
    {
        #print STDERR "get_base_msg_params: $name - intern $obj_ref\n";

        return $self->get_base_msg_params__for_intern( $obj_ref );
    }

    my @res;

    return @res;
}

############################################################

sub get_obj_params__by_ref($$)
{
    my ( $self, $obj_ref ) = @_;

    die "cannot find message $name" if $obj_ref == 0;

    my @res;

    if( $$obj_ref->has_base_class() )
    {
        @res = $self->get_base_msg_params( $$obj_ref->get_base_class() );
    }

    foreach( @{ $$obj_ref->{members} } )
    {
        push @res, $_->{data_type};
    }

    return @res;
}

############################################################

sub get_msg_params($$)
{
    my ( $self, $name ) = @_;

    my $obj_ref = $self->find_msg( $name );

    die "cannot find message $name" if $obj_ref == 0;

    return $self->get_obj_params__by_ref( $obj_ref );
}

############################################################

1;
