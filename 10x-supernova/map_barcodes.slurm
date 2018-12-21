#!/bin/bash
#
#SBATCH --job-name=map_barcodes # Job name
#SBATCH --nodes=1
#SBATCH --ntasks=20 # Number of cores
#SBATCH --mem=64000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=3-00
#SBATCH --partition=production # Partition to submit to
#SBATCH --reservation=workshop # use the workshop reservation
#SBATCH --account=workshop # use the workshop account
#SBATCH --output=slurm_out/mapbarcodes-%N-%j.out # File to which STDOUT will be written
#SBATCH --error=slurm_out/mapbarcodes-%N-%j.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail@ucdavis.edu # Email to which notifications will be sent

start=`date +%s`

echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)
MAPTHREADS=$(expr ${THREADS} - 6)
SORTTHREADS=$(expr ${THREADS} - ${MAPTHREADS})

hostname

module load bwa/0.7.16a
module load samtools/1.9
module load anaconda2
proc10xPath="proc10xG"

# requires bwa index on fasta and samtools faidx on fasta
basepath="."
samplename=aspidoscelis_lizard

in_path=${basepath}/${samplename}_proc_fastq
in_prefix=${in_path}/${samplename}_reads
output=${in_path}/${samplename}-10xMapping2self.bam

mapfasta=${basepath}/${samplename}_supernova_outs/${samplename}_supernova.pseudohap2.1.fasta.gz

call="bwa mem -t ${MAPTHREADS} -C \
 -R '@RG\tID:${samplename}\tSM:${samplename}\tPL:ILLUMINA\tDS:Paired' \
 ${mapfasta} ${in_prefix}_R1_001.fastq.gz ${in_prefix}_R2_001.fastq.gz \
 | python ${proc10xPath}/samConcat2Tag.py \
 | samtools sort -m 768M --threads ${SORTTHREADS} \
 | samtools view -hb -o ${output} -"

echo $call
eval $call

call="samtools index -@ ${THREADS} ${output}"
echo $call
eval $call

call="samtools idxstats ${output} > ${output}.idxstats"
echo $call
eval $call

call="samtools flagstat -@ ${THREADS} ${output} > ${output}.flagstat"
echo $call
eval $call

call="samtools stats -@ ${THREADS} ${output} > ${output}.stats"
echo $call
eval $call

end=`date +%s`

runtime=$((end-start))

echo $runtime
