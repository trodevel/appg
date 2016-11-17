#!/usr/bin/perl -w

# $Revision: 5014 $ $Date:: 2016-11-16 #$ $Author: serge $
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

sub append_base_protocol()
{
    my( $self, $body ) = @_;

    $body = $body . ": public Object";

    return $body;
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
package Object;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"// Object\n" .
"struct " . $self->{name};

    $res = $self->append_base_protocol( $res ) . "\n";

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

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . ": public " . $self->{base_class};
    }
    else
    {
        $res = $self->append_base_protocol( $res );
    }

    $res = $res . "\n";

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

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . ": public " . $self->{base_class};
    }
    else
    {
        $res = $self->append_base_protocol( $res );
    }

    $res = $res . "\n";

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
