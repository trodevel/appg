#!/usr/bin/perl -w

# $Revision: 5046 $ $Date:: 2016-11-19 #$ $Author: serge $
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

    $body = $body . gtcpp::array_to_cpp_to_json_impl( $self->{objs} );      # objects
    $body = $body . gtcpp::array_to_cpp_to_json_impl( $self->{base_msgs} ); # base messages
    $body = $body . gtcpp::array_to_cpp_to_json_impl( $self->{msgs} );      # messages

    $body = $body . "\n";

    $body = $self->namespacize( $body );

    $body = "#include <sstream>    // std::ostringstream\n\n" . $body;

    my $incl = gtcpp::to_include_to_json( $self->{name} ) . "    // self\n\n";

    $incl = $incl . gtcpp::array_to_include_to_json( $self->{includes} ) . "\n";

    $body = $incl . $body;

    return $body;
}

############################################################
