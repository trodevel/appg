#!/usr/bin/perl -w

# $Revision: 5029 $ $Date:: 2016-11-18 #$ $Author: serge $
# 1.0   - 16b14 - initial version

package gtcpp;

require "gen_tools.pl";

############################################################
sub ifndef_define
{
    my ( $guard, $body ) = @_;

    my $guard_h = "${guard}_H";
    my $res =
"#ifndef $guard_h\n" .
"#define $guard_h\n\n" .
$body .
"#endif // $guard_h\n" ;

    return $res;
}
############################################################
sub namespacize
{
    my ( $name, $body ) = @_;

    my $res =
"namespace $name\n" .
"{\n\n" .
$body .
"} // namespace $name\n\n" ;

    return $res;
}
############################################################
sub ifndef_define_prot
{
    my ( $protocol_name, $file_name, $body ) = @_;

    my $guard = uc "APG_${protocol_name}_${file_name}";

    return ifndef_define( $guard, $body );
}
############################################################
sub array_to_decl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_decl() . "\n";
    }

    return $res;
}
############################################################
sub array_to_cpp_to_json_decl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_to_json_decl() . "\n";
    }

    return $res;
}
############################################################
sub array_to_cpp_to_json_impl
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . $_->to_cpp_to_json_impl() . "\n";
    }

    return $res;
}
############################################################
sub to_include
{
    my( $name ) = @_;

    return '#include "'.  $name . '.h"';
}
############################################################
sub array_to_include
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . to_include(  $_ ) . "\n";
    }

    return $res;
}
############################################################

1;
