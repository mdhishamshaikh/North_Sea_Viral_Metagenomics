# Fetching raw reads from Garin-Fernandez et al. (2018)

. ~/vo_vliz.sh
cd ~/Projects/North_Sea_Viral_Metagenomics/data

mkdir GF_2018 
cd GF_2018


# Downloding fastq files from ENA (Project number PRJEB21210).
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR200/ERR2002980/*fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR200/ERR2002981/*fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR200/ERR2002982/*fastq.gz
wget -nc ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR200/ERR2002983/*fastq.gz

# renaming files
for file in *_R*.fastq.gz; do
   
    number=$(echo "$file" | grep -o '^[0-9]*')

    rest=$(echo "$file" | sed 's/^[0-9]*_//')

    mv "$file" "V_${number}_GF2018_${rest}"
done

mv *fastq.gz ../raw_reads/

# Removing the empty folder
cd ..
rm -rf GF_2018
