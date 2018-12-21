#!/bin/bash
#
#SBATCH --array=1-4
#SBATCH --job-name=kat # Job name
#SBATCH --nodes=1
#SBATCH --time=10-9
#SBATCH --ntasks=8 # Number of cores
#SBATCH --mem=500000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production # Partition to submit to
#SBATCH --reservation=workshop # use the workshop reservation
#SBATCH --account=workshop # use the workshop account
#SBATCH --output=slurm_out/kat-%N-%j.out # File to which STDOUT will be written
#SBATCH --error=slurm_out/kat-%N-%j.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail@ucdavis.edu # Email to which notifications will be sent

hostname

start=`date +%s`

echo "My SLURM_JOB_ID: $SLURM_JOB_ID"

THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)

THREADS=8
kmer=(16 21 27 33)
echo "Processing kmer: ${kmer[SLURM_ARRAY_TASK_ID]}"

module load anaconda2
module load kat

proc10xPath="python2 proc10xG"

basepath="."
proc10xG_path=${basepath}/aspidoscelis_lizard_proc_fastq
proc10xG_prefix=${proc10xG_path}/aspidoscelis_lizard_reads

out_path=${basepath}/aspidoscelis_lizard_kat2
mkdir ${out_path}
out_prefix=${out_path}/aspidoscelis_lizard_reads

call="kat hist \
  -o ${out_prefix}-k${kmer[SLURM_ARRAY_TASK_ID]} \
  -m ${kmer[SLURM_ARRAY_TASK_ID]} \
  -t $((THREADS - 2)) \
  <( ${proc10xPath}/filter_10xReads.py -1 ${proc10xG_prefix}_R1_001.fastq.gz -2 ${proc10xG_prefix}_R2_001.fastq.gz )"

echo $call
eval $call

end=`date +%s`

runtime=$((end-start))

echo $runtime

exit

