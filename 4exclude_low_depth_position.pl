my $file = $ARGV[0];
open(IN,$file);

my $out = $ARGV[1];
open(OUT,">$out");

while(<IN>){
	
	$_=~s/[\n\r]//g;
	$_=~s/scaffoldA0/A/g;
	$_=~s/scaffoldA1/A1/g;
	my @arr = split(/\s+/,$_);
	
	if($arr[0] =~ /CHROM/)
	{
	    print OUT "Name\tChromosome\tPosition\tIMB_QIS4_8\tQuinta_QIS4_8\n";
	}
	
	if($arr[5] < 7 || $arr[8] < 7)
	{
		next;
	}
	
	if($arr[0] =~ /^A/)
	{
		$Ref = 1-$arr[9];
	
		print OUT "$arr[1]\t$arr[0]\t$arr[1]\t$arr[9]\t$Ref\n";
	}
}
	
close IN;
close OUT;