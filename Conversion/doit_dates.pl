#! perl -w
use strict;

system("time /t"); # time begin

my $inputdir = "in";
my $outputdir = "out";

my @files = glob("$inputdir/*.xml");


foreach my $infile (@files)
{
    my $outfile = $infile;
    $outfile =~ s/^$inputdir/$outputdir/o;

	system("java -Xmx1500M -Xms1500M -cp c:\\saxonica\\saxon9.jar net.sf.saxon.Transform -t -signorable -o _tmp.1 $infile dates.xsl");
	system("java -Xmx1500M -Xms1500M -cp c:\\saxonica\\saxon9.jar net.sf.saxon.Transform -t -signorable -o $outfile _tmp.1 dates2.xsl");


}

# unlink(_tmp.*);

system("time /t"); # time end


