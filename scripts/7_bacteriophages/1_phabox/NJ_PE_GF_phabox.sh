#!/usr/bin/env bash

#PBS -N PhaBOX_NJ_PE_GF
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



# AIM: Running PhaBOX(PhaMER, PhaGCN, PhaTYP, CHERRY) on NJ_PE_GF_cross_assembly

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUSES="$HOME_DIR/working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus.fna"
ROOT_PATH="$HOME_DIR/working/7_bacteriophages/1_phabox/NJ_PE_GF_phabox"
OUTPUT_PATH="NJ_PE_GF_phabox_output/"
MID_FOLDER="mid/"
PARAMETERS_PATH="$HOME_DIR/../../viral_tools/PhaBOX/parameters/"
SCRIPTS_PATH="$HOME_DIR/../../viral_tools/PhaBOX/scripts/"
DATABASE_DIR="$HOME_DIR/../../viral_tools/PhaBOX/database/"
PHABOX_MAIN_SCRIPT="$HOME_DIR/../../viral_tools/PhaBOX/main.py"

mkdir -p $ROOT_PATH
cd $ROOT_PATH



mamba activate phabox

# Running PhaBOX

python $PHABOX_MAIN_SCRIPT --contigs $GENOMAD_VIRUSES --threads 40 --len 3000 --rootpth $ROOT_PATH --out $OUTPUT_PATH --dbdir $DATABASE_DIR --parampth $PARAMETERS_PATH --scriptpth $SCRIPTS_PATH



mamba deactivate