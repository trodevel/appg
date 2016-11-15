#!/usr/bin/perl -w

# $Revision: 5000 $ $Date:: 2016-11-15 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require File;
require Objects_cpp;
require "gen_tools.pl";

############################################################
package File;

sub to_cpp_include_guards
{
    my( $self, $body, $prefix, $must_include_myself ) = @_;

    my @includes  = @{ $self->{includes} };     # includes

    $body = main::namespacize( $self->{name}, $body );

    $body = main::namespacize( 'apg', $body );

    if( defined $must_include_myself && $must_include_myself == 1 )
    {
        $body =
            main::to_cpp_include( $self->{name} ) . "    // self\n\n" . $body;
    }
    else
    {
        $body = "// includes\n" .
            main::array_to_cpp_include( \@includes ) . "\n" . $body;
    }

    my $res = main::ifndef_define_prot( $self->{name}, $prefix, $body );

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

    $body = $body . main::array_to_cpp_decl( \@enums );
    $body = $body . main::array_to_cpp_decl( \@objs );
    $body = $body . main::array_to_cpp_decl( \@base_msgs );
    $body = $body . main::array_to_cpp_decl( \@msgs );

    my $res = $self->to_cpp_include_guards( $body, "decl" );

    return $res;
}

############################################################
