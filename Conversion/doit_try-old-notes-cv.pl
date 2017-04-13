#! perl -w
use strict;

system("time /t"); # time begin

my $inputdir = "in";
my $outputdir = "out";

my @files = glob("$inputdir/*.tex");


foreach my $infile (@files)
{
    my $outfile = $infile;
    $outfile =~ s/^$inputdir/$outputdir/o;
	$outfile =~ s/TEX/xml/;
	
	system("perl cv_membk_notes.pl $infile $outfile");

}

# unlink("_tmp.*");

system("time /t"); # time end
