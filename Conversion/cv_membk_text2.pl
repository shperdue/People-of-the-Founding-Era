#!/usr/local/bin/perl5
#This is the Jefferson Memorandum Book Perl script
#Prepared to convert "Script" tag files to TEI P5
#Prepared by Stephen Perkins of Infoset Digital Publishing http://www.infoset.io

use strict;

open (IN, $ARGV[0]);
open (OUT, ">$ARGV[1]");

while (<IN>) {



# OK SECTION
	# cancel and restart of italics means nothing
	s/\@ \.us;/ /g;



# TBD SECTION

	# italics
	s/\.us\;/<hi rend=\"italic\">/g;
	s/\@/<\/hi>/g;

	
	print OUT;
}
