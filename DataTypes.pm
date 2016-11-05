#!/usr/bin/perl -w

# $Revision: 4903 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
package Generic;

sub new
{
    my $class = shift;
    my $self =
    {
    };

    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "#error 'not implemented yet'";
}


############################################################
package Integer;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{is_unsigned}  = $_[1];
    $self->{bit_width}    = $_[2];
    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;

    my $prefix = "";

    if( $self->{is_unsigned} == 1 )
    {
        $prefix = "u";
    }
    return "${prefix}int" . $self->{bit_width} . "_t";
}

############################################################
package Float;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{is_double}  = $_[1];
    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;
    if( $self->{is_double} == 1 )
    {
        return "double";
    }
    return "float";
}

############################################################
package String;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::string";
}

############################################################
package UserDefined;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{name}  = $_[1];
    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;
    return $self->{name};
}

############################################################
package Vector;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{value_type}  = $_[1];
    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::vector<" . $self->{value_type}->to_cpp_decl() . ">";
}

############################################################
package Map;

use strict;
our @ISA = qw( Generic );

sub new
{
    my ($class) = @_;

    my $self = $class->SUPER::new();
    $self->{key_type}         = $_[1];
    $self->{mapped_type}      = $_[2];
    bless $self, $class;
    return $self;
}

sub to_cpp_decl()
{
    my( $self ) = @_;
    return "std::map<" . $self->{key_type}->to_cpp_decl() . ", " . $self->{mapped_type}->to_cpp_decl() . ">";
}

############################################################

