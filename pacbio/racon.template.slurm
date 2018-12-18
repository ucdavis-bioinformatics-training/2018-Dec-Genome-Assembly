#!/bin/bash
#
#SBATCH --job-name=replaceMe  # Job name
#SBATCH --nodes=1
#SBATCH --time=3-0
#SBATCH --exclusive  # take over whole node
#SBATCH --ntasks=8  # Number of cores
#SBATCH --mem=120G  # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production  # Partition to submit to
#SBATCH --reservation=workshop  # for workshop
#SBATCH --account=workshop  # for workshop
#SBATCH --output=run_miniasm-%A-%a.out  # File to which STDOUT will be written
#SBATCH --error=run_miniasm-%A-%a.err  # File to which STDERR will be written
#SBATCH --mail-type=END  # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=replaceMe@geemail.com  # Email to which notifications will be sent

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)

# specify assembly, reads, then filename prefix after slurm script name, e.g.:
# sbatch racon.slurm sampleA.fa sampleA.rq sampleA
asm=$1
reads=$2
prefix=$3
module load racon/1.2.1
module load minimap2/2.7
call="minimap2 -t 8 ${asm} ${reads} > ${prefix}.round1.paf"
echo $call
eval $call

call="racon -t 8 ${reads} ${prefix}.round1.paf ${asm} > ${prefix}.round1.fa 2> ${prefix}.round1.log"
echo $call
eval $call

call="minimap2 -t 8 ${prefix}.round1.fa ${reads} > ${prefix}.round2.paf"
echo $call
eval $call

call="racon -t 8 ${reads} ${prefix}.round2.paf ${prefix}.round1.fa > ${prefix}.round2.fa 2> ${prefix}.round2.log"
echo $call
eval $call

end=`date +%s`
runtime=$((end-start))
echo $runtime
exit

