#!/usr/bin/env bash

#PBS -N cd_hit_clustering
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


# AIM: To classify viral contigs

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
ASSEMBLY_DIR="$HOME_DIR/working/2_assembly/2_cross_assemblies"
CROSS_ASSEMBLY_SAMPLES="NJ_PE NJ_PE_GF"
CD_HIT_DIR="$HOME_DIR/working/3_clustering/"


mkdir -p $CD_HIT_DIR
cd $CD_HIT_DIR


mamba activate cd-hit


for sample in  $CROSS_ASSEMBLY_SAMPLES; do
  
    echo "Running cd-hit for sample: $sample"
    mkdir -p $CD_HIT_DIR/${sample}_cd_hit
    cd $CD_HIT_DIR/${sample}_cd_hit

    # Running genomad
   cd-hit-est -i $ASSEMBLY_DIR/${sample}_cross_assembly/${sample}_final_contigs.fa -o $CD_HIT_DIR/${sample}_cd_hit/${sample}_clustered_contigs.fa  -c 0.95 -n 11 -d 0 -T 40 -M 150000
 
done


mamba deactivate