#!/usr/bin/env bash

#PBS -N vcontact3_NJ_PE_GF
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



# AIM: Running vCONTACT3 on genomad identified viral nucleotides

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUS="$HOME_DIR/working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus.fna"
OUTPUT_DIR="$HOME_DIR/working/8_vcontact3/NJ_PE_GF_vcontact3_output"
DB_DIR="$HOME_DIR/../../viral_tools/vcontact3/vcontact3_db"

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR


mamba activate vcontact3

# Running vcontact3
vcontact3 run --nucleotide $GENOMAD_VIRUS --output $OUTPUT_DIR --db-domain "prokaryotes" --db-version 223 --db-path $DB_DIR

mamba deactivate