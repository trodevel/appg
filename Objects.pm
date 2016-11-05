#!/usr/bin/perl -w

# $Revision: 4904 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

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
use strict;
use warnings;

require Element;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        members   => shift,
    };

    bless $self, $class;
    return $self;
}

sub to_cpp_decl
{
    my( $self ) = @_;
    return '#error not implemented yet';
}

############################################################
package Enum;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[3] );

    $self->{data_type}  = $_[2];

    bless $self, $class;
    return $self;
}

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
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[2] );

    bless $self, $class;
    return $self;
}

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
package Message;
use strict;
use warnings;

our @ISA = qw( IObject );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new( $_[1], $_[2] );

    $self->{base_class}  = $_[3];
    $self->{message_id}  = 0;

    bless $self, $class;
    return $self;
}

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
