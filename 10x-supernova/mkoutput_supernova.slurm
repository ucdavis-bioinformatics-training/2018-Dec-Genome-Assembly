#!/bin/bash
#
#SBATCH --job-name=mkoutput_supernova # Job name
#SBATCH --nodes=1
#SBATCH --time=1-0
#SBATCH --ntasks=8 # Number of cores
#SBATCH --mem=120000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production # Partition to submit to
#SBATCH --reservation=workshop # use the workshop reservation
#SBATCH --account=workshop # use the workshop account
#SBATCH --output=slurm_out/mkoutput_supernova-%N-%j.out # File to which STDOUT will be written
#SBATCH --error=slurm_out/mkoutput_supernova-%N-%j.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail@ucdavis.edu # Email to which notifications will be sent

hostname

echo "My SLURM_JOB_ID"
echo $SLURM__JOB_ID

start=`date +%s`

THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1000)

module load supernova/2.1.1

basepath="."

amsdir=${basepath}/aspidoscelis_lizard_supernova/outs

out_dir="aspidoscelis_lizard_supernova_outs"
mkdir ${out_dir}

cp ${amsdir}/report.txt ${out_dir}/report.txt
cp ${amsdir}/summary.csv ${out_dir}/summary.csv

out_prefix="${out_dir}/aspidoscelis_lizard_supernova"

## output style options are raw|megabubbles|pseudohap|pseudohap2
## minsize default is 500bp for raw, 1000bp for all others
## headers default is short
outstyle=pseudohap2
minsize=1000

call="supernova mkoutput \
--asmdir=${amsdir}/assembly \
--outprefix=${out_prefix}.${outstyle} \
--style=${outstyle} \
--minsize=${minsize} \
--headers=full"

echo $call
eval $call

end=`date +%s`

runtime=$((end-start))

echo $runtime
