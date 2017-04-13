#!/usr/local/bin/perl5
#This is the Jefferson Memorandum Book Perl script
#Prepared to convert "Script" tag files to TEI P5
#Prepared by Stephen Perkins of Infoset Digital Publishing http://www.infoset.io

use strict;

open (IN, $ARGV[0]);
open (OUT, ">$ARGV[1]");

while (<IN>) {


	# fix a few things before line ends go back in

	# italics starting deletions that straddle lines
	s/\.us on \.([a-z]+)\;\;oa/\.$1\;\.us on ;oa/g;
	# weird case like Nov. 20 with parens between commands (as in text)
	s/\.us\;\(\;oa/\(\.us\;\;oa/g;


	# ok now line ends
	s/(\.month|\.day|\.sday|\.year|\.\'?cm|\.xday|\.xlist|\.daylist|\.sublist|\.pa|\.\'?etbt|\.\'?bt|\.text|\.ce|\.pp)/\n$1/g;

	
	print OUT;
}

