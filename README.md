# Karyotyping
Karyotyping of aneuploid and polyploid plants from low coverage whole-genome resequencing
# Dependencies
1. BWA, https://bio-bwa.sourceforge.net/
2. Samtools, https://github.com/samtools/samtools
3. Control-FREEC, http://boevalab.inf.ethz.ch/FREEC/index.html
4. GATK, https://software.broadinstitute.org/gatk/
5. R (tested with 3.6.3 and 4.2.2) and Perl (tested with 5.32.1) are also required.
# Citation
Cao Y, Zhao K, Xu J, et al. Genome balance and dosage effect drive allopolyploid formation in Brassica[J]. PNAS, 2023, 120(14): e2217672120.
# Programs
Chromosome copy number analysis

After the sample was resequenced (no more than 1x depth), the fastq file was analyzed by BWA and SAMtools software to obtain the bam file, and the bam file was analyzed by Control-FREEC to obtain the copy number variation (CNV) file, such as test_data_QIS4_8_1X.txt. Karyotypes were then inferred from CNV visualizations by Control-FREEC_visualization.R.

Hybrid genome structure analysis

In addition to chromosome copy numbers, the genotypes of hybrid offspring can be inferred. This process requires at least three samples (5-10x depth), including both parents and one offspring. As described above, after obtaining bam files for all samples, a vcf file containing variation information for all samples is obtained using the gatk standard process. According to the vcf file, selecting the homozygous and differential genotype positions of parents by select_homozygous_differential_position.pl to obtain the filtered vcf file, and then the “index” of offsprings are calculated based on the filtered vcf file by calculate_index.pl (enter "perl calculate_index.pl" for usage).
