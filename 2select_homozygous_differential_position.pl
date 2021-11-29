my $file = $ARGV[0];
open(IN,$file);

my $out = $ARGV[1];
open(OUT,">$out");

while(<IN>){
	
	$_=~s/[\n\r]//g;
	my @arr = split(/\s+/,$_);
	
	if($arr[0] =~ /#CHROM/)
	{
	    print OUT $_."\n";
	}
	
	if(($arr[9] =~ /^0(\/||\|)0/ && $arr[11] =~ /^1(\/||\|)1/) || ($arr[9] =~ /^1(\/||\|)1/ && $arr[11] =~ /^0(\/||\|)0/))
	{
	    print OUT $_."\n";
	}
	
}
close IN;
close OUT;