#!/usr/local/bin/perl5
#Perl script to convert OCR exported from PDF into XML
#Prepared by Stephen Perkins of Infoset Digital Publishing http://www.infoset.io

use UTF8;
use strict;

while (<>) {

	my $text = $_;

	$_ =~ s/<\/em> <em>/ /g;

	$_ =~ s/<IndexEntry>/<Object entry="0" url="0" sortkey="" title="unknown" link-target-type="index" status="Active"><IndexEntry>/g;
	$_ =~ s/<MainEntryGrp>/<MainEntryGrp><Entry><Body>/g;
	$_ =~ s/\x20*<\/MainEntryGrp><\/IndexEntry>/<\/Entry><\/MainEntryGrp><\/IndexEntry><\/Object>/g;
	$_ =~ s/\?><\/MainEntryGrp><\/IndexEntry>/\?>/g;
	$_ =~ s/<ObjectCollection><\/Entry><\/MainEntryGrp><\/IndexEntry><\/Object>/<!DOCTYPE ObjectCollection SYSTEM \"ObjectCollection\.dtd\">\n<ObjectCollection>/g;

	$_ =~ s/, (([\d-]+,?\x20*)+)/<\/Body><VolumeInfo>$1<\/VolumeInfo>/g;
	$_ =~ s/, <em>(\d+)<\/em></<\/Body><VolumeInfo><em>$1<\/em><\/VolumeInfo></g;

	# mark refs
	$_ =~ s/\.\x20+<em>See(.*?)<\/Entry>/<ref><em>See$1<\/ref><\/Entry>/g;
	$_ =~ s/([^>])<ref>/$1<\/Body><ref>/g;

	# mark up sub entries
	$_ =~ s/\:(.*?)<\/Body>/<\/Body><SubEntryGrp><SubEntry>$1/g;
	$_ =~ s/>\;/><\/SubEntry><SubEntry>/g;
	$_ =~ s/<SubEntry>(.*?)<\/Entry>/<SubEntry>$1<\/SubEntry><\/SubEntryGrp><\/Entry>/g;
	$_ =~ s/<SubEntry>(.*?)<VolumeInfo>/<SubEntry><Body>$1<\/Body><VolumeInfo>/g;
	$_ =~ s/<\/Body><\/Body>/<\/Body>/g;

	# mark up folios
	$_ =~ s/<VolumeInfo>(.*?)<\/VolumeInfo>/markFolios($&)/gse;

	$_ =~ s/<em>/<render as=\"italic\">/g;
	$_ =~ s/<\/em>/<\/render>/g;

	# cleanup stuff
	$_ =~ s/<Body>\x20+/<Body>/g;
	$_ =~ s/<\/Body><SubEntryGrp><SubEntry><Body><\/render>/<\/render><\/Body><SubEntryGrp><SubEntry><Body>/g;
	$_ =~ s/<pn><\/pn><\/VolumeInfo><render as=\"italic\">([\d-]+)<\/render><\/Body><VolumeInfo><pn>/<pn><render as=\"italic\">$1<\/render><\/pn><pn>/g;

	# line ends so we can read
	$_ =~ s/<\/(SubEntry|Entry)>/$&\n/g;

	print $_;
}

sub markFolios {
	my $folios = shift;
	$folios =~ s/<VolumeInfo>/<VolumeInfo><pn>/g;
	$folios =~ s/<\/VolumeInfo>/<\/pn><\/VolumeInfo>/g;
	$folios =~ s/,\x20*/<\/pn><pn>/g;
	return $folios;
}