#!/usr/bin/perl -w

# $Revision: 5006 $ $Date:: 2016-11-15 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require File;
require Objects_cpp;
require "gen_tools_cpp.pl";

############################################################
package File;

sub to_include_guards
{
    my( $self, $body, $prefix, $must_include_myself ) = @_;

    my @includes  = @{ $self->{includes} };     # includes

    $body = gtcpp::namespacize( $self->{name}, $body );

    $body = gtcpp::namespacize( 'apg', $body );

    if( defined $must_include_myself && $must_include_myself == 1 )
    {
        $body =
            gtcpp::to_include( $self->{name} ) . "    // self\n\n" . $body;
    }
    else
    {
        $body = "// includes\n" .
            gtcpp::array_to_include( \@includes ) . "\n" . $body;
    }

    my $res = gtcpp::ifndef_define_prot( $self->{name}, $prefix, $body );

    return $res;
}

############################################################

sub to_cpp_decl
{
    my( $self ) = @_;

    my $body = "";

    my @enums     = @{ $self->{enums} };        # enums
    my @objs      = @{ $self->{objs} };         # objects
    my @base_msgs = @{ $self->{base_msgs} };    # base messages
    my @msgs      = @{ $self->{msgs} };         # messages

    $body = $body . gtcpp::array_to_decl( \@enums );
    $body = $body . gtcpp::array_to_decl( \@objs );
    $body = $body . gtcpp::array_to_decl( \@base_msgs );
    $body = $body . gtcpp::array_to_decl( \@msgs );

    my $res = $self->to_include_guards( $body, "decl" );

    return $res;
}

############################################################
