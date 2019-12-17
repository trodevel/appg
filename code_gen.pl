#!/usr/bin/perl -w

#
# Automatic Protocol Generator - Code Gen.
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
# SKV 19c7

# 1.0 - 19c07 - initial commit

my $VER="1.0";

###############################################

use strict;
use warnings;
use 5.010;
use Getopt::Long;


use File_cpp;
#use File_cpp_json;


###############################################

sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

###############################################

sub read_config_file($$$)
{
    my ( $filename, $array_ref, $line_num_ref ) = @_;

    unless( -e $filename )
    {
        print STDERR "ERROR: file $filename doesn't exist\n";
        exit;
    }

    print "reading file $filename ...\n";

    open RN, "<", $filename;

    my $lines = 0;

    while( <RN> )
    {
        chomp;
        $lines++;

        # skip empty lines
        s/^\s+//g; # no leading white spaces
        next unless length;

        my $line = trim( $_ );

        next if( $line =~ /^#/ );	# ignore comments

        push( @$array_ref,  $line );
        push( @$line_num_ref, $lines );

        #print "DEBUG: $lines: $line\n";
    }

    print "read $lines lines(s) from $filename\n";
}

###############################################

use constant KW_CONST       => 'const';
use constant KW_ENUM        => 'enum';
use constant KW_ENUM_END    => 'enum_end';
use constant KW_BASE_MSG    => 'base_msg';
use constant KW_BASE_MSG_END    => 'base_msg_end';
use constant KW_MSG         => 'msg';
use constant KW_MSG_END     => 'msg_end';

use constant REGEXP_ID_NAME => '[a-zA-Z0-9_]+';
use constant REGEXP_ID_NAME_W_BASE_CLASS => "(${\REGEXP_ID_NAME}::|)${\REGEXP_ID_NAME}";
use constant REGEXP_INT_NUM   => '[0-9]+';
use constant REGEXP_FLOAT_NUM => '[0-9\.]+';
use constant REGEXP_NUMBER => "${\REGEXP_INT_NUM}|${\REGEXP_FLOAT_NUM}";
use constant REGEXP_BOOL   => 'bool';
use constant REGEXP_INT    => '([u]*)int(8|16|32|64)';
use constant REGEXP_FLOAT  => 'float';
use constant REGEXP_DOUBLE => 'double';
use constant REGEXP_STR    => 'string';
use constant REGEXP_POD    => "${\REGEXP_BOOL}|${\REGEXP_INT}|${\REGEXP_FLOAT}|${\REGEXP_DOUBLE}|${\REGEXP_STR}";
use constant REGEXP_VR     => ':\s*([\(\[])\s*([0-9\.]*)\s*,\s*([0-9\.]*)\s*([\)\]])';
use constant REGEXP_DT_OBJ    => "o ${\REGEXP_ID_NAME}";
use constant REGEXP_DT_ENUM   => "e ${\REGEXP_ID_NAME}";
use constant REGEXP_DT_ARRAY  => 'a';
use constant REGEXP_DT_MAP    => 'm';
use constant REGEXP_DT_USER_DEF     => "${\REGEXP_DT_OBJ}|${\REGEXP_DT_ENUM}";
use constant REGEXP_DT     => "${\REGEXP_POD}|${\REGEXP_DT_OBJ}|${\REGEXP_DT_ENUM}|${\REGEXP_DT_ARRAY}|${\REGEXP_DT_MAP}";

###############################################

sub to_ValidRange($)
{
    my ( $line ) = @_;

    die "malformed valid range '$line'" if( $line !~ /(${\REGEXP_VR}|)/ );

    my $open_bracket  = $2;
    my $from          = $3;
    my $to            = $4;
    my $close_bracket = $5;

    my $has_from = ( defined $from and $from ne '' ) ? 1 : 0;
    my $has_to   = ( defined $to and $to ne '' ) ? 1 : 0;

    $from     = ( $has_from ) ? $from + 0 : 0;
    $to       = ( $has_to ) ? $to + 0 : 0;

    my $is_inclusive_from = ( $has_from and $open_bracket eq '[' ) ? 1 : 0;
    my $is_inclusive_to   = ( $has_to and $close_bracket eq ']' ) ? 1 : 0;

    print STDERR "DEBUG: to_ValidRange: incl_from=$is_inclusive_from from=$from to=$to incl_to=$is_inclusive_to\n";

    my $res = new ValidRange( $has_from, $from, $is_inclusive_from, $has_to, $to, $is_inclusive_to );

    return $res;
}

###############################################

sub to_Boolean($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_BOOL}/ );

    my $res = new Boolean();

    return $res;
}

sub to_Integer($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_INT}/ );

    my $u = $1;
    my $bits = $2;

    print STDERR "DEBUG: to_Integer: u=$u bits=$bits\n";

    my $is_unsigned = ( defined $u and $u eq 'u' ) ? 1 : 0;
    $bits = $bits + 0;

    my $res = new Integer( $is_unsigned, $bits );

    return $res;
}

sub to_Float($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_FLOAT}/ );

    my $res = new Float( 0 );

    return $res;
}

sub to_Double($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_DOUBLE}/ );

    my $res = new Float( 1 );

    return $res;
}

sub to_String($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_STR}/ );

    my $res = new String();

    return $res;
}

sub to_user_defined_dt($)
{
    my ( $line ) = @_;

    die "malformed data type '$line'" if( $line !~ /^${\REGEXP_DT_USER_DEF}/ );

    my @elem = split( ' ', $line );

    my $pref = $elem[0];
    my $name = $elem[1];

    my $res = ( $pref eq 'o' ) ? new UserDefined( $name ) : new UserDefinedEnum( $name );

    return $res;
}

###############################################

sub to_data_type($)
{
    my ( $line ) = @_;

    if( $line =~ /^${\REGEXP_BOOL}/ )
    {
        return to_Boolean( $line );
    }
    elsif( $line =~ /^${\REGEXP_INT}/ )
    {
        return to_Integer( $line );
    }
    elsif( $line =~ /^${\REGEXP_FLOAT}/ )
    {
        return to_Float( $line );
    }
    elsif( $line =~ /^${\REGEXP_DOUBLE}/ )
    {
        return to_Double( $line );
    }
    elsif( $line =~ /^${\REGEXP_STR}/ )
    {
        return to_String( $line );
    }
    elsif( $line =~ /^${\REGEXP_DT_USER_DEF}/ )
    {
        return to_user_defined_dt( $line );
    }

    die "to_data_type: unknown data type '$line'\n";
}

###############################################

sub is_string($)
{
    my ( $line ) = @_;

    return 1 if ( $line =~ /^${\REGEXP_STR}/ );

    return 0;
}

###############################################

sub parse_pod($$)
{
    my ( $parent_ref, $line ) = @_;

    die "parse_pod: malformed object $line" if( $line !~ /^(${\REGEXP_POD})\s*(${\REGEXP_ID_NAME})\s*(${\REGEXP_VR}|)/ );

    my $dt_str  = $1;
    my $name    = $4;
    my $valid   = $5;

    print STDERR "DEBUG: parse_pod: dt_str=$dt_str name=$name valid='$valid'\n";

    my $dt = to_data_type( $dt_str );

    my $valid_range = undef;

    if( defined $valid and $valid ne '' )
    {
        $valid_range = to_ValidRange( $valid );
    }

    my $is_array = is_string( $dt_str );

    $$parent_ref->add_member( new ElementExt( $dt, $name, $valid_range, $is_array ) );
}

###############################################

sub parse_user_defined($$)
{
    my ( $parent_ref, $line ) = @_;

    die "parse_pod: malformed object $line" if( $line !~ /^(${\REGEXP_DT_USER_DEF})\s*(${\REGEXP_ID_NAME})/ );

    my $dt_str  = $1;
    my $name    = $2;

    print STDERR "DEBUG: parse_user_defined: dt_str=$dt_str name=$name\n";

    my $dt = to_data_type( $dt_str );

    $$parent_ref->add_member( new ElementExt( $dt, $name, undef, 0 ) );
}

###############################################

sub parse_const($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $line ) = @_;

    die "parse_const: malformed $line" if( $line !~ /${\KW_CONST}\s*(${\REGEXP_POD})\s*(${\REGEXP_ID_NAME})\s*=\s*(${\REGEXP_NUMBER})/ );

    my $dt_str = $1;
    my $name   = $4;
    my $val    = $5;

    print STDERR "DEBUG: parse_const: dt_str=$dt_str name=$name val=$val\n";

    my $dt = to_data_type( $dt_str );

    my $obj = new ConstElement( $dt, $name, $val );

    $$file_ref->add_const( $obj );
}

###############################################

sub parse_enum_member($$)
{
    my ( $parent_ref, $line ) = @_;

    die "parse_enum_member: malformed object $line" if( $line !~ /^(${\REGEXP_ID_NAME})\s*(=\s*(${\REGEXP_VR}|${\REGEXP_INT_NUM})|)/ );

    my $name    = $1;
    my $init    = $2;
    my $val     = $3;

    my $has_val = ( defined $val and $val ne '' ) ? 1 : 0;

    print STDERR "DEBUG: parse_enum_member: name=$name has_val='$has_val'\n";

    my $res = $has_val ? new EnumElement( $name, $val ) : new EnumElement( $name, undef );

    $$parent_ref->add_element( $res );
}

###############################################

sub parse_enum($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $line ) = @_;

    die "parse_enum: malformed $line" if( $line !~ /${\KW_ENUM}\s*(${\REGEXP_ID_NAME})\s*(:\s*(${\REGEXP_INT})|)/ );

    $$i_ref++;

    my $name   = $1;
    my $dt_str = $3;

    my $dt = ( defined $dt_str and $dt_str ne '' ) ? to_data_type( $dt_str ) : undef;

    my $obj = new Enum( $name, $dt );

    for( ; $$i_ref < $size; $$i_ref++ )
    {
        #print STDERR "DEBUG: i=$$i_ref size=$size\n";

        my $line = @$array_ref[$$i_ref];

        if ( $line =~ /^${\KW_ENUM_END}/ )
        {
            print STDERR "DEBUG: enum_end\n";
            $$file_ref->add_enum( $obj );
            return;
        }
        elsif ( $line =~ /^${\REGEXP_ID_NAME}/ )
        {
            print STDERR "DEBUG: enum_member\n";
            parse_enum_member( \$obj, $line );
        }
        else
        {
            die( "parse_enum: cannot parse line '$line'" );
        }
    }

    die( "incomplete enum $name\n" );
}

###############################################

sub parse_obj($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $line ) = @_;

    die "malformed object $line" if( $line !~ /obj ([a-zA-Z0-9_]*)/ );

    $$i_ref++;

    my $name = $1;

    my $obj = new Object( $name );

    for( ; $$i_ref < $size; $$i_ref++ )
    {
        #print STDERR "DEBUG: i=$$i_ref size=$size\n";

        my $line = @$array_ref[$$i_ref];

        if ( $line =~ /^obj_end/ )
        {
            print STDERR "DEBUG: obj_end\n";
            $$file_ref->add_obj( $obj );
            return;
        }
        elsif ( $line =~ /^${\REGEXP_POD} / )
        {
            print STDERR "DEBUG: pod\n";
            parse_pod( \$obj, $line );
        }
        elsif ( $line =~ /^${\REGEXP_DT_USER_DEF} / )
        {
            print STDERR "DEBUG: user_defined\n";
            parse_user_defined( \$obj, $line );
        }
        else
        {
            die( "parse_obj: cannot parse line '$line'" );
        }
    }

    die( "incomplete object $name\n" );
}

###############################################

sub parse_base_msg($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $line ) = @_;

    die "malformed object $line" if( $line !~ /${\KW_BASE_MSG}\s*(${\REGEXP_ID_NAME})\s*(:\s*(${\REGEXP_ID_NAME_W_BASE_CLASS})|)/ );

    $$i_ref++;

    my $name            = $1;
    my $opt_base_name   = $3;

    my $obj = new BaseMessage( $name, $opt_base_name );

    for( ; $$i_ref < $size; $$i_ref++ )
    {
        #print STDERR "DEBUG: i=$$i_ref size=$size\n";

        my $line = @$array_ref[$$i_ref];

        if ( $line =~ /^${\KW_BASE_MSG_END}/ )
        {
            print STDERR "DEBUG: base_msg_end\n";
            $$file_ref->add_base_msg( $obj );
            return;
        }
        elsif ( $line =~ /^${\REGEXP_POD} / )
        {
            print STDERR "DEBUG: pod\n";
            parse_pod( \$obj, $line );
        }
        elsif ( $line =~ /^${\REGEXP_DT_USER_DEF} / )
        {
            print STDERR "DEBUG: user_defined\n";
            parse_user_defined( \$obj, $line );
        }
        else
        {
            die( "parse_base_msg: cannot parse line '$line'" );
        }
    }

    die( "incomplete object $name\n" );
}

###############################################

sub parse_msg($$$$$)
{
    my ( $array_ref, $file_ref, $size, $i_ref, $line ) = @_;

    die "malformed object $line" if( $line !~ /${\KW_MSG}\s*(${\REGEXP_ID_NAME})\s*(:\s*(${\REGEXP_ID_NAME_W_BASE_CLASS})|)/ );

    $$i_ref++;

    my $name            = $1;
    my $opt_base_name   = $3;

    print STDERR "DEBUG: parse_msg: name=$name opt_base_name=" . ((defined $opt_base_name) ? $opt_base_name : "<undef>" )  ."\n";

    my $obj = new Message( $name, $opt_base_name );

    for( ; $$i_ref < $size; $$i_ref++ )
    {
        #print STDERR "DEBUG: i=$$i_ref size=$size\n";

        my $line = @$array_ref[$$i_ref];

        if ( $line =~ /^${\KW_MSG_END}/ )
        {
            print STDERR "DEBUG: msg_end\n";
            $$file_ref->add_msg( $obj );
            return;
        }
        elsif ( $line =~ /^${\REGEXP_POD} / )
        {
            print STDERR "DEBUG: pod\n";
            parse_pod( \$obj, $line );
        }
        elsif ( $line =~ /^${\REGEXP_DT_USER_DEF} / )
        {
            print STDERR "DEBUG: user_defined\n";
            parse_user_defined( \$obj, $line );
        }
        else
        {
            die( "parse_msg: cannot parse line '$line'" );
        }
    }

    die( "incomplete object $name\n" );
}

###############################################

sub parse($$)
{
    my ( $array_ref, $file_ref ) = @_;

    my $size = scalar( @$array_ref );

    for( my $i = 0; $i < $size; $i++ )
    {
        my $line = @$array_ref[$i];

        #print STDERR "DEBUG: i=$i, line=$line\n";

        if ( $line =~ /protocol (${\REGEXP_ID_NAME})/ )
        {
            print STDERR "DEBUG: protocol $1\n";
            $$file_ref->set_name( $1 );
        }
        elsif ( $line =~ /base (${\REGEXP_ID_NAME})/ )
        {
            print STDERR "DEBUG: base protocol $1\n";
            $$file_ref->set_base_prot( $1 );
        }
        elsif ( $line =~ /include "([a-zA-Z0-9_\/\.\-]*)"/ )
        {
            print STDERR "DEBUG: include '$1'\n";
            $$file_ref->add_include( $1 );
        }
        elsif ( $line =~ /${\KW_CONST} / )
        {
            print STDERR "DEBUG: const\n";

            parse_const( $array_ref, $file_ref, $size, \$i, $line );
        }
        elsif ( $line =~ /${\KW_ENUM} (${\REGEXP_ID_NAME})/ )
        {
            print STDERR "DEBUG: enum $1\n";

            parse_enum( $array_ref, $file_ref, $size, \$i, $line );
        }
        elsif ( $line =~ /obj (${\REGEXP_ID_NAME})/ )
        {
            print STDERR "DEBUG: obj $1\n";

            parse_obj( $array_ref, $file_ref, $size, \$i, $line );
        }
        elsif ( $line =~ /${\KW_BASE_MSG} (${\REGEXP_ID_NAME})/ )
        {
            print STDERR "DEBUG: base_msg $1\n";

            parse_base_msg( $array_ref, $file_ref, $size, \$i, $line );
        }
        elsif ( $line =~ /${\KW_MSG} (${\REGEXP_ID_NAME})/ )
        {
            print STDERR "DEBUG: msg $1\n";

            parse_msg( $array_ref, $file_ref, $size, \$i, $line );
        }
        else
        {
            die "FATAL: unknown line $line\n";
        }
    }

}

###############################################

sub print_help
{
    print STDERR "\nUsage: code_gen.sh --input_file <input.txt> --output_file <output.h>\n";
    print STDERR "\nExamples:\n";
    print STDERR "\ncode_gen.sh --input_file protocol.txt --output_file protocol.h\n";
    print STDERR "\n";
    exit
}

###############################################

my $input_file;
my $output_file;

my $verbose = 0;

GetOptions(
            "input_file=s"      => \$input_file,   # string
            "output_file=s"     => \$output_file,  # string
            "verbose"           => \$verbose   )   # flag
  or die("Error in command line arguments\n");

&print_help if not defined $input_file;
&print_help if not defined $output_file;

print STDERR "input_file  = $input_file\n";
print STDERR "output file = $output_file\n";

my @input = ();
my @line_num = ();

read_config_file( $input_file, \@input, \@line_num );

my $file = new File( "example" );

parse( \@input, \$file );

$file->set_use_ns( 0 );

open FO, ">", $output_file;

print FO $file->to_cpp_decl() . "\n";

###############################################
1;
