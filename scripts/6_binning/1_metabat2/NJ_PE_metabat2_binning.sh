#!/usr/bin/env bash

#PBS -N metabat2_binning_NJ_PE
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



# AIM: Metabat2 binning for NJ_PE_cross_assembly

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
ASSEMBLY="$HOME_DIR/working/2_assembly/2_cross_assemblies/NJ_PE_cross_assembly/NJ_PE_final_contigs.fa"
DEPTH_FILE="$HOME_DIR/working/5_depth_coverage/1_NJ_PE/NJ_PE_depth.txt"
BINNING_DIR="$HOME_DIR/working/6_metabat2_binning/1_NJ_PE"


mkdir -p  $BINNING_DIR
cd $BINNING_DIR


mamba activate metabat2

metabat2 -i $ASSEMBLY -a $DEPTH_FILE -o $BINNING_DIR/bin

mamba deactivate