#!/usr/bin/perl -w

# $Revision: 4911 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

require Objects;
require Elements_cpp;

############################################################
sub bracketize
{
    my ( $body, $must_put_semicolon ) = @_;

    my $res = "{\n";

    my @lines = split /\n/, $body;
    foreach my $line( @lines )
    {
        $res = $res . "    " . $line . "\n";
    }

    my $semic = "";

    if( defined $must_put_semicolon && $must_put_semicolon == 1 )
    {
        $semic = ";";
    }

    $res = $res . "}$semic\n";


    return  $res;
}

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
"enum class " . $self->{name} ." : " . $self->{data_type}->to_cpp_decl() . "\n";

    my @array = @{ $self->{members} };

    my $body = "";
    foreach( @array )
    {
        $body = $body . $_->to_cpp_decl() . "\n";
    }

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package Object;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res =
"struct " . $self->{name} ."\n";

    my @array = @{ $self->{members} };

    my $body = "";
    foreach( @array )
    {
        $body = $body . $_->to_cpp_decl() . "\n";
    }

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package BaseMessage;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res = "struct " . $self->{name};

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . ": public " . $self->{base_class};
    }

    $res = $res . "\n";

    my $body = "";

    my @array = @{ $self->{members} };

    foreach( @array )
    {
        $body = $body . $_->to_cpp_decl() . "\n";
    }

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
package Message;

sub to_cpp_decl
{
    my( $self ) = @_;

    my $res = "struct " . $self->{name};

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $res = $res . ": public " . $self->{base_class};
    }

    $res = $res . "\n";

    my $body = "";

    $body = $body . "enum\n" . main::bracketize( "message_id = " . $self->{message_id} . "\n", 1 ) . "\n";

    my @array = @{ $self->{members} };

    foreach( @array )
    {
        $body = $body . $_->to_cpp_decl() . "\n";
    }

    $res = $res . main::bracketize( $body, 1 );

    return $res;
}

############################################################
