#!/usr/bin/perl -w

# $Revision: 5018 $ $Date:: 2016-11-17 #$ $Author: serge $
# 1.0   - 16b04 - initial version

my $VER="1.0";

use strict;
use warnings;
use Objects;
use Objects_cpp;

{
    my $obj = new Object( "SomeObject" );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Object( "AnotherObject" );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, 1 ) );
    $obj->set_base_class( "test" );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Object( "TimeRange24" );
    $obj->add_member( new ElementExt( new Integer( 1, 8 ), "hh", new ValidRange( 1, 0, 1, 1, 23, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Integer( 1, 8 ), "mm", new ValidRange( 1, 0, 1, 1, 59, 1 ), 0 ) );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new BaseMessage( "GenericRequest", undef );
    $obj->add_member( new ElementExt( new Integer( 1, 32 ), "user_id", new ValidRange( 1, 1, 1, 1, 32768, 0 ), 0 ) );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Message( "Request", undef );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Message( "Request", "base::Request" );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Message( "Request2", "base::Request" );
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ) );
    $obj->add_member( new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef ) );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $obj = new Enum( "Colors", new Integer( 0, 8 ) );
    $obj->add_decl( new EnumElement( "RED", undef ) );
    $obj->add_decl( new EnumElement( "GREEN", undef ) );
    $obj->add_decl( new EnumElement( "BLUE", undef ) );
    print $obj->to_cpp_decl() . "\n";
}
{
    my $enum = new Enum( "State", new Integer( 0, 8 ) );
        
    $enum->add_decl( new EnumElement( "DISCONNECTED", 1 ) );
    $enum->add_decl( new EnumElement( "CONNECTING", 2 ) );
    $enum->add_decl( new EnumElement( "CONNECTED", 3 ) );
 
    my $obj = new Message( "Request3", "base::Request" );
 
    $obj->add_decl( $enum );   
    $obj->add_member( new ElementExt( new Integer( 0, 8 ), "pass_range", new ValidRange( 1, 1, 1, 1, 100, 1 ), 0 ) );
    $obj->add_member( new ElementExt( new Vector( new Integer( 0, 16 ) ), "user_ids", undef, undef ) );
    $obj->add_member( new ElementExt( new Map( new Integer( 1, 16 ), new String ), "id_to_name", undef, undef ) );
    $obj->add_member( new Element( new UserDefined( "State" ), "state" ) );
    
    print $obj->to_cpp_decl() . "\n";
}

