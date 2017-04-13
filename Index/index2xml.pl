#!/usr/local/bin/perl5
#Perl script to convert OCR exported from PDF into XML
#Prepared by Stephen Perkins of Infoset Digital Publishing http://www.infoset.io

use UTF8;
use strict;
my $RS = undef;

while (<>) {

	my $text = $_;

	# undo newline for now
	$_ =~ s/\n/<lb>/g;

	# fix versus error in ocr
	$_ =~ s/ v \./ v\./g;

	# fix ampersands
	$_ =~ s/\s\&\s/ \&amp\; /g;

	# mark headings
	$_ =~ s/^<em>([\w\s]+)<\/em>\s*<lb>/<head>$1<\/head>\n/g;

	# remove running heads and continued lines
	$_ =~ s/^.*?I\x20?N\x20?D\x20?E\x20?X.*?<lb>//g;
	$_ =~ s/^.*?cont\..*?<lb>//g;

	# start running in things that need running in....
	$_ =~ s/([\d\)\w]+)(,|\;)\x20*<lb>/$1$2 /g;
	$_ =~ s/<em>(See|see)\x20*<\/em>\x20*<lb>/<em>$1<\/em> /g;
	$_ =~ s/\.<lb>/\. /g;
	$_ =~ s/(\d)(-|­)\x20*<lb>/$1$2/g;
	$_ =~ s/<lb>\s*\x3e/ \(/g;

	# break lines that ended up run in
	$_ =~ s/(\d+)\x20+(\p{Lu})/$1<lb>$2/g;

	# fix line end hyphens
	$_ =~ s/([a-z])­\x20+([a-z])/$1$2/g;
	$_ =~ s/([a-z])(-|­)<lb>/$1/g;
	$_ =~ s/<lb><\/em>\x20*<lb><em>//g;

	# fix space around em element
	$_ =~ s/\s+<\/em>/<\/em> /g;
	$_ =~ s/<lb><\/em>/<\/em><lb>/g;

	# collapse space
	$_ =~ s/\x20{2,}/ /g;

	# fix space before comma, semicolon
	$_ =~ s/\x20+\;/\;/g;
	$_ =~ s/\x20+,/,/g;

	# remove redundant start/end tags
	$_ =~ s/<\/em>\x20+<em>/ /g;

	# run in
	$_ =~ s/also<\/em>\x20*<lb>/also<\/em> /g;
	$_ =~ s/\;<\/em>\x20*<lb>/<\/em> /g;

	$_ =~ s/<lb>/<lb>\n/g;
	
	print;
}