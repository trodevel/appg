#!/usr/bin/perl -w

# $Revision: 5021 $ $Date:: 2016-11-17 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Objects;
require Elements_cpp;
require "gen_tools.pl";
require "gen_tools_cpp.pl";

############################################################
package IObject;

sub to_cpp_decl
{
    my( $self ) = @_;
    return '#error not implemented yet';
}

sub get_base_class()
{
    my( $self ) = @_;

    if( defined $self->{base_prot} && $self->{base_prot} ne '' )
    {
        return $self->{base_prot};
    }

    return "apg::Object";
}

sub append_base_class()
{
    my( $self, $body ) = @_;

    my $base = $self->get_base_class();

    return $body . ": public $base";
}

############################################################
package Enum;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Enum\n" .
"enum class " . $self->{name} ." : " . $self->{data_type}->to_cpp_decl() . "\n";

    my @decls = @{ $self->{decls} };

    my $body = gtcpp::array_to_decl( \@decls );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package ObjectWithMembers;

sub get_base_class()
{
    my( $self ) = @_;

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        return $self->{base_class};
    }

    return $self->SUPER::get_base_class();
}

############################################################
package Object;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Object\n" .
"struct " . $self->{name};

    $res = $self->append_base_class( $res ) . "\n";

    my @decls = @{ $self->{decls} };
    my @array = @{ $self->{members} };

    my $body = gtcpp::array_to_decl( \@decls );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package BaseMessage;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Base message\n" .
"struct " . $self->{name};

    $res = $self->append_base_class( $res ) . "\n";

    my @decls = @{ $self->{decls} };
    my @array = @{ $self->{members} };

    my $body = gtcpp::array_to_decl( \@decls );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package Message;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Message\n" .
"struct " . $self->{name};

    $res = $self->append_base_class( $res ) . "\n";

    my $body = "";

    $body = $body . "enum\n" . main::bracketize( "message_id = " . $self->{message_id} . "\n", 1 ) . "\n";


    my @decls = @{ $self->{decls} };
    my @array = @{ $self->{members} };

    $body = $body . gtcpp::array_to_decl( \@decls );

    $body = $body . gtcpp::array_to_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
