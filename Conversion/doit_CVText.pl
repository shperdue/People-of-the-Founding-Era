#! perl -w
use strict;

system("time /t"); # time begin

my $inputdir = "in";
my $outputdir = "out";

my @files = glob("$inputdir/*.SCT");


foreach my $infile (@files)
{
    my $outfile = $infile;
    $outfile =~ s/^$inputdir/$outputdir/o;
	$outfile =~ s/SCT/xml/;
	
	system("perl cv_membk_text_pre.pl $infile _tmp.1");
	system("perl cv_membk_text_pre2.pl _tmp.1 _tmp.2");
	system("perl cv_membk_text.pl _tmp.2 _tmp.3");
	system("perl cv_membk_text2.pl _tmp.3 $outfile");

}

# unlink(_tmp.*);

system("time /t"); # time end


