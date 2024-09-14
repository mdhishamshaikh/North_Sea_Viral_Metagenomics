#!/usr/bin/env bash

#PBS -N eggnog_mapping_NJ_PE_GF
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



# AIM: Running eggNOG mapper on genomad identified viral nucleotides

. ~/vo_vliz.sh
. .bashrc

# Defining directories
HOME_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUS_PROTEINS="$HOME_DIR/working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus_proteins.faa"
OUTPUT_DIR="$HOME_DIR/working/9_functional_annotation/1_eggnog_mapping/NJ_PE_GF_eggnog_mapper_output"
EGGNOG_DB_DIR="$HOME_DIR/../../viral_tools/eggnog/eggnog_db"

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR


mamba activate eggnog_mapper

# Running eggNOG mapper

# emapper.py -m diamond --sensmode fast --no_annot -i virus_proteins_100 -o virus_test_100_diamond_2.1.8 --cpu 4 --data_dir $EGGNOG_DB_DIR --override
# emapper.py -m diamond --sensmode fast --no_annot -i cyanophage_capsid.faa -o cyanophage_test_100_diamond_2.1.8 --cpu 4 --data_dir $EGGNOG_DB_DIR --override

# emapper.py -m no_search --annotate_hits_table virus_test_100_diamond_2.1.8.emapper.seed_orthologs -o virus_test_100_diamond_2.1.8 --cpu 4 --data_dir $EGGNOG_DB_DIR --override
# emapper.py -m no_search --annotate_hits_table cyanophage_test_100_diamond_2.1.8.emapper.seed_orthologs -o cyanophage_test_100_diamond_2.1.8 --cpu 4 --data_dir $EGGNOG_DB_DIR --override



emapper.py -m diamond --no_annot  --no_file_comments --cpu 40 -i $GENOMAD_VIRUS_PROTEINS -o NJ_PE_GF \
    --output_dir $OUTPUT_DIR --data_dir $EGGNOG_DB_DIR  --override

emapper.py --annotate_hits_table NJ_PE_GF.emapper.seed_orthologs \
     --no_file_comments --data_dir $EGGNOG_DB_DIR \
     -o NJ_PE_GF_functional_annotation --cpu 40 \
     --output_dir $OUTPUT_DIR --override


mamba deactivate




