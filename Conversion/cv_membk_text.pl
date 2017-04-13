#!/usr/local/bin/perl5
#This is the Jefferson Memorandum Book Perl script
#Prepared to convert "Script" tag files to TEI P5
#Prepared by Stephen Perkins of Infoset Digital Publishing http://www.infoset.io

use strict;



open (IN, $ARGV[0]);
open (OUT, ">$ARGV[1]");

while (<IN>) {



	#	CHARACTER CONVERSIONS
	 s/\&c\./&amp;c\./g;					# &c.
	 s/\;pl/+/g;							# +
	 s/\;\;pl/+/g;							# +
	 s/\;eq/=/g;							# =
	 s/:t/\&\#x2009\;/g;					# thin space
	 s/:m/\&\#x2003\;/g;					# em space
	 s/:n/\&\#x2002\;/g;					# en space
	 s/\;ts/×/g;							# × times sign
	 s/\;cb/\]/g;							# close square brace
	 s/\;ob/\[/g;							# open square brace
	 s/\;ms/–/g;							# minus sign
	 s/\;cs/\*/g;							# asterisk
	 s/\;sb/•/g;							# bullet
	 s/\;tb/•/g;							# bullet
	 s/\;\;sb/•/g;							# bullet
	 s/\;sh/\//g;							# forward slash
	 s/\;ck/\&\#x2713\;/g;					# check mark
	 s/\;dg/°/g;							# degree sign
	 s/\;bs/\\/g;							# backslash
	 s/\[bu11\]1\[cm2\[cm/½/g;				# 1/2
	 s/\[bu11\]2\[cm3\[cm/\&\#x2153\;/g;	# 1/3
	 s/\[bu11\]2\[cm3\[cm/\&\#x2154\;/g;	# 2/3
	 s/\[bu11\]1\[cm4\[cm/¼/g;				# 1/4
	 s/\[bu11\]3\[cm4\[cm/¾/g;				# 3/4
	 s/\[bu11\]1\[cm8\[cm/\&\#x215B\;/g;	# 1/8
	 s/\[bu11\]3\[cm8\[cm/\&\#x215C\;/g;	# 3/8
	 s/\[bu11\]5\[cm8\[cm/\&\#x215D\;/g;	# 5/8
	 s/\[bu11\]7\[cm8\[cm/\&\#x215E\;/g;	# 7/8
	 s/\[bu11\]1\[cm5\[cm/\&\#x2155\;/g;	# 1/5 
	 s/\[bu11\]2\[cm5\[cm/\&\#x2156\;/g;	# 2/5
	 s/\[bu11\]3\[cm5\[cm/\&\#x2157\;/g;	# 3/5 
	 s/\[bu11\]4\[cm5\[cm/\&\#x2158\;/g;	# 4/5
	 s/\[bu11\]1\[cm6\[cm/\&\#x2159\;/g;	# 1/6 
	 s/\[bu11\]5\[cm6\[cm/\&\#x215A\;/g;	# 5/6
	 # the rest of the fractions mark as segs
	 s/\[bu11\]([\d\.]+)\[cm([\d\.]+)\[cm/<seg type=\"math\">$1\/$2<\/seg>/g;



	 s/\;ca/\&\#x0040\;/g;							# @
	 
	 # mark all these as currency?
	 s/\;bp/£/g;							# pound
	 s/\;mi/\&\#x20B6\;/g;					# livre tournois
	 s/\;ff/\&\#x0192\;/g;					# florin
	 s/\;xx/f/g;							# franc
	 s/\;sh/\//g;							# shilling (uses forward slash)
	 # what does 'lib.' mean? ; this and currency abbreviations like 'fr.' (= franc) also need to be marked

	 # mark these as measures?
	 s/\.\'lbar \./\&\#x2114\;/g;			# barred lb
	 s/\.lbar \./\&\#x2114\;/g;				# barred lb
	 s/\.Cbar \./<g>\&\#xE000\;<\/g>/g;		# barred C (in private range, Monticello Unicode font)
	 s/\.\'Mbar/<g>\&\#xE004\;<\/g>/g;		# barred M (in private range, Monticello Unicode font)
	 s/\.\'Cwt/<g>\&\#xE005\;<\/g>/g;		# TJ Cwt with double line through (in private range, Monticello Unicode font)
	 # use of .'Cequal wt. is inconsistent, sometimes resolving to a barred C with 'wt' following, sometimes to 'Cwt' with no bar
	 # for now resolving as shown here
	 s/\.\'Cequal wt/<g>\&\#xE000\;<\/g>wt/g;		# as barred C+wt
	 s/\.\'Cequal ent/<g>\&\#xE000\;<\/g>ent/g;		# as barred C+ent
	 s/\.\'Cequal /<g>\&\#xE000\;<\/g>ent/g;		# as barred C
	 
	 s/---/\&\#x2014\;/g;					# em dash
	 s/--/\&\#x2013\;/g;					# en dash
	 s/\;pr/\&\#x2032\;/g;					# prime (minute)
	 s/\;dp/\&\#x2033\;/g;					# double prime (second)
	 s/\;db/\&\#x00F7\;/g;					# division sign
	 s/\;aaa/á/g;							# a acute
	 s/\;aae/é/g;							# e acute
	 s/\;aaE/É/g;							# E acute
	 s/\;afa/â/g;							# a circumflex
	 s/\;afe/ê/g;							# e circumflex
	 s/\;afi/î/g;							# i circumflex
	 s/\;afo/ô/g;							# o circumflex
	 s/\;afu/û/g;							# u circumflex
	 s/\;acc/ç/g;							# c cedilla
	 s/\;aga/à/g;							# a grave
	 s/\;agA/À/g;							# A grave
	 s/\;age/è/g;							# e grave
	 s/\;agi/ì/g;							# i grave
	 s/\;agu/ù/g;							# u grave
	 s/\;amu/\&\#x016B\;/g;					# u macron
	 s/\;amo/\&\#x014D\;/g;					# o macron
	 s/\;sd/†/g;							# dagger
	 s/\;dd/‡/g;							# double dagger

	 s/\;gA/\&\#x0391\;/g;					# greek Alpha
	 s/\;gV/\&\#x03A9\;/g;					# greek Omega
	 s/\;tii/\&\#x03B9\;/g;					# iotatonos
	 s/\;tgd/\&\#x03B4\;\&\#x1FBF\;/g;		# greek delta with psili (following)
	 s/\;tge/\&\#x03AD\;/g;					# small greek epsilon with tonos
	 s/\;tja/\&\#x1F00\;/g;					# small greek alpha with psili
	 s/\;tje/\&\#x1F10\;/g;					# small greek epsilon with psili
	 s/\;tji/\&\#x1F30\;/g;					# small greek iota with psili
	 s/\;tjy/\&\#x1F50\;/g;					# small greek upsilon with psili
	 s/\;tla/\&\#x1F04\;/g;					# small greek alpha with tonos and oxia
	 s/\;txa/\&\#x1F04\;/g;					# small greek alpha with perispomeni
	 s/\;txy/\&\#x1FE6\;/g;					# small greek upsilon with perispomeni


	 s/\[fy123,1\]/<hi rend=\"greek\">/g;	# start greek font
	 s/\[fy27,1\]/<\/hi>/g;					# return to standard font (Monticello)
	 s/\.br\;/<lb\/>/g;						# line break


# what the hell is .morspace;?


# OK SECTION


	# note references
	s/\;s(\d)\;s(\d)/<ref type=\"textual-note\" target=\"n$1$2\"\/>/g;
	s/\;s(\d)/<ref type=\"textual-note\" target=\"n$1$2\"\/>/g;

	# year div
	s/\.(lawyear|cashyear|miscyear|MsTJyear|weather)/<\/td><\/tr><\/table>\n<\/div1>\n<div1 type=\"$1\">/g;

	# year head
	s/\.year\;(\[)?(\d{4})(\]?)?(.*?)$/<head>$1$2$3$4<\/head>\n<table>/g;

	# editorial convention: gap
	s/\[\.\&\#x2009\;\.\&\#x2009\;\.\&\#x2009\;\.]/<gap extent=\"long\"\/>/g;
	s/\[\.\&\#x2009\;\.\&\#x2009\;\.]/<gap extent=\"oneortwoword\"\/>/g;
	
	s/\[\&\#x2002\;\]/<gap extent=\"1digit\"\/>/g;
	s/\[\&\#x2002\;\&\#x2002\;\]/<gap extent=\"2digit\"\/>/g;
	s/\[\&\#x2002\;\&\#x2002\;\&\#x2002\;\]/<gap extent=\"3digit\"\/>/g;
	s/\[\&\#x2002\;\&\#x2002\;\&\#x2002\;\&\#x2002\;\]/<gap extent=\"4digit\"\/>/g;
	s/\[\&\#x2002\;\&\#x2002\;\&\#x2002\;\&\#x2002\;\&\#x2002\;\]/<gap extent=\"5digit\"\/>/g;
	s/\[\&\#x2002\;\&\#x2002\;\&\#x2002\;\&\#x2002\;\&\#x2002\;\&\#x2002\;\]/<gap extent=\"6digit\"\/>/g;

	# editorial convention: restore
	s/\.us\;\;oa/<del status=\"retain\">/g;
	s/\.us on \;oa/<del status=\"retain\">/g;
	s/\;ea\@/<\/del>/g;
	s/\;ea \.us off/<\/del>/g;

	# editorial conventions: supplied
	s/\[([^\?\]]+)\]/<supplied>$1<\/supplied>/g;
	s/\[([^\]]+)\?\]/<supplied cert=\"low\">$1\?<\/supplied>/g;

	# now ok to cv angle brackets
	 s/\;oa/\&lt\;/g;	
	 s/\;ea/\&gt\;/g;

	# and should be ok to convert &
	s/ \& / \&amp; /g;

	# formatting notes (PIs for now)
	s/\.cm\'?(.*?)$/<\?format $1\?>/g;

	# tab specs, will be bounded either by ';' (when followed by another command) or a line end
	s/\.tb(( \d+)+)\;/<\?format tabs $1\?>/g;
	s/\.tb(( \d+)+) ?$/<\?format tabs $1\?>/g;
	s/\.pa/<\?format tabs default\?>/g; # TBV

	# package up line length change as a PI for now too
	s/\.ll (\d+)\;?/<\?format line-length $1\?>/g;

	# begin table (1st row). These need to be marked as a row first, then process '}' into columns/cells
	# later we'll put these tables into the column 4 cell (using xsl)
	s/\.\'?bt ?\;?(.*)$/<tr role=\"etbt\"><td>$1<\/td><\/tr>\n/g;
	# begin table row
	s/\.\'?etbt ?\;?(.*)$/<tr role=\"etbt\"><td>$1<\/td><\/tr>\n/g;
	
	s/<tr role=\"etbt\">(.*?)<\/tr>/fixTabs($&)/gse; # put tabs in rows of custom tables


	# end table. .et is always the end of a table and column spec
	s/\.et/<\/td><\/tr><\/table>\n<\?format tabs end-current-spec\?><table>/g; # may need to begin table again, we'll see
	s/\.end\;?/<\/table>\n<table>/g;


# SCRIPT CODES / LAYOUT
	# There are the following macros for entries:
	# .lawyear, .cashyear, .miscyear, .MsTJyear, .weather
					# denotes the type of year division following
	# .year			starts a year of entries
	# .month		starts a month of entries, though does not always contain the month in the text
	# .day			starts a day of entries
	# .sday			an entry on the same day as the preceding .day
	# .xday			an entry on the current day, beginning with an 'X'. See MB I p. 12 for first example.
	# .daylist		a list on the current .day, .sday(?), .xday
	# .xlist		list entry on current day
	# .pp			always indicates text set off from the tabular format, either in left column 1-3 (below) or in a split version of column 4, 
	#				with the text being on the right, aligned vertically with the text to its left, e.g.
	#					test here } .pp text here
	# .sublist		sublist within xlist, sday. Indents 2ems in col 4
	# .subsublist	Appears in 1772, 1785, 1786. Is usu. to have additional indent with a special alignment

	# VISUAL
	#   1       2    3   4
	#  6.25%  6.25% 6.25%
	# Year
	# Month    Day       .day Entry for the day with 
	#                      hanging indent. 
	#          Day   X   .day Entry for the day with an X, always includes date. Has a 
	#                      hanging indent.
	#                    .sday Entry for the same day goes here left align on entry column.....
	#                X   .xday looks like this left aligned on entry column. Never has a date......
	#                X     .daylist indents to align left with hanging indent above, always has X or checkmark
	#                      .xlist indents to align left with hanging indent above. No preceding character
	#                         .sublist indents another em, hang indent
	#                            .subsublist indents another em, hang indent (by default, usu. indicates special alignment)



	# months end/start 
	s/\.month\;([^}]*)}([^}]*)\}([^}]*)\}([^}]*)$/<tr valign=\"top\" role=\"month\"><td width=\"6\.25\%\">$1<\/td><td role=\"day\" width=\"6\.25\%\" align=\"right\"><date>$2<\/date><\/td><td width=\"6\.25\%\">$3<\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$4<\/td><\/tr>\n/g;
	# not all months have three tabs though, might be 0, 1, or 2. Do all permutations here in an order that gets them right
	s/\.month\;([^}]*)}}([^}]*)$/<tr valign=\"top\" role=\"month2\"><td colspan=\"3\" width=\"18\.75\%\">$1<\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;
	s/\.month\;([^}]+)}([^}]+)}}([^}]+)}([^}]+)$/<tr valign=\"top\" role=\"month\"><td width=\"6\.25\%\">$1<\/td><td role=\"day\" width=\"6\.25\%\" align=\"right\"><date>$2<\/date><\/td><td width=\"6\.25\%\"><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$3<\?format tab\?>$4<\/td><\/tr>\n/g;	
	s/\.month\;([^}]*)}X}([^}]*)$/<tr valign=\"top\" role=\"monthX\"><td colspan=\"2\" width=\"12\.5\%\">$1<\/td><td width=\"6\.25\%\"\><hi rend=\"smallcap\">X<\/hi><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;
	s/\.month\;([^}]*)X}([^}]*)$/<tr valign=\"top\" role=\"monthWX\"><td colspan=\"2\" width=\"12\.5\%\">$1<\/td><td width=\"6\.25\%\"\><hi rend=\"smallcap\">X<\/hi><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;
	s/\.month\;([^}]*)}([^}]*)$/<tr valign=\"top\" role=\"month1\"><td colspan=\"3\" width=\"18\.75\%\">$1<\/td><td>$2<\/td><\/tr>\n/g;
	s/\.month\;([^}]*)$/<tr valign=\"top\" role=\"monthQ\"><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$1<\/td><\/tr>\n/g;

	
	# day is row (usually)
	s/\.day\;([^}]*)}X}([^}]*)$/<tr valign=\"top\" role=\"day\"><td width=\"6\.25\%\"\/><td width=\"6\.25\%\" align=\"right\"><date>$1<\/date><\/td><td width=\"6\.25\%\"><hi rend=\"smallcap\">X<\/hi><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;
	s/\.day\;([^}]*)}([^}]*)}([^}]*)$/<tr valign=\"top\" role=\"day\"><td width=\"6\.25\%\"\/><td width=\"6\.25\%\" align=\"right\"><date>$1<\/date><\/td><td width=\"6\.25\%\">$2<\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$3<\/td><\/tr>\n/g;

	s/\.day\;([^}]+)}}([^}]+)}([^}]+)$/<tr valign=\"top\" role=\"day\"><td width=\"6\.25\%\"\/><td width=\"6\.25\%\" align=\"right\"><date>$1<\/date><\/td><td width=\"6\.25\%\"><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\?format tab\?>$3<\/td><\/tr>\n/g;


	# rare cases has just one tab, usu to hand note in column
	s/\.day\;([^}]*)}([^}]*)$/<tr valign=\"top\" role=\"dayQ\"><td\/><td colspan=\"2\" align=\"center\">$1<\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;

	# sday is same day, is row (usually)
	s/\.sday;([^}]*)$/<tr valign=\"top\" role=\"sday\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$1<\/td><\/tr>\n/g;
	# some have one or two tabs, or three usu. for a special alignment (such as a .pp)
	s/\.sday;}+([^}]*)$/<tr valign=\"top\" role=\"sday\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\"><\?format tab\?>$1<\/td><\/tr>\n/g;
	s/\.sday;([^}]*)}+([^}]*)$/<tr valign=\"top\" role=\"sday\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$1<\?format tab\?>$2<\/td><\/tr>\n/g;

	# xday
	s/\.xday\;([^}]*)}([^}]*)$/<tr valign=\"top\" role=\"xday\"><td colspan=\"2\"\ width=\"12\.5\%\"\/><td width=\"6\.25\%\"><hi rend=\"smallcap\">$1<\/hi><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;
	s/\.xday\;([^}]*)}}([^}]*)$/<tr valign=\"top\" role=\"xday\"><td colspan=\"2\" width=\"12\.5\%\"\/><td width=\"6\.25\%\"><hi rend=\"smallcap\">$1<\/hi><\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\"><\?format tab\?>$2<\/td><\/tr>\n/g;
	s/\.xday\&\#x2713\;}([^}]*)$/<tr valign=\"top\" role=\"xday\"><td colspan=\"2\" width=\"12\.5\%\"\/><td width=\"6\.25\%\">\&\#x2713\;<\/td><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$1<\/td><\/tr>\n/g;

	# daylist 
	s/\.daylist\;}X}([^}]*)$/<tr valign=\"top\" role=\"daylist\"><td colspan=\"2\" width=\"12\.5\%\"\/><td width=\"6\.25\%\"><hi rend=\"smallcap\">X<\/hi><\/td><td xhtml:style=\"padding-left:1em\;margin-left:1em\;text-indent:-1em\;\">$1<\/td><\/tr>\n/g;
	s/\.daylist\;}([^}]*)}([^}]*)$/<tr valign=\"top\" role=\"daylist\"><td colspan=\"2\" width=\"12\.5\%\"\/><td width=\"6\.25\%\">$1<\/td><td xhtml:style=\"padding-left:1em\;margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;
	s/\.daylist\;([^}]*)}}([^}]*)$/<tr valign=\"top\" role=\"daylist\"><td width=\"6\.25\%\"\/><td width=\"6\.25\%\" align=\"right\">$1<\/td><td width=\"6\.25\%\"\/><td xhtml:style=\"margin-left:1em\;text-indent:-1em\;\">$2<\/td><\/tr>\n/g;

	# xlist
	s/\.xlist\;([^}]*)$/<tr valign=\"top\" role=\"xlist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:1em\;margin-left:1em\;text-indent:-1em\;\">$1<\/td><\/tr>\n/g;
	# seen in 1771, some xlist can have additional indents. Inserting em spaces for those until checked
	s/\.xlist\;}([^}]*)$/<tr valign=\"top\" role=\"xlist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:1em\;margin-left:1em\;text-indent:-1em\;\"><\?check\?>\&\#x2003\;$1<\/td><\/tr>\n/g;
	s/\.xlist\;}}([^}]*)$/<tr valign=\"top\" role=\"xlist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:1em\;margin-left:1em\;text-indent:-1em\;\"><\?check\?>\&\#x2003\;\&\#x2003\;$1<\/td><\/tr>\n/g;
	s/\.xlist\;}}}([^}]*)$/<tr valign=\"top\" role=\"xlist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:1em\;margin-left:1em\;text-indent:-1em\;\"><\?check\?>\&\#x2003\;\&\#x2003\;\&\#x2003\;$1<\/td><\/tr>\n/g;

	# sublist
	s/\.sublist\;}([^}]*)$/<tr valign=\"top\" role=\"sublist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:2em\;margin-left:1em\;text-indent:-1em\;\;\">$1<\/td><\/tr>\n/g;
	s/\.sublist\;}}([^}]*)$/<tr valign=\"top\" role=\"sublist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:2em\;margin-left:1em\;text-indent:-1em\;\"><\?format tab\?>$1<\/td><\/tr>\n/g;
	# rarely without tab, first seen in 1771
	s/\.sublist\;([^}]*)$/<tr valign=\"top\" role=\"sublist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:2em\;margin-left:1em\;text-indent:-1em\;\"><\?check\?>$1<\/td><\/tr>\n/g;


	# subsublist NEEDS review. Appears in 1772, 1785, 1786. Is usu. to have additional indent with a special alignment
	s/\.subsublist\;}([^}]*)$/<tr valign=\"top\" role=\"subsublist\"><td colspan=\"3\" width=\"18\.75\%\"\/><td xhtml:style=\"padding-left:3em\;margin-left:1em\;text-indent:-1em\;\">$1<\/td><\/tr>\n/g;

	# pp (not programmatically possible to get right)
	s/\.pp\;([^}]*)$/<!-- .pp will need manual intervention --><tr valign=\"top\" role=\"pp\"><td colspan=\"3\" width=\"18\.75\%\"\/><td>$1<\/td><\/tr>\n/g;

	# headings within tables (over column 4)
	s/\.ce\;([^}]*)$/<tr valign=\"top\" role=\"heading\"><td colspan=\"3\" width=\"18\.75\%\"><\/td><td align=\"center\">$1<\/td><\/tr>\n/g;

	# script macros left to write cv for: text, tex, texnew, note, ext, extoff, weather, morspace
		# tex, texnew, note, ext, extoff not found, weather handled in its own div

	# just putting in a PI as .morspace indicates the need for additional vertical space
	s/\.morspace/<\?format add vertical space\?>/g;

	# text
	s/\.text([^}]*)$/<tr valign=\"top\" role=\"text\"><td colspan=\"2\" width=\"12\.5\%\"><\/td><td colspan=\"2\">$1<\/td><\/tr>\n/g;

	# remove file ending character
	s/\x1a//g;

	# lower case <hi rend="small-caps">X</hi>
	s/<hi rend=\"smallcap\">([^<]+)<\/hi>/smallCap($&)/gse;


	# time to make the Greek
	s/<hi rend=\"greek\">([^<]+)<\/hi>/greekMe($&)/gse;

	# cleanups
	s/<td([^>]*)>\s+/<td$1>/g;
	s/\s+<\/td>/<\/td>/g;
	s/<table><\/td><\/tr>/<table>/g;
	s/\?><\/td><\/tr>/\?>/g;
	s/\.\s*<\/table>/\.<\/td><\/tr><\/table>/g;
	s/\.us on\;\&lt\;/<del status=\"retain\">/g;
	s/<td width=\"6\.25\%\">X<\/td>/<td width=\"6\.25\%\"><hi rend=\"smallcap\">x<\/hi><\/td>/g;
	s/\&\&\#x/\&amp\;\&\#x/g;
	s/>\&/>\&amp\;/g;
	s/\&amp\;\#x([A-z\d]{4});/\&\#x$1\;/g;
	s/\/>\s*<\/table>/\/><\/td><\/tr><\/table>/g;
	s/([A-z\d\.])\s*<\/table>/$1<\/td><\/tr><\/table>/g;
	s/\&\#x2003\&/\&\#x2003\;\&/g;
	s/^\.\'cm(.*?)$/<\?format $1\?>/g;
	s/<table>\;<\?format/<table><\?format/g;
	s/<table>\s*<\/table>//g;
	s/<table>\s+<\?format line-length 80\?>\s+<\/table>/<\?format line-length 80\?>/g;
	s/JJL\s*<\/td><\/tr><\/table>/JJL\?>/g;

	print OUT;
}


print OUT "<\/table><\/div1>";

	sub fixTabs {
		my $cells = shift;
		$cells =~ s/\}/<\/td><td>/g;
		return $cells;
	}

	sub smallCap {
		my $letters = shift;
		$letters =~ tr/A-Z/a-z/;
		return $letters;
	}
	
	sub greekMe {
		my $letters = shift;
		$letters =~ s/<hi rend=\"greek\"/<HI REND=\"GREEK\"/g;	# so markup is unaffected
		$letters =~ s/<\/hi>/<\/HI>/g;
		$letters =~ s/m/\&\#x00B5\;/g;	# mu
		$letters =~ s/t/\&\#x03C4\;/g;	# tau
		$letters =~ s/n/\&\#x03BD\;/g;	# nu
		$letters =~ s/r/\&\#x03C1\;/g;	# rho
		$letters =~ s/o/\&\#x03BF\;/g;	# omicron
		$letters =~ s/p/\&\#x03C0\;/g;	# pi
		$letters =~ s/s/\&\#x03C3\;/g;	# sigma
		$letters =~ s/i/\&\#x03B9\;/g;	# iota
		$letters =~ s/a/\&\#x03B1\;/g;	# alpha
		$letters =~ s/k/\&\#x03F0\;/g;	# script kappa
		$letters =~ s/l/\&\#x03BB\;/g;	# lambda
		$letters =~ s/y/\&\#x03C5\;/g;	# upsilon
		$letters =~ s/d/\&\#x03B4\;/g;	# delta
		$letters =~ s/w/\&\#x03C2\;/g;	# final sigma
		$letters =~ s/e/\&\#x03AD\;/g;	# epsilon with tonos (confirmed)
		# x is last!
		$letters =~ s/\#x/\#X/g;								# so existing entities aren't affected
		$letters =~ s/x/\&\#x03C7\;/g;	# chi
		$letters =~ s/\#X/\#x/g;								# and return to the way we found it....
		$letters =~ s/<HI REND=\"GREEK\"/<hi rend=\"greek\" xml:lang=\"grc\"/g; # and mark language code while we're here (ancient greek? greek = el)
		$letters =~ s/<\/HI>/<\/hi>/g;
		return $letters;
	}