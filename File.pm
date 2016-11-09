#!/usr/bin/perl -w

# $Revision: 4956 $ $Date:: 2016-11-09 #$ $Author: serge $
# 1.0   - 16b09 - initial version

############################################################
package File;
use strict;
use warnings;

sub new
{
    my $class = shift;
    my $self =
    {
        name      => shift,
        includes  => shift,     # includes
        enums     => shift,     # enums
        objs      => shift,     # objects
        base_msgs => shift,     # base messages
        msgs      => shift,     # messages
    };

    bless $self, $class;
    return $self;
}

############################################################
