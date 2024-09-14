#!/usr/bin/env bash

#PBS -N Phagenus_NJ_PE_GF
#PBS -l nodes=1:ppn=20 #1 of node requested; 20 processors in total
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



# AIM: Running PhaGenus on NJ_PE_GF_cross_assembly

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
PHAMER_PHAGES="$HOME_DIR/working/7_bacteriophages/1_phabox/NJ_PE_GF_phabox/phage_contigs.fa"
PHAGENUS_DIR="/data/gent/vo/001/gvo00125/vsc44392/viral_tools/phagenus"
OUTPUT_DIR="$HOME_DIR/working/7_bacteriophages/3_phagenus/NJ_PE_GF_phagenus_output"
MIDFOLDER="$OUTPUT_DIR/mid"
#OUTPUT_FILE="$OUTPUT_DIR/NJ_PE_GF_phagenus_output.csv"

# PhaGenus ony runs when ran in the git cloned repo

mkdir -p $OUTPUT_DIR $MIDFOLDER
cd $PHAGENUS_DIR

mamba activate phagenus
#export MKL_SERVICE_FORCE_INTEL=1

# Running PhaGenus

python phagenus.py --contigs $PHAMER_PHAGES --len 3000 --out NJ_PE_GF_phagenus_output.csv --midfolder $MIDFOLDER --reject 0.035 --sim high --threads 20


mamba deactivate