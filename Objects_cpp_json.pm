#!/usr/bin/perl -w

# $Revision: 5036 $ $Date:: 2016-11-18 #$ $Author: serge $
# 1.0   - 16b08 - initial version

require Objects;
require Elements_cpp_json;
require Objects_cpp;

############################################################
package IObject;

sub to_cpp_json
{
    my( $self ) = @_;

    my $res = "";

    my $base = "Object";

    if( defined $self->{base_class} && $self->{base_class} ne '' )
    {
        $base = $self->{base_class};
    }

    $res = $res . "<< to_json( static_cast<const " . $base . "*>( this ) )\n";

    my @array = @{ $self->{members} };

    foreach( @array )
    {
        $res = $res . "<< " . $_->to_cpp_json() . "\n";
    }

    return $res;
}

sub to_cpp_to_json_func_name
{
    my( $self ) = @_;

    return "std::string to_json( const " . $self->{name} . " & o )";
}

sub to_cpp_to_json_decl
{
    my( $self ) = @_;

    return $self->to_cpp_to_json_func_name() . ";";
}

sub to_cpp_to_json_impl
{
    my( $self ) = @_;

    my $body = $self->to_cpp_to_json_impl_body();

    my $res =  $self->to_cpp_to_json_func_name() . "\n"
        . main::bracketize( $body );

    return $res;
}

# must be overriden
sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    return "#error not implemented yet";
}
############################################################
package Enum;

sub to_cpp_json
{
    my( $self ) = @_;

    return "";
}

############################################################
package ObjectWithMembers;

sub to_cpp_to_json_impl_body
{
    my( $self ) = @_;

    my $res =
        "std::ostringstream os;\n\n" .
        "os " . $self->SUPER::to_cpp_json() . ";\n\n" .
        "return os.str();";

    return $res;
}
############################################################
package Object;

############################################################
package BaseMessage;

############################################################
package Message;

############################################################
