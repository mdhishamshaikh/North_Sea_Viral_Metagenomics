#!/usr/bin/env bash

#PBS -N PhaGCN2.0_NJ_PE_GF
#PBS -l nodes=1:ppn=40 #1 of node requested; 20 processors in total
#PBS -l walltime=48:00:00 # 48 hours walltime
#PBS -l mem=150gb #150 Gb memory in total
#PBS -m abe
#PBS -M MohammedHisham.Shaikh@ugent.be
#PBS -o /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_output.log  
#PBS -e /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_error.log   



#Making sure I am on the rigth cluster
module swap cluster/doduo

# Unset OMP_PROC_BIND
unset OMP_PROC_BIND



# AIM: Running PhaGCN2 on NJ_PE_GF_cross_assembly

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
PHAMER_PHAGES="$HOME_DIR/working/7_bacteriophages/1_phabox/NJ_PE_GF_phabox/phage_contigs.fa"


# PhaGCN2 ony runs when ran in the git cloned repo

OUTPUT_DIR="$HOME_DIR/working/7_bacteriophages/2_phagcn2.0/NJ_PE_GF_phagcn2_output"
mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

git clone https://github.com/KennthShang/PhaGCN2.0.git


cd PhaGCN2.0
git checkout PhaGCNv2.0

cd database
tar -zxvf ALL_protein.tar.gz
cd ..


mamba activate phagcn2.0
export MKL_SERVICE_FORCE_INTEL=1

# Running PhaGCN2.0

python run_Speed_up.py --contigs $PHAMER_PHAGES --len 3000 --outpath NJ_PE_GF_phagcn2_results


mamba deactivate