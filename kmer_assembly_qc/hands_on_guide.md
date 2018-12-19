# Hands on guide

### phiX kmer histogram

Calculate the kmer spectra for the phiX genome. Before launching the command think for a moment in the result:  

- how many Khmers do you expect to get? 
- what is the main frequency that you expect to get?
- Do you count canonical kmers or non canonical kmers? does it make a difference in the kmer spectra?

```bash
$ kat hist -o phiX.hist phiX.fasta
$ head -n 20 phiX.hist
```

```
# Title:27-mer spectra for: phiX.fasta
# XLabel:27-mer frequency
# YLabel:# distinct 27-mers
# Kmer value:27
# Input 1: phiX.fasta
###
1 5360
2 0
3 0
4 0
...
```

![image-20181210143549848](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181210143549848.png)

Now artificially double the genome:

- what changes do you expect to find in the kmer spectra? Why?

```bash
$ cat phiX.fasta phiX.fasta > phiX_twice.fasta
$ kat hist -o phiX_twice.hist phiX_twice.fasta
```

```
# Title:27-mer spectra for: phiX_twice.fasta
# XLabel:27-mer frequency
# YLabel:# distinct 27-mers
# Kmer value:27
# Input 1:phiX_twice.fasta
###
1 0
2 5360
3 0
4 0
...
```

![image-20181210143521903](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181210143521903.png)

### ecoli Kmer spectra and spectra-cn

- How many distributions can you see in the spectra?
- Is there a correspondence between the distribution and the content?

```bash
$ kat hist -H100000000 -m15 -o ecoli.k15.hist ecoli_pe_R?.fastq
```

![image-20181216075653713](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181216075653713.png)

Identify the components of the genome in the spectra-cn.

- Is this a good assembly? Why?
- what can you say about the original genome and about the assembly looking at the spectra-cn?

```bash
$ kat comp -H100000000 -m15 -o ecoli.k15 'ecoli_pe_R1.fastq' e-coli.fasta
$ kat plot spectra-cn -x200 -o ecoli.k15-main.mx.spectra-cn.png ecoli.k15-main.mx
```

![image-20181216080933141](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181216080933141.png)

### random hetero1 kat comp

- What do you expect to encounter in a heterozygous assembly spectra-cn?
- is the heterozygosity in this genome high/low? Why?
- Whay does each distribution in the spectra-cn means? (shapes and colors)
- is this a good assembly?

```
$ kat comp -m15 -H100000000 -o unitigs_vs_pe 'pe_reads_R*' assembly/assembly_test-3.fa
```

![image-20181216082508152](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181216082508152.png)

```
$ kat comp -m15 -H100000000 -o reference_vs_pe 'pe_reads_R*' random_genome_AB.fasta
```

- Why does each distribution in the spectra-cn means? (shapes and colors)
- is this a good assembly?

![image-20181216082408862](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181216082408862.png)

### kat sect example

```bash
$ kat sect -m15 -H100000000 -o contigs_vs_pe_sect assembly/assembly_test-8.fa pe_reads_R1.fastq pe_reads_R2.fastq
```

```bash
$ kat sect -m15 -H100000000 -o contigs_vs_self_sect assembly/assembly_test-8.fa assembly/assembly_test-8.fa
```

![image-20181216090411269](/Users/ggarcia/Library/Application Support/typora-user-images/image-20181216090411269.png)

