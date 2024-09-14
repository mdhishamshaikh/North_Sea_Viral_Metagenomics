#!/usr/bin/env bash

#PBS -N vrhyme_binning_NJ_PE_GF
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



# AIM: vRhyme binning for NJ_PE_GF_cross_assembly

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUS_FASTA="$HOME_DIR/working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus.fna"
TRIMMED_READS_DIR="$HOME_DIR/working/1_read_qc_trimming/1_fastp_trim_qc"
BAM_DIR="$HOME_DIR/working/5_read_mapping/3_NJ_PE_GF_genomad/mapping"
BINNING_DIR="$HOME_DIR/working/6_binning/2_vrhyme"
UPDATED_TRIMMED_READS_DIR="$BINNING_DIR/trimmed_paired_reads"

mkdir -p  $BINNING_DIR $UPDATED_TRIMMED_READS_DIR

# Making symlinks of the trimmed reads and fixing names

# Create destination directory if it doesn't exist
mkdir -p $UPDATED_TRIMMED_READS_DIR

# # Loop through all paired files
# for file in $TRIMMED_READS_DIR/*_paired.fastq.gz; do
#   # Extract the base name of the file (without path)
#   basename=$(basename "$file")

#   # Determine whether it's R1 or R2 and adjust the name accordingly
#   if [[ "$basename" == *R1_paired.fastq.gz ]]; then
#     newname="${basename/_R1_paired.fastq.gz/_R1.fastq.gz}"
#   elif [[ "$basename" == *R2_paired.fastq.gz ]]; then
#     newname="${basename/_R2_paired.fastq.gz/_R2.fastq.gz}"
#   fi

#   # Create the symlink in the updated directory
#   ln -s "$file" "$UPDATED_TRIMMED_READS_DIR/$newname"
# done



cd $BINNING_DIR



mamba activate vrhyme

#vRhyme -i $ASSEMBLY -b $BAM_DIR/*.bam -o $BINNING_DIR/NJ_PE_GF -t 5 --speed

vRhyme -i $GENOMAD_VIRUS_FASTA -r $UPDATED_TRIMMED_READS_DIR/*fastq.gz -o $BINNING_DIR/NJ_PE_GF_from_reads_genomad -t 5 --speed



mamba deactivate