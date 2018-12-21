#!/bin/bash
#
#SBATCH --job-name=mkbwaref # Job name
#SBATCH --nodes=1
#SBATCH --time=1-0
#SBATCH --ntasks=1 # Number of cores
#SBATCH --mem=12000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production # Partition to submit to
#SBATCH --reservation=workshop # use the workshop reservation
#SBATCH --account=workshop # use the workshop account
#SBATCH --output=slurm_out/mkbwaref-%N-%j.out # File to which STDOUT will be written
#SBATCH --error=slurm_out/mkbwaref-%N-%j.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail@ucdavis.edu # Email to which notifications will be sent

hostname

echo "My SLURM_JOB_ID"
echo $SLURM__JOB_ID

start=`date +%s`

THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1000)

module load bwa/0.7.16a

basepath="."
out_dir="aspidoscelis_lizard_supernova_outs"
in_fasta="${out_dir}/aspidoscelis_lizard_supernova.pseudohap2.1.fasta.gz"

call="bwa index ${in_fasta}"

echo $call
eval $call

end=`date +%s`

runtime=$((end-start))

echo $runtime
