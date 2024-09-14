#!/usr/bin/env bash

#PBS -N metacerberus_NJ_PE_GF
#PBS -l nodes=1:ppn=40 #1 of node requested; 20 processors in total
#PBS -l walltime=24:00:00 # 48 hours walltime
#PBS -l mem=200gb #150 Gb memory in total
#PBS -m abe
#PBS -M MohammedHisham.Shaikh@ugent.be
#PBS -o /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_output.log  
#PBS -e /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_error.log   



#Making sure I am on the rigth cluster
module swap cluster/doduo

# Unset OMP_PROC_BIND
unset OMP_PROC_BIND



# AIM: Running metacerberus on genomad identified viral nucleotides

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUS_PROTEINS="$HOME_DIR/working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus_proteins.faa"
OUTPUT_DIR="$HOME_DIR/working/9_functional_annotation/2_metacerberus/NJ_PE_GF_eggnog_mapper_output"

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR


mamba activate metacerberus

# Running metacerberus

metacerberus.py --protein $GENOMAD_VIRUS_PROTEINS --illumina --meta --dir_out $OUTPUT_DIR --cpus 40 

mamba deactivate
