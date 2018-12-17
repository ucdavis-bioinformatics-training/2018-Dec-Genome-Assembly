Assembly With PacBio Data
==========================


# Joe - after Sequel data, what are scraps, etc., after assembly (QA, assembly, polishing, assessment), integration of two technologies? Run nanopore and pacbio together (CANU, miniasm,) and more than one technology, PB scaffolds plus ONT reads, and vice versa




Raw Data
--------------------------------

To start out, we'll make a directory for this part of the workshop:

    cd /share/biocore/workshop/{your username}/
    mkdir PB
    cd PB/
    mkdir 00-RawData
    cd 00-RawData/

Then, so we don't have multiple copies of the raw data sitting around, make symbolic links:

    ln -s /share/biocore/jfass/....................... sequel.fq.gz
    ln -s /share/biocore/jfass/....................... minion.fq.gz
    ln -s /share/biocore/jfass/....................... miseq_R1.fq.gz
    ln -s /share/biocore/jfass/....................... miseq_R2.fq.gz

This is a Sequel dataset, a MinION dataset, and an Illumina dataset from *Michael, et al. 2018 Nature Communications*, all from *Arabidopsis thaliana* KBS-Mac-74. We're going to look at MinION later with Jessie. Right now we've got the filtered subread data from a Sequel run. But let's actually look at an example of a Sequel dataset linked from PacBio's DevNet wiki [https://github.com/PacificBiosciences/DevNet/wiki/Datasets](https://github.com/PacificBiosciences/DevNet/wiki/Datasets). I've downloaded two SMRT-Cells of *Arabidopsis* data. Let's take a look at the sequence data (stored in BAM files) and relate it to the sequencing process.

    module load samtools/1.9
    samtools view m54113_160913_184949.subreads.bam | cut -f1-9 | head

Notice the ZMW that has two subreads? For every subread ID, the first "/"-separated field is the SMRT-Cell ID (90% sure of that), the second field is the ZMW number, and the third field is the range of nucleotides from the full read that are shown in that subread. So:

    m54113_160913_184949/4326262/2021_5141  4       *       0       255     *       *       0       0
    m54113_160913_184949/4326262/5185_16357 4       *       0       255     *       *       0       0


... are two subreads from the same ZMW, the first from pulse 2,021 to 5,141, and the second from pulse 5,185 to 16,357. What's in between the two, and what happened to the first ~2,000 nucleotides? Let's look at that ZMW in the "scraps" file.

    samtools view m54113_160913_184949.scraps.bam | cut -f1-9 | grep "/4326262/"
    # m54113_160913_184949/4326262/0_2021     4       *       0       255     *       *       0       0
    # m54113_160913_184949/4326262/5141_5185  4       *       0       255     *       *       0       0

So, for some reason the first 2,022 nucleotides (assuming 0 is the first one) didn't become a subread. The next segment (2021-5141) became the first subread. Following that (5141-5185) should be one SMRT-bell adapter. And the last segment (5185-16357) became the next subread. So the first ~2000 nucleotides of the longer, second subread should be the reverse complement of the first subread. (Discuss qualities, why no first subread?)

Dumping all subreads can be done by grabbing the correct columns:

    samtools view m54113_160913_184949.subreads.bam \
      | head -n 400 \
      | cut -f1,10,11 \
      | while read line; do
          id=`echo $line | cut -f1 -d\ `
          seq=`echo $line | cut -f2 -d\ `
          qual=`echo $line | cut -f3 -d\ `
          echo -e ">$id"
          echo "$seq"
          echo "+"
          echo "$qual"
        done > test.fq




Some Basic Stats
-------------------

Let's make some Cumulative Length Plots (see Fig10-11, Assemblathon 2 [paper](https://academic.oup.com/gigascience/article/2/1/2047-217X-2-10/2656129#120193432)) of the raw read data. First, list lengths of reads longest to shortest. Then add a cumulative length column next to the length column. In the following code block, the first Perl chunk reads four lines at a time, then prints out only the length of the second line (the sequence line in FASTQ format). The second Perl chunk updates a cumulative length ($c) and print out the two columns (length and cumulative length) one row at a time.

    # generate cumulative length data for the PacBio data (2-3 minutes run time):
    zcat ../00-RawData/sequel.fq.gz \
    | perl -ne '$h=$_; $s=<>; $h2=<>; $q=<>; chomp $s; print length($s)."\n"' \
    | sort -rn \
    | perl -ne '$l=$_; chomp $l; $c+=$l; print "$l\t$c\n"' \
    > sequel.cl
    # ... and for the Nanopore data (2-3 minutes):
    zcat ../00-RawData/minion.fq.gz \
    | perl -ne '$h=$_; $s=<>; $h2=<>; $q=<>; chomp $s; print length($s)."\n"' \
    | sort -rn \
    | perl -ne '$l=$_; chomp $l; $c+=$l; print "$l\t$c\n"' \
    > minion.cl

Take a look at the output files. Now, without leaving the terminal (important, for those of us with gui-phobia) we can get a preliminary picture of the distributions of read lengths, using gnuplot.

    gnuplot -e 'set term dumb;
    set logscale xy;
    set key bottom left;
    plot "minion.cl" pt ".","sequel.cl" pt "*"'

Generate a prettier graph by substituting in "set term png;" instead of the "dumb" terminal command, as well as adding 'set output "plot.png";' to write to file plot.png. To read the Cumulative Length Plots, remember that we're plotting the longest sequences first. So the first point is at the lower right, an an X-value equal to the length of the sequence, and a Y-value equal to the sum of the first (1) sequence(s). The second longest point is plotted next, usually above and to the left of the first point, at an X-value of its length, and a Y-value of the sum of the lengths of the 1st 2 sequences. Etc.

Another metric could be the base quality distributions across reads:

    # stick to the 1st 1000 reads and it'll only take half a minute ...
    # PacBio data:
    zcat ../00-RawData/sequel.fq.gz \
    | perl -ne '$h=$_; $s=<>; $h2=<>; $q=<>; print $q' \
    | head -n 1000 \
    | grep -o . \
    | sort \
    | uniq -c \
    | sort -k2,2
    # Nanopore data:
    zcat ../00-RawData/minion.fq.gz \
    | perl -ne '$h=$_; $s=<>; $h2=<>; $q=<>; print $q' \
    | head -n 1000 \
    | grep -o . \
    | sort \
    | uniq -c \
    | sort -k2,2

This gives you the frequencies of base quality characters. Consulting Wikipedia's excellent [FASTQ format](https://en.wikipedia.org/wiki/FASTQ_format) page tells you that looking up the decimal value of each character in the ASCII table (try 'man ascii'), then subtracting 33, gives you the "phred-scaled Q-value" quality (Q). The probability that a base is incorrect is 10^(-Q/10). These error estimates are some amalgamation of base substitution errors, between-base insertions, and base deletions.

How about a feel for -per-read average base Q-values?

    zcat ../00-RawData/minion.fq.gz \
    | perl -ne '$h=$_; $s=<>; $h2=<>; $q=<>; print $q' \
    | head -1000 \
    | perl -ne '$q=$_; chomp $q; @Q=split(//,$q); while (@Q) {$q=pop(@Q); $cnt++; $tot+=(ord($q)-33)} $avg=sprintf("%.1f",($tot/$cnt)); print "$avg\n"' \
    | sort \
    | uniq -c \
    | sort -n -k2,2

Given what we saw above, this wouldn't be useful for the PacBio Sequel data.

Running the Assemblers
--------------------------

CANU runs all steps in one command ... see the SLURM scripts that you can copy from my example directory.

    cd /share/biocore/{your username}/PB/
    cp /share/biocore/jfass/2018-December-Genome-Assembly-Workshop/02-Assemblies/canu*slurm .

For miniasm, one needs to align the reads all-versus-all, so there are separate minimap and miniasm SLURM scripts.

    cp /share/biocore/jfass/2018-December-Genome-Assembly-Workshop/02-Assemblies/mini*slurm .

Submit the CANU scripts, then the minimap scripts. Then you can schedule each miniasm script to run depending on each one's minimap script running successfully. First use 'squeue' to find the JOBID of the appropriate minimap job (let's say it's 42 for this example, for the sequel data). Then submit the dependent job like this:

    sbatch -d afterok:42 miniasm.sequel.slurm

Please make sure to change the notification email in each SLURM script to YOUR OWN EMAIL! Otherwise you'll drown my inbox, unless I have enough forethought to change the email in my scripts to ... Matt's.

Output
-------------

For the miniasm assmeblies (in GFA format) we just need to grab the "S" lines:

    cat sequel.gfa | grep ^S | perl -ane 'print ">$F[1]\n$F[2]\n"' > sequel.miniasm.fa
    cat minion.gfa | grep ^S | perl -ane 'print ">$F[1]\n$F[2]\n"' > minion.miniasm.fa

For the CANU assemblies, 

    cat CANU-sequel/CANU-sequel.unitigs.fasta \
      | cut -f1 -d\  \
      | perl -pe 'chomp if !(m/^>/)' \
      | perl -pe 's/>/\n>/g' \
      | grep -v ^$ \
      > sequel.canu.fa
    cat CANU-minion/CANU-minion.unitigs.fasta \
      | cut -f1 -d\  \
      | perl -pe 'chomp if !(m/^>/)' \
      | perl -pe 's/>/\n>/g' \
      | grep -v ^$ \
      > minion.canu.fa


Assembly Stats
---------------

Use the same commands as for the read stats, but we'll need to modify slightly to accommodate fasta, as opposed to fastq.

    cd /share/biocore/{your username}/PB/
    mkdir 03-AssemblyStats
    cd 03-AssemblyStats/
    zcat ../02-Assemblies/sequel.miniasm.fa \
    | perl -ne '$h=$_; $s=<>; chomp $s; print length($s)."\n"' \
    | sort -rn \
    | perl -ne '$l=$_; chomp $l; $c+=$l; print "$l\t$c\n"' \
    > sequel.miniasm.cl
    # ... adapt for the others as well ...
    gnuplot -e 'set term dumb;
    set logscale xy;
    set key bottom left;
    plot "sequel.miniasm.cl" pt ".","sequel.canu.cl" pt "*"'
    # ... etc. ...


Polishing
------------

Using RACON to polish. 

    

Integration
------------

Installation of QuickMerge (oy). 



Reference Comparison
---------------------

Align each using Contig Reorder tool. Then align all at once. All wrt At (Col?).





