#!/usr/bin/perl -w

# $Revision: 4911 $ $Date:: 2016-11-05 #$ $Author: serge $
# 1.0   - 16b04 - initial version

my $VER="1.0";

use strict;
use warnings;
use Objects;
use Objects_cpp;

{
    my @members = ( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    my $obj = new Object( "SomeObject",  \@members  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, 1 )
         );
    my $obj = new Object( "AnotherObject",  \@members  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
        new ElementExt( new Integer( 1, 8 ), "hh", new ValidRange( 1, 0, 1, 1, 23, 1 ), 0 ),
        new ElementExt( new Integer( 1, 8 ), "mm", new ValidRange( 1, 0, 1, 1, 59, 1 ), 0 )
         );
    my $obj = new Object( "TimeRange24",  \@members  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
        new ElementExt( new Integer( 1, 32 ), "user_id", new ValidRange( 1, 1, 1, 1, 32768, 0 ), 0 ),
         );
    my $obj = new BaseMessage( "GenericRequest",  \@members, undef );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
         );
    my $obj = new Message( "Request",  \@members, undef  );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
         );
    my $obj = new Message( "Request",  \@members, "base::Request" );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = (
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ),
        new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef )
         );
    my $obj = new Message( "Request2",  \@members, "base::Request" );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @members = 
    (
        new EnumElement( "RED", undef ),
        new EnumElement( "GREEN", undef ),
        new EnumElement( "BLUE", undef ),
    );

    my $obj = new Enum( "Colors", new Integer( 0, 8 ), \@members );
    print $obj->to_cpp_decl() . "\n";
}
{
    my @enum_members = 
    (
        new EnumElement( "DISCONNECTED", 1 ),
        new EnumElement( "CONNECTING", 2 ),
        new EnumElement( "CONNECTED", 3 ),
    );

    my @members = (
        new Enum( "State", new Integer( 0, 8 ), \@enum_members ),
        new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ),
        new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ),
        new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef ),
        new Element( new UserDefined( "State" ), "state" )
         );
    my $obj = new Message( "Request3",  \@members, "base::Request" );
    print $obj->to_cpp_decl() . "\n";
}
