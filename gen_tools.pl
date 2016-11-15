#!/usr/bin/perl -w

# $Revision: 4998 $ $Date:: 2016-11-15 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
sub tabulate
{
    my ( $body ) = @_;

    my $res = "";

    my @lines = split /\n/, $body;
    foreach my $line( @lines )
    {
        $res = $res . "    " . $line . "\n";
    }

    return  $res;
}
############################################################
sub bracketize
{
    my ( $body, $must_put_semicolon ) = @_;

    my $res = "{\n";

    $res = $res . tabulate( $body );

    my $semic = "";

    if( defined $must_put_semicolon && $must_put_semicolon == 1 )
    {
        $semic = ";";
    }

    $res = $res . "}$semic\n";


    return  $res;
}

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
sub array_to_cpp_decl
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
sub to_cpp_include
{
    my( $name ) = @_;

    return '#include "'.  $name . '.h"';
}
############################################################
sub array_to_cpp_include
{
    my( $array_ref ) = @_;

    my @array = @{ $array_ref };

    my $res = "";
    foreach( @array )
    {
        $res = $res . to_cpp_include(  $_ ) . "\n";
    }

    return $res;
}
############################################################

1;
