#!/usr/bin/perl -w

# $Revision: 5005 $ $Date:: 2016-11-15 #$ $Author: serge $
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

    return $self->to_include_guards( $body, "json", 1 );
}

############################################################
