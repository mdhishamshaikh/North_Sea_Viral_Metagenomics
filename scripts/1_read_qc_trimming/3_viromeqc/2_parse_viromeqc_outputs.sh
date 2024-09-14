# To combine viromeQC outputs into a single file
#!/usr/bin/env bash


REPORTS_DIR="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/working/1_read_qc_trimming/3_viromeqc"
OUTPUT_FILE="/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/working/1_read_qc_trimming/3_viromeqc/NJ_PE_GF_combined_viromeqc_report.txt"

# Creating an empty output file
echo -e "Sample\tReads\tReads_HQ\tSSU rRNA alignment rate\tLSU rRNA alignment rate\tBacterial_Markers alignment rate\ttotal enrichment score" > "$OUTPUT_FILE"

# Looping through each ViromeQC report and appending it to the combined file
for report in "$REPORTS_DIR"/*_viromeqc_report.txt; do
   
    sample=$(basename "$report" | cut -d'_' -f1-3)
    
    tail -n +2 "$report" | sed "s/^/${sample}\t/" >> "$OUTPUT_FILE"
done

echo "Combined ViromeQC report created at $OUTPUT_FILE"
