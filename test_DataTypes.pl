#!/usr/bin/perl -w

# $Revision: 4907 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16a17 - initial version

my $VER="1.0";

use DataTypes;
use DataTypes_cpp;

{
    my $obj = new Integer( 0, 8 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 0, 16 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 0, 32 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 0, 64 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 1, 8 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 1, 16 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 1, 32 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Integer( 1, 64 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Float( 0 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Float( 1 );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Vector( new Integer( 0, 16 ) );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Map( new Integer( 0, 16 ), new String );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new UserDefined( "MyObject" );
    print $obj->to_cpp_decl() . "\n";
}
