#!/usr/bin/perl -w

# $Revision: 5002 $ $Date:: 2016-11-15 #$ $Author: serge $
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

1;
