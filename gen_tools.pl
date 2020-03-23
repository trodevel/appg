#!/usr/bin/perl -w

# Code generation tools
#
# Copyright (C) 2016 Sergey Kolevatov
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# $Revision: 12860 $ $Date:: 2020-03-24 #$ $Author: serge $
# 1.0   - 16b04 - initial version

############################################################
sub tabulate
{
    my ( $body ) = @_;

    my $res = "";

    my @lines = split /\n/, $body;
    foreach my $line( @lines )
    {
        if( $line =~ /^\s*$/ )
        {
            $res .= "\n";
            next;
        }

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
