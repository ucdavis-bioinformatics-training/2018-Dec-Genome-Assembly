#!/bin/bash
#
#SBATCH --job-name=run_supernova # Job name
#SBATCH --nodes=1
#SBATCH --time=12-0
#SBATCH --ntasks=48 # Number of cores
#SBATCH --mem=508000 # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=production # Partition to submit to
#SBATCH --reservation=workshop # use the workshop reservation
#SBATCH --account=workshop # use the workshop account
#SBATCH --output=slurm_out/run_supernova-%N-%j.out # File to which STDOUT will be written
#SBATCH --error=slurm_out/run_supernova-%N-%j.err # File to which STDERR will be written
#SBATCH --mail-type=ALL # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=mymail@ucdavis.edu # Email to which notifications will be sent

hostname

start=`date +%s`

echo "My SLURM_JOB_ID"
echo $SLURM_JOB_ID

THREADS=${SLURM_NTASKS}
MEM=$(expr ${SLURM_MEM_PER_NODE} / 1000)


module load supernova/2.1.1
basepath="."

id="aspidoscelis_lizard_supernova"
fastqs=${basepath}/2018_Sept_10X


call="supernova run \
--id=${id} \
--maxreads="all" \
--fastqs=${fastqs} \
--localcores=${THREADS} \
--localmem=${MEM}"

echo $call
eval $call

end=`date +%s`

runtime=$((end-start))

echo $runtime
