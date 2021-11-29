#!/usr/bin/perl -w
use strict;
use Getopt::Long;

sub usage
{
        print STDERR <<USAGE;
==============================================================================
Description	Calculate index from homozygous vcf file
				
	This script calculates index of two offspring samples at the same time. 
	In case of a single sample, -s2 can enter the name of another parent (non-reference parent) 
	to complete the parameter.
	The index in the output file is the ratio consistent with the non-reference parent, 
	so the reference parent is "1.00 - index".

perl $0 -i <hom vcf filename> -p1 <ref parent name> -s1 <sample1 name> -s2 <sample2 name> -out <index filename>

Options
	-i	input hom vcf file
	-p1	ref parent name should be consistent with vcf file
	-s1	sample1 name should be consistent with vcf file
	-s2	sample2 name should be consistent with vcf file
	-out	output index file
==============================================================================
USAGE
}

my ($in,$p1,$s1,$s2,$out,$help);

GetOptions(
        "h|?|help"=>\$help,
        "i=s"=>\$in,
	"p1=s"=>\$p1,
	"s1=s"=>\$s1,
	"s2=s"=>\$s2,
	"out=s"=>\$out,
);

if(!defined($in) || !defined($p1) || !defined($s1) || !defined($s2) || !defined($out) || defined($help)){
	&usage;
	exit 0;
}

if($in =~ /gz$/){
	open IN,"<:gzip",$in || die $!;
}else{
	open IN,"$in" || die $!;
}

open OUT,">$out";
my @line;
while (<IN>){
	chomp;
	next if(/^##/);
	@line=split /\t/,$_;
	last if(/^#CHROM/);
}
my $col_p1=0;
my $col1=0;
my $col2=0;
my $format_col=8;
for(my $i=1;$i<@line;$i++){
	if($p1 eq $line[$i]){
		$col_p1=$i;
	}elsif($s1 eq $line[$i]){
		$col1=$i;
	}elsif($s2 eq $line[$i]){
		$col2=$i;
	}elsif($line[$i] eq "FORMAT"){
		$format_col=$i;
	}
}

if($col1==0 || $col2==0 || $col_p1==0 || $col1==3 || $col2==3){
	print "Error input -p1 or -s1 or -s2!\n";
	exit 0;
}
my $col;
if($col_p1==3){
	print OUT "CHROM\tPOS\tREF\tALT\tRef_depth_$s1\tAlt_depth_$s1\tDepth_$s1\tindex_$s1\tRef_depth_$s2\tAlt_depth_$s2\tDepth_$s2\tindex_$s2\n";
	while(my $line=<IN>){
		chomp($line);
		my @line=split /\t/,$line;
		next if($line[4]=~/,/);
		my @format=split /:/,$line[$format_col];
		my ($ad_col,$dp_col);
		for(my $j=0;$j<@format;$j++){
			if($format[$j] eq "AD"){
				$ad_col=$j;
			}elsif($format[$j] eq "DP"){
				$dp_col=$j;
			}
		}
		next if($line[$col1]=~/^\.(\/||\|)\./ || $line[$col2]=~/^\.(\/||\|)\./ );
		my @f1=split /:/,$line[$col1];
		my @f2=split /:/,$line[$col2];
		my @ad1=split /,/,$f1[$ad_col];
		my @ad2=split /,/,$f2[$ad_col];
		my $total1=$ad1[0]+$ad1[1];
		my $total2=$ad2[0]+$ad2[1];
		next if ($total1==0);
		next if ($total2==0);
		my $snpindex1=sprintf "%.2f",$ad1[1]/$total1;
		my $snpindex2=sprintf "%.2f",$ad2[1]/$total2;
		print OUT "$line[0]\t$line[1]\t$line[3]\t$line[4]\t$ad1[0]\t$ad1[1]\t$total1\t$snpindex1\t$ad2[0]\t$ad2[1]\t$total2\t$snpindex2\n";
	}
}else{
	print OUT "CHROM\tPOS\tREF\tALT\tGenotype_$p1\tDepth_$p1\tRef_depth_$s1\tAlt_depth_$s1\tDepth_$s1\tindex_$s1\tRef_depth_$s2\tAlt_depth_$s2\tDepth_$s2\tindex_$s2\n";
	while(my $line=<IN>){
		chomp($line);
		my @line=split /\t/,$line;
		next if($line[4]=~/,/);
		my @format=split /:/,$line[$format_col];
		my ($ad_col,$dp_col);
		for(my $j=0;$j<@format;$j++){
			if($format[$j] eq "AD"){
				$ad_col=$j;
			}elsif($format[$j] eq "DP"){
				$dp_col=$j;
			}
		}
		next if($line[$col1]=~/^\.(\/||\|)\./ || $line[$col2]=~/^\.(\/||\|)\./ );
		my @f1=split /:/,$line[$col1];
		my @f2=split /:/,$line[$col2];
		my @fp1=split /:/,$line[$col_p1];
		my @ad1=split /,/,$f1[$ad_col];
		my @ad2=split /,/,$f2[$ad_col];
		my @adp1=split /,/,$fp1[$ad_col];
		my $total1=$ad1[0]+$ad1[1];
		my $total2=$ad2[0]+$ad2[1];
		next if ($total1==0);
		next if ($total2==0);
		my $totalp1=$adp1[0]+$adp1[1];
		my ($snpindex1,$snpindex2,$p1_geno);
		if($line[$col_p1]=~/^0(\/||\|)0/){
			$snpindex1=sprintf "%.2f",$ad1[1]/$total1;
			$snpindex2=sprintf "%.2f",$ad2[1]/$total2;
			$p1_geno=$line[3];
		}elsif($line[$col_p1]=~/^1(\/||\|)1/){
			
			$snpindex1=sprintf "%.2f",$ad1[0]/$total1;
			$snpindex2=sprintf "%.2f",$ad2[0]/$total2;
			$p1_geno=$line[4];
		}else{
			print "Error: parent1 is not hom!\n";
		}
		print OUT "$line[0]\t$line[1]\t$line[3]\t$line[4]\t$p1_geno\t$totalp1\t$ad1[0]\t$ad1[1]\t$total1\t$snpindex1\t$ad2[0]\t$ad2[1]\t$total2\t$snpindex2\n";
	}
}	
close IN;
close OUT;