#!/usr/local/bin/perl5

#This is the Jefferson Memorandum Book Perl script
#This file converts TEX note files to TEI tagged note id files
#Prepared by Jeffrey Feldman, Electronic Text Center

use strict;

open (IN, $ARGV[0]);
open (OUT, ">$ARGV[1]");

while (<IN>) {

 s/[\n\r]/ /g;

#first kill all the \note tags:
   s/\\note/<\/p>\n/g;

#kill \one space tag:
	s/\\one/ /g;

#italics {\it{   }}
	 s/\{\\it\{\s*(.*?)\}\}/<hi rend=\"italic\">$1<\/hi>/g;
	 s/\\it\s*/<hi rend=\"italic\">/g;
	 s/\s*[\/\\]+rm\s*/<\/hi> /g; 

# greek
    s/\\greek/<hi rend=\"greek\">/g;

#Quotation marks; changes <``> to "
	 s/\`\`/“/g;
	 s/\'\'/”/g;

#removes \- tag
	 s/\\\-//g;

#cut out \hbox:
	 s/\\hbox//g;

#cut out \pageno tag
	 s/\\pageno....//g;
	 s/\\pageno...//g;

#comments out \mark tag
	 s/\\mark/<div2 type=\"notes\">\n<head>/g;
	 s/\\\\mbooks\\\\fn1\.tex/<\/head>\n/g;

#\par paragraph
	 s/\\parindent ([\d\.]+(pt|em))/<\?style indent $1\?>/g;
	 s/\\hangindent ([\d\.]+(pt|em))/<\?style hangindent $1\?>/g;
	 s/\\noindent/<\?style noindent $1\?>/g;
	 s/\\par/\n<\/p>\n<p>/g;
	 s/\\landpar/\n<\/p>\n<p>/g;

# chcode??
s/\\chcode\'(\d+=\d+)/<\?style chcode$1\?>/g;


# \bf configuration which means "block caps"
	 s/\{\\bf\{(.*?)\}\}/<hi rend=\"small-caps\">$1<\/hi>/g;

#deals with note target ids:
	 s/\\efn\{(\d+)\}(\\th| )/<\/note><note type=\"editorial-footnote\" xml\:id\=\"n$1\" n=\"$1\"><p>/g;

#cleans up extra {  } brackets which don't seem to mean anything:
#	 s/\{(.*?)\}/$1/g;


# further improvements 2014
# character conversions
s/\\\'e/é/g;
s/\&/\&amp\;/g;
s/\\bp\s*/£/g;
s/\\A a/â/g;
s/\{\.\\th\.\\th\.\}/\.\&\#x2009\;\.\&\#x2009\;\./g;
s/\\th/\&\#x2009\;/g;
s/\\equals\\/=/g;
s/\\fr\{4\}\{3\}\{4\}/¾/g;
s/\\fr\{2\}\{1\}\{2\}/½/g;
s/\\fr\{4\}\{1\}\{4\}/¼/g;
s/\\fr\{3\}\{2\}\{3\}/\&\#x2154\;/g;
s/\\fr\{9\}\{1\}\{9\}/<seg type=\"math\">1\/9<\/seg>/g;
s/\\fr\{8\}\{7\}\{8\}/\&\#x215E\;/g;
s/\\plus\\/+/g;
s/\\cent\\/¢/g;
s/\\deg\\? ?/°/g;
s/\\atsign\\/\@/g;
s/\\\"o/ö/g;
s/\\\"y/ÿ/g;
s/\\sh /\//g;
s/\\iumlaut /ï/g;
s/\\lbbar /\&\#x2114\;/g; #tj lb
s/\\`e/è/g;
s/\\A o/ô/g;
s/\\\$/\$/g;
s/---/—/g;
s/--/–/g;
s/\\\"u/ü/g;
s/\\\"e/ë/g;
s/\\v c/\&\#x010D\;/g;
s/(\\lt\\|\\lt )/\&\#x20B6\;/g; # livre tournois
s/\\c c/ç/g;
s/\\\'E/É/g;
s/\\icircumflex /î/g;
s/\\A a/â/g;
s/\\`a/à/g;
s/\\\'a/á/g;
s/\\A u/û/g;
s/\\A e/ê/g;
s/\"a/ä/g;
s/\\sec /\&\#x2033\;/g;
s/\\fn\{e\}/<hi rend=\"superscript\">e<\/hi>/g; # superscript e
s/\\min\\/\&\#x2032\;/g;
s/\\min /\&\#x2032\;/g; # minute used, though should be a primary stress
s/\\two\s+/\&\#x2002\;/g; # used to align numbered paras

# coding
s/\\linebreak/<lb\/>/g;
s/after[\s\n]+1\{\}/\&\#x2007\;/g; # manual coding



# fixes
s/<\/hi>\s+([\.,\;\:\?\!\)])/<\/hi>$1/g;
s/<p>\s+/<p>/g;
s/<lb\/> <\/p>/<\/p>/g;
s/\s+<\/p>/<\/p>/g;
s/\x1a/<\/p><\/note>/g;												# end of file indicator
s/<hi rend=\"italic\">([A-Z])([^<]+)<\/hi>/<title>$1$2<\/title>/g;	# attempt to mark titles, eventually should become wrapped with other text in bibl
s/\\sc\{([A-z]+)\}/<hi rend=\"small-caps\">$1<\/hi>/g;				# a few mistaken small caps codes



		print OUT;
}
