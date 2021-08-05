my $file = $ARGV[0];
open(IN,$file);

my $out = $ARGV[1];
open(OUT,">$out");

while(<IN>){
	
	$_=~s/[\n\r]//g;
	$_=~s/chr0//g;
	$_=~s/chr1/1/g;
	my @arr = split(/\s+/,$_);
	
	if($arr[0] =~ /CHROM/)
	{
	    print OUT "Name\tChromosome\tPosition\tAC142_EA49\tETB_EA49\n";
	}
	
	if($arr[5] < 7 || $arr[8] < 21)
	{
		next;
	}
	
	if($arr[0] =~ /\d/)
	{
		$Ref = 1-$arr[9];
	
		print OUT "$arr[1]\t$arr[0]\t$arr[1]\t$arr[9]\t$Ref\n";
	}
}
	
close IN;
close OUT;