#!/usr/bin/perl -w

# $Revision: 5033 $ $Date:: 2016-11-18 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require File_cpp;
require Objects_cpp_json;
require "gen_tools_cpp.pl";

############################################################
package File;

sub to_cpp_to_json_decl
{
    my( $self ) = @_;

    my $body = "";

    my @includes  = @{ $self->{includes} };     # includes
    my @objs      = @{ $self->{objs} };         # objects
    my @base_msgs = @{ $self->{base_msgs} };    # base messages
    my @msgs      = @{ $self->{msgs} };         # messages

    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@objs );
    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@base_msgs );
    $body = $body . gtcpp::array_to_cpp_to_json_decl( \@msgs );

    $body = $body . "\n";

    return $self->to_include_guards( $body, "to_json", 1 );
}

############################################################
sub to_cpp_to_json_impl
{
    my( $self ) = @_;

    my $body = "";

    my @objs      = @{ $self->{objs} };         # objects
    my @base_msgs = @{ $self->{base_msgs} };    # base messages
    my @msgs      = @{ $self->{msgs} };         # messages

    $body = $body . gtcpp::array_to_cpp_to_json_impl( \@objs );
    $body = $body . gtcpp::array_to_cpp_to_json_impl( \@base_msgs );
    $body = $body . gtcpp::array_to_cpp_to_json_impl( \@msgs );

    $body = $body . "\n";

    $body = $self->namespacize( $body );

    $body = gtcpp::to_include( $self->{name} . "_to_json" ) . "    // self\n\n" . $body;

    return $body;
}

############################################################
