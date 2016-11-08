#!/usr/bin/perl -w

# $Revision: 4954 $ $Date:: 2016-11-08 #$ $Author: serge $
# 1.0   - 16b08 - initial version

my $VER="1.0";

use strict;
use warnings;
use Objects;
use Objects_cpp_json;

{
    my @decls = ();
    my @members = ( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    my $obj = new Object( "SomeObject",  \@decls, \@members );
    print $obj->to_cpp_json() . "\n";
}
{
    my @decls = ();
    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, 1 )
         );
    my $obj = new Object( "AnotherObject",  \@decls, \@members  );
    print $obj->to_cpp_json() . "\n";
}
{
    my @decls = ();
    my @members = (
        new ElementExt( new Integer( 1, 8 ), "hh", new ValidRange( 1, 0, 1, 1, 23, 1 ), 0 ),
        new ElementExt( new Integer( 1, 8 ), "mm", new ValidRange( 1, 0, 1, 1, 59, 1 ), 0 )
         );
    my $obj = new Object( "TimeRange24",  \@decls, \@members  );
    print $obj->to_cpp_json() . "\n";
}
{
    my @decls = ();
    my @members = (
        new ElementExt( new Integer( 1, 32 ), "user_id", new ValidRange( 1, 1, 1, 1, 32768, 0 ), 0 ),
         );
    my $obj = new BaseMessage( "GenericRequest",  \@decls, \@members, undef );
    print $obj->to_cpp_json() . "\n";
}
{
    my @decls = ();
    my @members = (
         );
    my $obj = new Message( "Request",  \@decls, \@members, undef  );
    print $obj->to_cpp_json() . "\n";
}
{
    my @decls = ();
    my @members = (
         );
    my $obj = new Message( "Request",  \@decls, \@members, "base::Request" );
    print $obj->to_cpp_json() . "\n";
}
{
    my @decls = ();
    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ),
        new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef )
         );
    my $obj = new Message( "Request2",  \@decls, \@members, "base::Request" );
    print $obj->to_cpp_json() . "\n";
}
{
    my @members = 
    (
        new EnumElement( "RED", undef ),
        new EnumElement( "GREEN", undef ),
        new EnumElement( "BLUE", undef ),
    );

    my $obj = new Enum( "Colors", new Integer( 0, 8 ), \@members );
    print $obj->to_cpp_json() . "\n";
}
{
    my @enum_members = 
    (
        new EnumElement( "DISCONNECTED", 1 ),
        new EnumElement( "CONNECTING", 2 ),
        new EnumElement( "CONNECTED", 3 ),
    );

    my @decls = (
        new Enum( "State", new Integer( 0, 8 ), \@enum_members ));

    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ),
        new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef ),
        new Element( new UserDefined( "State" ), "state" )
         );
    my $obj = new Message( "Request3",  \@decls, \@members, "base::Request" );
    print $obj->to_cpp_json() . "\n";
}
