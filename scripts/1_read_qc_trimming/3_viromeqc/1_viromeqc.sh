#!/usr/bin/env bash

#PBS -N viromeqc
#PBS -l nodes=1:ppn=40 #1 of node requested; 20 processors in total
#PBS -l walltime=24:00:00 # 48 hours walltime
#PBS -l mem=100gb #100 Gb memory in total
#PBS -m abe
#PBS -M MohammedHisham.Shaikh@ugent.be
#PBS -o /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_output.log  
#PBS -e /data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/logs/${PBS_JOBNAME}_error.log   



#Making sure I am on the rigth cluster
module swap cluster/doduo

# Unset OMP_PROC_BIND
unset OMP_PROC_BIND



# AIM: To assess non-viral contamination in my raw reads

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
OUTPUT_DIR="$HOME_DIR/working/1_read_qc_trimming/3_viromeqc"
TRIMMED_READS_DIR="$HOME_DIR/working/1_read_qc_trimming/1_fastp_trim_qc"
SAMPLE_LIST_NJ_PE_GF="$HOME_DIR/data/sample_overview/NJ_PE_GF_sample_list.csv"




mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

# Activate viromeQC
mamba activate viromeqc


# Running viromeQC 
for sample in $(cat $SAMPLE_LIST_NJ_PE_GF); do
    echo "Processing sample: $sample"
    
    viromeQC.py -i $TRIMMED_READS_DIR/${sample}_R1_paired.fastq.gz $TRIMMED_READS_DIR/${sample}_R2_paired.fastq.gz \
    -o "$OUTPUT_DIR/${sample}_viromeqc_report.txt" \
    --bowtie2_threads 40 \
    --diamond_threads 40 \
    -w environmental

done 

# Parsing the output

. $HOME_DIR/scripts/1_read_qc_trimming/3_viromeqc/2_parse_viromeqc_outputs.sh