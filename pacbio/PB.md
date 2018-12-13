Assembly With PacBio Data
==========================

Raw Data
--------------------------------

To start out, we'll make a directory for this part of the workshop:

    cd /share/biocore/workshop/{your username}/
    mkdir PB
    cd PB/




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

Without leaving the terminal (important, for those of us with gui-phobia) we can get a preliminary picture of the distributions of read lengths, using gnuplot.

    gnuplot -e 'set term dumb;
    set logscale xy;
    set key bottom left;
    plot "minion.cl" pt ".","sequel.cl" pt "*"'

Generate a prettier graph by substituting in "set term png;" instead of the "dumb" terminal command, as well as adding 'set output "plot.png";' to write to file plot.png.

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

Output
-------------

Polishing
------------





