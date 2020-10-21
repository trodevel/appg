#!/usr/bin/perl -w

#
# Automatic Protocol Parser Generator - CodeGen_php.
#
# Copyright (C) 2019 Sergey Kolevatov
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

# $Id $
# SKV 19c25

# 1.0 - 19c25 - initial commit

###############################################

require File;
require Objects_php;
require "gen_tools_php.pl";

###############################################

package CodeGen_php;

use strict;
use warnings;
use 5.010;

###############################################

sub get_namespace_name($)
{
    my( $file ) = @_;

    return $file->{name};
}

###############################################

sub namespacize($$)
{
    my( $file, $body ) = @_;

    my $name = get_namespace_name( $file );

    #print "DEBUG: name = $name\n";

    if( $file->{must_use_ns} )
    {
        $name = 'apg\\' . $name;
    }

    #print "DEBUG: name = $name\n";

    my $res = gtphp::namespacize( $name, $body );

    #print "DEBUG: res = $res\n";

    return $res;
}

############################################################

sub add_php_header_footer($)
{
    my( $body ) = @_;

    return "<?php\n\n" . $body . "\n?>\n";
}

############################################################

sub to_include_guards($$$$$$$$)
{
    my( $file, $body, $alternative_namespace, $prefix, $must_include_myself, $must_include_userdef, $other_incl_ref, $system_incl_ref ) = @_;

    if( defined $must_include_myself && $must_include_myself == 1 )
    {
        $body =
            gtphp::to_include( $file->{name} . "/protocol" ) . "    // self\n\n" . $body;
    }

    if( defined $must_include_userdef && $must_include_userdef == 1 )
    {
        my @includes  = @{ $file->{includes} };     # includes

        $body = "// includes for used modules\n" .
            gtphp::array_to_include_ext( \@includes ) . "\n" . $body;
    }

    if( defined $other_incl_ref && scalar @$other_incl_ref > 0 )
    {
        $body = "// includes\n" .
            gtphp::array_to_include( $other_incl_ref ) . "\n" . $body;
    }

    if( defined $system_incl_ref && scalar @$system_incl_ref > 0 )
    {
        $body = "// system includes\n" .
            gtphp::array_to_include( $system_incl_ref ) . "\n" . $body;
    }

    my $res = ( $alternative_namespace ne '' ) ? gtphp::namespacize( $alternative_namespace, $body ) : namespacize( $file, $body );

    #my $res = gtphp::ifndef_define_prot( $file->{name}, $prefix, $body );

    return add_php_header_footer( $res );
}

############################################################

sub to_body($$$$$$)
{
    my( $file, $body, $alternative_namespace, $base_incl, $own_incl_ref, $other_incl_ref ) = @_;

    if( defined $own_incl_ref && scalar @$own_incl_ref > 0 )
    {
        $body = "// own includes\n" .
            gtphp::array_to_include_w_path( $file->{name}, $own_incl_ref ) . "\n" . $body;
    }

    if( defined $other_incl_ref && scalar @$other_incl_ref > 0 )
    {
        $body = "// includes\n" .
            gtphp::array_to_include( $other_incl_ref ) . "\n" . $body;
    }

    if( $base_incl ne '' && $file->has_base_prot() )
    {
        $body = "// base include\n" .
            gtphp::to_include_w_path( $file->{base_prot}, $base_incl ) . "\n" . $body;
    }

    my $res = ( $alternative_namespace ne '' ) ? gtphp::namespacize( $alternative_namespace, $body ) : namespacize( $file, $body );

    return add_php_header_footer( $res );
}

############################################################

1;
