Work plan for assessing viral diversity and ecology in the North Sea.

Data Description:
Samples 



# Plans

# Step 0: fetch raw reads from Garin-Fernandez et al. (2018) from ENA project number - PRJEB21210


# Step 1: Quality checks on raw reads and metagenome assembly.
fastP was used to trim the raw reads and assess the quality. viromeQC was used to assess non-viral contamination. 
Although, the qaulity of the reads are good, fastP suggested high duplication % for NJ and PE samples, which was also reflective in viromeQC analysis (high enrichment score).
Considering I have already used dedup option in fastP, we assume that these duplication are likely due to abundant viruses.





I will run prin
fastP for quality assessment and quality filtering. I will have to apply these separately for Garin-Fernandez et al. (2018) study as it doesn't use the A-LA 

fastP performed on all samples. ViromeQC unning right now. 

# Cross assemblies are ruunning too, while individual assemblies are done. 

genomad script for cross assembly needs to be worked on. 

individual assembly geomad is running

check for metaquast ouptut for individual assemblies and compile it usi gmultiqc again

run metaquast o corss assemblies when they are done. 

check if the cross assemblies are stuck.

# CHECK INDIVIDUAL ASSEBLY OF 24 GF2018 an dthen run metaquast and multiqc - DONE
now runing genomad for 24_GF2018

# I prefer caat instead of while IFS read
cross assemblies are fine






#### CHERRY - use Taxonkit to add lineage information from the names for bacterial hosts

#### Combine PhaMER, PhaTYP, PhaGCN2 and CHERRY outptu and make it compatible for RawGraph alluvial diagram

#### PhaGCN2 based taxonomy  - mapped reads
ask Sarah a nd Filp abot ow to best adust for ssDNA vs dsDA
