#!/usr/local/bin/perl5
#This is the Jefferson Memorandum Book Perl script
#Prepared to convert "Script" tag files to TEI P5
#Prepared by Stephen Perkins of Infoset Digital Publishing http://www.infoset.io

use strict;

open (IN, $ARGV[0]);
open (OUT, ">$ARGV[1]");

while (<IN>) {


	# remove line ends in preprocess 1
	s/[\t\n\r]/ /g;


	
	print OUT;
}

