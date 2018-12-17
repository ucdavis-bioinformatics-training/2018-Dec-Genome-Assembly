#!/bin/bash
#
#SBATCH --job-name=replaceMe  # Job name
#SBATCH --nodes=1
#SBATCH --time=3-0
#SBATCH --exclusive  # take over whole node
#SBATCH --ntasks=24  # Number of cores
#SBATCH --mem=120G  # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production  # Partition to submit to
#SBATCH --account=workshop  # for workshop
#SBATCH --reservation=workshop  # for workshop
#SBATCH --output=run_minimap-%A-%a.out  # File to which STDOUT will be written
#SBATCH --error=run_minimap-%A-%a.err  # File to which STDERR will be written
#SBATCH --mail-type=END  # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=replaceMe@geemail.com  # Email to which notifications will be sent

hostname
start=`date +%s`
echo "My SLURM_JOB_ID: $SLURM_JOB_ID"
THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1024)

module load minimap2/2.7
call="minimap2 -x ava-ont -t 24 \
      ../00-RawData/minion.fq.gz \
      ../00-RawData/minion.fq.gz \
      | gzip -1 > minion.self.paf.gz
"
echo $call
eval $call

end=`date +%s`
runtime=$((end-start))
echo $runtime
exit

