#!/bin/bash
#
#SBATCH --job-name=example # Job name
#SBATCH --nodes=1
#SBATCH --ntasks=1 # Number of cores
#SBATCH --mem=1000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --time=0-02:00 # 0 days, 2 hours
#SBATCH --partition=production
#SBATCH --account=workshop
#SBATCH --reservation=workshop # Partition to submit to
#SBATCH --output=example-%N-%j.out # File to which STDOUT will be written, with Node and Job ID
#SBATCH --error=example-%N-%j.err # File to which STDERR will be written, with Node and Job ID
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=myemail@ucdavis.edu # Email to which notifications will be sent


begin=`date +%s`

echo $HOSTNAME
echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID

sample=`sed "${SLURM_ARRAY_TASK_ID}q;d" samples.txt`
R1=${sample}_L006_R1_001.fastq.gz
R2=${sample}_L006_R2_001.fastq.gz

module load scythe
module load sickle

scythe -a adapters.fasta -q sanger -o ${sample}.scythe.R1.fastq $R1
scythe -a adapters.fasta -q sanger -o ${sample}.scythe.R2.fastq $R2
sickle pe -f ${sample}.scythe.R1.fastq -r ${sample}.scythe.R2.fastq -t sanger -o ${sample}.sickle.R1.fastq -p ${sample}.sickle.R2.fastq -s ${sample}.singles.fastq

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
