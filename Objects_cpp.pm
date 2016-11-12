#!/usr/bin/perl -w

# $Revision: 4981 $ $Date:: 2016-11-11 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Objects;
require Elements_cpp;
require "gen_tools.pl";

############################################################
package IObject;

sub to_cpp_decl
{
    my( $self ) = @_;
    return '#error not implemented yet';
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

    my $body = main::array_to_cpp_decl( \@decls );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package Object;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Object\n" .
"struct " . $self->{name} ."\n";

    my @decls = @{ $self->{decls} };
    my @array = @{ $self->{members} };

    my $body = main::array_to_cpp_decl( \@decls );

    $body = $body . main::array_to_cpp_decl( \@array );

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

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . ": public " . $self->{base_class};
    }

    $res = $res . "\n";

    my @decls = @{ $self->{decls} };
    my @array = @{ $self->{members} };

    my $body = main::array_to_cpp_decl( \@decls );

    $body = $body . main::array_to_cpp_decl( \@array );

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

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . ": public " . $self->{base_class};
    }

    $res = $res . "\n";

    my $body = "";

    $body = $body . "enum\n" . main::bracketize( "message_id = " . $self->{message_id} . "\n", 1 ) . "\n";


    my @decls = @{ $self->{decls} };
    my @array = @{ $self->{members} };

    $body = $body . main::array_to_cpp_decl( \@decls );

    $body = $body . main::array_to_cpp_decl( \@array );

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
