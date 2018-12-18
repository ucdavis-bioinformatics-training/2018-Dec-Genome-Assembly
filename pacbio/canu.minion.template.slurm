#!/bin/bash
#
#SBATCH --job-name=replaceMe  # Job name
#SBATCH --nodes=1
#SBATCH --time=3-0
#SBATCH --exclusive  # take over whole node
#SBATCH --ntasks=48  # Number of cores
#SBATCH --mem=500G  # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production  # Partition to submit to
#SBATCH --reservation=workshop  # for workshop
#SBATCH --account=workshop  # for workshop
#SBATCH --output=run_canu-%A-%a.out  # File to which STDOUT will be written
#SBATCH --error=run_canu-%A-%a.err  # File to which STDERR will be written
#SBATCH --mail-type=END  # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=replaceMe@geemail.com  # Email to which notifications will be sent

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)

module load canu/1.8
call="canu useGrid=false --maxMemory=500G --maxThreads=48 \
  -p CANU-minion \
  -d CANU-minion \
  genomeSize=135m \
  -nanopore-raw ../00-RawData/minion.fq.gz
"
echo $call
eval $call

end=`date +%s`
runtime=$((end-start))
echo $runtime
exit

