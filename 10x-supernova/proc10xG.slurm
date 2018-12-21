#!/bin/bash
#
#SBATCH --job-name=proc10xG # Job name
#SBATCH --nodes=1
#SBATCH --time=20-0
#SBATCH --ntasks=24 # Number of cores
#SBATCH --mem=4000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production # Partition to submit to
#SBATCH --reservation=workshop # use the workshop reservation
#SBATCH --account=workshop # use the workshop account
#SBATCH --output=slurm_out/proc10xG-%N-%j.out # File to which STDOUT will be written
#SBATCH --error=slurm_out/proc10xG-%N-%j.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail@ucdavis.edu # Email to which notifications will be sent

hostname

start=`date +%s`

echo "My SLURM_JOB_ID: $SLURM_JOB_ID"


THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)

module load anaconda2
proc10xPath="proc10xG"

basepath="."
fastqs=${basepath}/2018_Sept_10X/Project_ERAG_L2_ASPWS02
fastq1=${fastqs}/ASPWS02_S41_L002_R1_001.fastq.gz
fastq2=${fastqs}/ASPWS02_S41_L002_R2_001.fastq.gz

out_path=${basepath}/aspidoscelis_lizard_proc_fastq
mkdir ${out_path}
out_prefix=${out_path}/aspidoscelis_lizard_reads

call="${proc10xPath}/process_10xReads.py \
 -1 ${fastq1} \
 -2 ${fastq2} \
 -o ${out_prefix} -a"

echo $call
eval $call

end=`date +%s`

runtime=$((end-start))

echo $runtime

exit

