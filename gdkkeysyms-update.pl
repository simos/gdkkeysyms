#!/usr/bin/env perl

# Updates http://svn.gnome.org/viewcvs/gtk%2B/trunk/gdk/gdkkeysyms.h?view=log from upstream (X.org 7.x),
# from http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob_plain;f=keysymdef.h
# 
# Author  : Simos Xenitellis <simos at gnome dot org>.
# Version : 1.2
#
# Input   : http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob_plain;f=keysymdef.h
# Output  : http://svn.gnome.org/svn/gtk+/trunk/gdk/gdkkeysyms.h
# 
# Notes   : It downloads keysymdef.h from the Internet, if not found locally,
# Notes   : and creates an updated gdkkeysyms.h
# Notes   : This version updates the source of gdkkeysyms.h from CVS to the GIT server.

use strict;

# Used for reading the keysymdef symbols.
my %keysyms;
my @keysymelements;
my $value;
my %registry;
my $val;

if ( ! -f "keysymdef.h" )
{
	print "Trying to download keysymdef.h from\n";
	print "http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob_plain;f=keysymdef.h\n";
	die "Unable to download keysymdef.h from http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob_plain;f=keysymdef.h\n" 
		unless system("wget -c -O keysymdef.h \"http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob_plain;f=keysymdef.h\"") == 0;
	print " done.\n\n";
}
else
{
	print "We are using existing keysymdef.h found in this directory.\n";
	print "It is assumed that you took care and it is a recent version\n";
	print "as found at http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob;f=keysymdef.h\n\n";
}


#if ( -f "gdkkeysyms.h" )
#{
#	print "There is already a gdkkeysyms.h file in this directory. We are not overwriting it.\n";
#	print "Please move it somewhere else in order to run this script.\n";
#	die "Exiting...\n\n";
#}

# Source: http://cvs.freedesktop.org/xorg/xc/include/keysymdef.h
die "Could not open file keysymdef.h: $!\n" unless open(IN_KEYSYMDEF, "<:utf8", "keysymdef.h");

# Output: gtk+/gdk/gdkkeysyms.h
die "Could not open file gdkkeysyms.h: $!\n" unless open(OUT_GDKKEYSYMS, ">:utf8", "gdkkeysyms.h.NEW");

print OUT_GDKKEYSYMS<<EOF;
/* GDK - The GIMP Drawing Kit
 * Copyright (C) 1995-1997 Peter Mattis, Spencer Kimball and Josh MacDonald
 * Copyright (C) 2005, 2006, 2007 GNOME Foundation
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/*
 * File auto-generated from script http://svn.gnome.org/viewcvs/gtk%2B/trunk/gdk/gdkkeysyms-update.pl
 * using the input file
 * http://gitweb.freedesktop.org/?p=xorg/proto/x11proto.git;a=blob_plain;f=keysymdef.h
 */

/*
 * Modified by the GTK+ Team and others 1997-2007.  See the AUTHORS
 * file for a list of people on the GTK+ Team.  See the ChangeLog
 * files for a list of changes.  These files are distributed with
 * GTK+ at ftp://ftp.gtk.org/pub/gtk/.
 */

#ifndef __GDK_KEYSYMS_H__
#define __GDK_KEYSYMS_H__

EOF


while (<IN_KEYSYMDEF>)
{
	next if ( ! /^#define / );

	@keysymelements = split(/\s+/);
	die "Internal error, no \@keysymelements: $_\n" unless @keysymelements;

	$_ = $keysymelements[1];
	die "Internal error, was expecting \"XC_*\", found: $_\n" if ( ! /^XK_/ );
	
	$_ = $keysymelements[2];
	die "Internal error, was expecting \"0x*\", found: $_\n" if ( ! /^0x/ );

	$keysymelements[1] =~ s/^XK_/GDK_/g;

	$value = hex($keysymelements[2]);
	if ($value >= 0x1000000)
	{
		print "WARNING: Got value > 0x1000000, keysym $keysymelements[1]: values $value, subtracting 0x1000000\n";
		$value -= 0x1000000;
	}
	if (exists($keysyms{$keysymelements[1]}))
	{
		print "ERROR: Got DUP for keysym $keysymelements[1]: values $value and $keysyms{$keysymelements[1]}\n";
	}
	@keysyms{$keysymelements[1]} = $value;

	if (exists($registry{$value}))
	{
		print "Got possible DUP for $value: $keysymelements[1] and $registry{$value}\n";
	}
	@registry{$value} = $keysymelements[1];

	$val = sprintf("0x%04X", $keysyms{$keysymelements[1]});
	printf OUT_GDKKEYSYMS "#define %-32s %9s\n", $keysymelements[1], $val;
}

# my @sorted = sort { $keysyms{$a} cmp $keysyms{$b} } keys %keysyms;
#
#foreach my $i (keys %keysyms)
#{
#	$val = sprintf("0x%04X", $keysyms{$i});	
#	printf OUT_GDKKEYSYMS "#define %-32s %9s\n", $i, $val;
#}
#
#$gdksyms{"0"} = "0000";

close IN_KEYSYMDEF;


print OUT_GDKKEYSYMS<<EOF;

#endif /* __GDK_KEYSYMS_H__ */
EOF

printf "\nWe just finished converting keysymdef.h to gdkkeysyms.h.NEW\nRename gdkkeysyms.h.NEW to gdkkeysyms.h\nThank you\n";
