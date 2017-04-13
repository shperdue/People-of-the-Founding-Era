#!/usr/local/bin/perl5
# 2014-09-19
# script to mark references to letters to and from TJ in the Memorandum Book textual notes

# also mark internal refs to MB, e.g. "MB 29 Apr. 1779;"
# links not always in parens, see d1e1901a1048964

use strict;

open (IN, $ARGV[0]);
open (OUT, ">$ARGV[1]");


undef $/;
$/ = "<\/p>";

while (<IN>) {


	# work only between parens?
	s/\(([^\)]+)\)/markRefs($&)/gse;


	# cleanup
	s/<ref pm:link-pointer-type=\"relatedDocument\"> / <ref pm:link-pointer-type=\"relatedDocument\">/g;


	
	print OUT;
}

sub markRefs {
	my $text = shift;
	# comment out entities
	$text =~ s/\&([\#x0-9A-z]+)\;/<\?entity $1\?>/g;
	# case one: entire parens is reference. no semicolon
	$text =~ s/\((see[\s\n\t]+)?([^\;\)]*)(TJ[\s\n\t]+to|to[\s\n\t]+TJ)([^\;\)]*)\)/\($1<ref pm:link-pointer-type=\"relatedDocument\">$2$3$4<\/ref>\)/g;
	# case two: multiple entries
	$text =~ s/\(([^\;\)]*)(TJ[\s\n\t]+to|to[\s\n\t]+TJ)([^\;\)]*)\;([^\)]*)\)/\(<ref pm:link-pointer-type=\"relatedDocument\">$1$2$3<\/ref>;$4\)/g;
	# next line runs twice, assuming max refs in parens is 4
	$text =~ s/<\/ref>\;([^\;\)]*)(TJ[\s\n\t]+to|to[\s\n\t]+TJ)([^\;\)]*)\;/<\/ref>\;<ref pm:link-pointer-type=\"relatedDocument\">$1$2$3<\/ref>;/g;
	#$text =~ s/<\/ref>\;([^\;\)]*)(TJ\s+to|to\s+TJ)([^\;\)]*)\;/<\/ref>\;<ref pm:link-pointer-type=\"relatedDocument\">$1$2$3<\/ref>;/g;
	# then we look for 2
	$text =~ s/<\/ref>\;([^\;\)]*)(TJ[\s\n\t]+to|to[\s\n\t]+TJ)([^\;\)]*)\)/<\/ref>\;<ref pm:link-pointer-type=\"relatedDocument\">$1$2$3<\/ref>\)/g;
	
	# try and mark bibls that we can
	$text =~ s/<\/ref>\; (?!<ref)([^\)]+)\)/<\/ref>\; <bibl>$1<\/bibl>\)/g;

	# turn the entities back
	$text =~ s/<\?entity ([\#x0-9A-z]+)\?>/\&$1\;/g;

	return $text;
}

