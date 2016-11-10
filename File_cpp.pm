#!/usr/bin/perl -w

# $Revision: 4969 $ $Date:: 2016-11-10 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require File;
require Objects_cpp;
require "gen_tools.pl";

############################################################
package File;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $body = "";

    my @includes  = @{ $self->{includes} };     # includes
    my @enums     = @{ $self->{enums} };        # enums
    my @objs      = @{ $self->{objs} };         # objects
    my @base_msgs = @{ $self->{base_msgs} };    # base messages
    my @msgs      = @{ $self->{msgs} };         # messages

    $body = $body . main::array_to_cpp_decl( \@enums );
    $body = $body . main::array_to_cpp_decl( \@objs );
    $body = $body . main::array_to_cpp_decl( \@base_msgs );
    $body = $body . main::array_to_cpp_decl( \@msgs );

    $body = main::namespacize( $self->{name}, $body );

    $body = main::namespacize( 'apg', $body );

    my $res = main::ifndef_define_prot( $self->{name}, "decl", $body );

    return $res;
}

############################################################
