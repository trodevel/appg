#!/usr/bin/perl -w

#
# Automatic Protocol Generator - CodeGen_cpp.
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
require Objects_cpp;
require "gen_tools_cpp.pl";

###############################################

package CodeGen_cpp;

use strict;
use warnings;
use 5.010;

############################################################

sub generate_enums($)
{
    my ( $file_ref ) = @_;

    my $body;

    $body = "enum class request_type_e\n";

    my $msgs = "UNDEF,\n";

    foreach( @{ $$file_ref->{msgs} } )
    {
        $msgs = $msgs . $_->{name} . ",\n";
    }

    $body = $body . main::bracketize( $msgs, 1 ) . "\n";

    my $res = to_include_guards( $$file_ref, $body, "", "enums", 0, 0, [] );

    return $res;
}

###############################################

1;
