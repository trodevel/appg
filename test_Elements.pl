#!/usr/bin/perl -w

# $Revision: 4955 $ $Date:: 2016-11-08 #$ $Author: serge $
# 1.0   - 16a17 - initial version

my $VER="1.0";

use strict;
use warnings;
use Elements;
use Elements_cpp;

{
    my $obj = new Element( new Integer( 0, 8 ), "number_of_users" );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new EnumElement( "IDLE", undef );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new EnumElement( "RED", 0 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ConstElement( new Integer( 1, 16 ), "HTTP_PORT", 80 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ConstElement( new Float( 1 ), "PI", 3.141592 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ValidRange( 0, 0, 0, 0, 0, 0 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ValidRange( 0, 0, 0, 1, 99, 0 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ValidRange( 0, 0, 0, 1, 99, 1 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ValidRange( 1, 17, 0, 1, 99, 1 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ValidRange( 1, 17, 1, 1, 99, 1 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", new ValidRange( 1, 0, 1, 1, 1024, 1 ), 1 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, 1 );
    print $obj->to_cpp_decl() . "\n";
}
