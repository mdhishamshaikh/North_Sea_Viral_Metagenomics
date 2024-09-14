setwd("/kyukon/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics/working/7_bacteriophages/10_mapping_viruses/genomad_viruses")

# Load required libraries
library(tidyverse)
library(data.table)
library(httpgd)
hgd()
library(ggsci)
library(reshape2)
library(pheatmap)


HOME_DIR <- "/data/gent/vo/001/gvo00125/vsc44392/Projects/North_Sea_Viral_Metagenomics"
GENOMAD_VIRUS_SUMMARY <- file.path(HOME_DIR, "working/4_genomad/2_genomad_cross_assemblies/NJ_PE_GF_genomad_output/NJ_PE_GF_clustered_contigs_summary/NJ_PE_GF_clustered_contigs_virus_summary.tsv")
BOWTIE2_QUANT <- file.path(HOME_DIR, "working/5_read_mapping/2_NJ_PE_GF/combined_quant/combined_read_counts_NJ_PE_GF.txt")
OUTPUT_DIR <- file.path(HOME_DIR, "working/7_bacteriophages/10_mapping_viruses/genomad_viruses")
RPKM_OUTPUT <- file.path(OUTPUT_DIR, "genomad_viral_contig_RPKM.tsv")
PHABOX_SUMMARY <- file.path(HOME_DIR, "working/7_bacteriophages/1_phabox/NJ_PE_GF_phabox/NJ_PE_GF_phabox_output/prediction_summary.csv")
PHABOX_RPKM_OUTPUT <- file.path(OUTPUT_DIR, "phabox_summary_with_rpkm.tsv")

dir.create(OUTPUT_DIR, recursive = TRUE)


# Step 1: Load GeNomad viral contigs and Bowtie2 quantification data using fread
genomad_viral_contigs <- fread(GENOMAD_VIRUS_SUMMARY, header = TRUE, sep = "\t", select = "seq_name")
setnames(genomad_viral_contigs, "seq_name", "Contig")

bowtie_quant <- fread(BOWTIE2_QUANT, header = TRUE, sep = "\t")

# Step 2: Merge Bowtie2 quant data with GeNomad viral contigs
# Add a column "genomad" to indicate if the contig is viral (based on GeNomad prediction)
merged_data <- bowtie_quant %>%
  mutate(genomad = if_else(Contig %in% genomad_viral_contigs$Contig, "viral", "non-viral"))

# Step 3: Calculate RPK for each contig (Reads per Kilobase)
merged_data <- merged_data %>%
  mutate(RPK = Mapped_Reads / (Contig_Length / 1000))

# Step 4: Calculate total mapped reads for normalization
total_mapped_reads <- sum(merged_data$Mapped_Reads, na.rm = TRUE)

# Step 5: Calculate RPKM (Reads Per Kilobase per Million mapped reads)
merged_data <- merged_data %>%
  mutate(RPKM = RPK * (1e6 / total_mapped_reads))

# Step 6: Save the final data with RPKM and Genomad classification using fwrite (fast write)
fwrite(merged_data, RPKM_OUTPUT, sep = "\t")
cat("RPKM data with Genomad classification saved to:", RPKM_OUTPUT, "\n")

# Step 7: Load PHABOX summary and previously saved RPKM data using fread
phabox_summary <- fread(PHABOX_SUMMARY, header = TRUE, sep = ",")
rpkm_data <- fread(RPKM_OUTPUT, header = TRUE, sep = "\t")

# Step 8: Merge PHABOX data with RPKM data based on Contig/Accession
final_merged_data <- rpkm_data %>%
  left_join(phabox_summary, by = c("Contig" = "Accession")) %>%
  select(Sample, Contig, everything())  # Reorder columns

# Step 9: Save the merged data with PHABOX and RPKM information using fwrite
fwrite(final_merged_data, PHABOX_RPKM_OUTPUT, sep = "\t")
cat("PHABOX and RPKM merged data saved to:", PHABOX_RPKM_OUTPUT, "\n")


# Viral vs non-viral abundance ####

phabox_rpkm_data <- fread("phabox_summary_with_rpkm.tsv", header = TRUE, sep = "\t")

# Step 1: Summarize total RPKM by Sample and GeNomad classification
rpkm_summary <- phabox_rpkm_data %>%
  group_by(Sample, genomad) %>%
  summarize(total_rpkm = sum(RPKM, na.rm = TRUE)) %>%
  ungroup()

# Step 2: Create a stacked bar plot of total RPKM (viral vs non-viral)
stacked_bar_plot <- ggplot(rpkm_summary, aes(x = Sample, y = total_rpkm, fill = genomad)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Total RPKM by Sample (Viral vs Non-Viral)", x = "Sample", y = "Total RPKM") +
  scale_fill_manual(values = c("viral" = "#173B45", "non-viral" = "#B43F3F")) +
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90),
  text = element_text(family = "sans"))

# Display the stacked bar plot
print(stacked_bar_plot)

# Step 3: Calculate relative RPKM (proportion of viral/non-viral in each sample)
rpkm_relative <- rpkm_summary %>%
  group_by(Sample) %>%
  mutate(relative_rpkm = total_rpkm / sum(total_rpkm)) %>%
  ungroup()

# Step 4: Create a relative abundance plot (viral vs non-viral)
relative_abundance_plot <- ggplot(rpkm_relative, aes(x = Sample, y = relative_rpkm, fill = genomad)) +
  geom_bar(stat = "identity", position = "fill") +
  labs(title = "Relative RPKM by Sample (Viral vs Non-Viral)", x = "Sample", y = "Proportion of RPKM") +
  scale_fill_manual(values = c("viral" = "#173B45", "non-viral" = "#B43F3F")) +
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90),
  text = element_text(family = "Arial"))

# Display the relative abundance plot
print(relative_abundance_plot)


# Phages vs Viruses #####


# Step 1: Subset only the viral contigs based on GeNomad classification
viral_data <- phabox_rpkm_data %>%
  filter(genomad == "viral")

# Step 2: Classify the viral contigs into "phage" and "non-phage" using PHaMer classification
# "phage" for contigs classified as phages by PHaMer, "non-phage" otherwise
viral_data <- viral_data %>%
  mutate(classification = if_else(PhaMer == "phage", "phage", "non-phage"))

# Step 3: Summarize total RPKM by Sample and classification (phage vs non-phage)
rpkm_summary <- viral_data %>%
  group_by(Sample, classification) %>%
  summarize(total_rpkm = sum(RPKM, na.rm = TRUE)) %>%
  ungroup()

# Step 4: Create a stacked bar plot of total RPKM (phage vs non-phage)
stacked_bar_plot <- ggplot(rpkm_summary, aes(x = Sample, y = total_rpkm, fill = classification)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Total RPKM by Sample (Phage vs Non-Phage)", x = "Sample", y = "Total RPKM") +
  scale_fill_manual(values = c("phage" = "#009E73", "non-phage" = "#D55E00")) +
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        text = element_text(family = "Arial"))

# Display the stacked bar plot
print(stacked_bar_plot)

# Step 5: Calculate relative RPKM (proportion of phage/non-phage in each sample)
rpkm_relative <- rpkm_summary %>%
  group_by(Sample) %>%
  mutate(relative_rpkm = total_rpkm / sum(total_rpkm)) %>%
  ungroup()

# Step 6: Create a relative abundance plot (phage vs non-phage)
relative_abundance_plot <- ggplot(rpkm_relative, aes(x = Sample, y = relative_rpkm, fill = classification)) +
  geom_bar(stat = "identity", position = "fill") +
  labs(title = "Relative RPKM by Sample (Phage vs Non-Phage)", x = "Sample", y = "Proportion of RPKM") +
  scale_fill_manual(values = c("phage" = "#009E73", "non-phage" = "#D55E00")) +
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        text = element_text(family = "Arial"))

# Display the relative abundance plot
print(relative_abundance_plot)


# Phages families #####
phage_data <- viral_data %>%
  filter(PhaMer == "phage")

# Step 3: Summarize total RPKM by Sample and PhaGCN classification
rpkm_summary_phage <- phage_data %>%
  group_by(Sample, PhaGCN) %>%
  summarize(total_rpkm = sum(RPKM, na.rm = TRUE)) %>%
  ungroup()

rpkm_summary_phage$PhaGCN <- factor(rpkm_summary_phage$PhaGCN, 
                                      levels = c(setdiff(unique(rpkm_summary_phage$PhaGCN), "unknown"), "unknown"))

combined_palette <- c(
  pal_nejm()(4),  # NPJ palette with 4 colors
  pal_aaas()(7),  # AAAS palette with 4 colors
  pal_lancet()(7),  # Lancet palette with 4 colors
  pal_jama()(7)  # JAMA palette with 4 colors
)

# Step 4: Create a stacked bar plot of total RPKM by PhaGCN classification
stacked_bar_plot_phage <- ggplot(rpkm_summary_phage, aes(x = Sample, y = total_rpkm, fill = PhaGCN)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Total RPKM by Sample and PhaGCN (Phages)", x = "Sample", y = "Total RPKM") +
  scale_fill_manual(values = combined_palette) +  # Use the combined palette here
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        text = element_text(family = "Arial"))

# Display the stacked bar plot
print(stacked_bar_plot_phage)

rpkm_relative_phage <- rpkm_summary_phage %>%
  group_by(Sample) %>%
  mutate(relative_rpkm = total_rpkm / sum(total_rpkm)) %>%
  ungroup()

# Step 3: Ensure "unknown" is on top by converting PhaGCN to a factor and reordering the levels
rpkm_relative_phage$PhaGCN <- factor(rpkm_relative_phage$PhaGCN, 
                                      levels = c(setdiff(unique(rpkm_relative_phage$PhaGCN), "unknown"), "unknown"))

# Define the combined palette with multiple ggsci palettes
combined_palette <- c(
  pal_nejm()(4),  # NEJM palette with 4 colors
  pal_aaas()(7),  # AAAS palette with 7 colors
  pal_lancet()(7),  # Lancet palette with 7 colors
  pal_jama()(7)  # JAMA palette with 7 colors
)

# Step 4: Create a relative abundance plot of RPKM by PhaGCN classification
relative_abundance_plot_phage <- ggplot(rpkm_relative_phage, aes(x = Sample, y = relative_rpkm, fill = PhaGCN)) +
  geom_bar(stat = "identity", position = "fill") +
  labs(title = "Relative RPKM by Sample and PhaGCN (Phages)", x = "Sample", y = "Proportion of RPKM") +
  scale_fill_manual(values = combined_palette) +  # Use the combined palette here
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        text = element_text(family = "Arial"))

# Display the relative abundance plot
print(relative_abundance_plot_phage)


#### Only known phage amilies


# Step 1: Subset the data to include only the phages identified by PHaMER, excluding "unknown" PhaGCN
phage_data <- viral_data %>%
  filter(PhaMer == "phage" & PhaGCN != "unknown")  # Exclude "unknown" PhaGCN values

# Step 2: Summarize total RPKM by Sample and PhaGCN classification (phage families)
rpkm_summary_phage <- phage_data %>%
  group_by(Sample, PhaGCN) %>%
  summarize(total_rpkm = sum(RPKM, na.rm = TRUE)) %>%
  ungroup()

# Step 3: Define the combined color palette from multiple ggsci palettes
combined_palette <- c(
  pal_nejm()(4),  # NEJM palette with 4 colors
  pal_aaas()(7),  # AAAS palette with 7 colors
  pal_lancet()(7),  # Lancet palette with 7 colors
  pal_jama()(7)    # JAMA palette with 7 colors
)

# Step 4: Create a stacked bar plot of total RPKM by PhaGCN classification (phage families)
stacked_bar_plot_phage <- ggplot(rpkm_summary_phage, aes(x = Sample, y = total_rpkm, fill = PhaGCN)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Total RPKM by Sample and PhaGCN (Phage Families, Excluding Unknown)", x = "Sample", y = "Total RPKM") +
  scale_fill_manual(values = combined_palette) +  # Use the combined palette here
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        text = element_text(family = "Arial"))

# Display the stacked bar plot
print(stacked_bar_plot_phage)

# Step 5: Convert to relative RPKM (proportion of RPKM for each PhaGCN within each Sample)
rpkm_relative_phage <- rpkm_summary_phage %>%
  group_by(Sample) %>%
  mutate(relative_rpkm = total_rpkm / sum(total_rpkm)) %>%
  ungroup()

# Step 6: Create a relative abundance plot of RPKM by PhaGCN classification (phage families)
relative_abundance_plot_phage <- ggplot(rpkm_relative_phage, aes(x = Sample, y = relative_rpkm, fill = PhaGCN)) +
  geom_bar(stat = "identity", position = "fill") +
  labs(title = "Relative RPKM by Sample and PhaGCN (Phage Families, Excluding Unknown)", x = "Sample", y = "Proportion of RPKM") +
  scale_fill_manual(values = combined_palette) +  # Use the combined palette here
  scale_y_continuous(expand = c(0, 0)) +  
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        text = element_text(family = "Arial"))

# Display the relative abundance plot
print(relative_abundance_plot_phage)


# heat map

# Step 3: Pivot the data into a wide format for the heatmap (Samples as columns, PhaGCN as rows)
rpkm_wide <- rpkm_summary_phage %>%
  pivot_wider(names_from = Sample, values_from = total_rpkm, values_fill = 0)

# Step 4: Convert the data frame to a matrix for heatmap generation
rpkm_matrix <- as.matrix(rpkm_wide[,-1])  # Remove the first column (PhaGCN) and convert to matrix
rownames(rpkm_matrix) <- rpkm_wide$PhaGCN  # Set the row names to be the PhaGCN classification

# Step 5: Create a heatmap using ggplot2
rpkm_long <- melt(rpkm_wide, id.vars = "PhaGCN")  # Reshape to long format for ggplot2

heatmap_plot <- ggplot(rpkm_long, aes(x = variable, y = PhaGCN, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red", na.value = "white") +
  labs(title = "Heatmap of Total RPKM by Sample and PhaGCN (Phage Families)", 
       x = "Sample", y = "Phage Family (PhaGCN)", fill = "Total RPKM") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        axis.text.y = element_text(size = 10),
        text = element_text(family = "Arial"))

# Display the heatmap
print(heatmap_plot)


# Step 4: Apply CLR transformation to the wide data
clr_transform <- function(x) {
  gm <- exp(mean(log(x[x > 0]), na.rm = TRUE))  # Geometric mean
  log(x / gm)
}


# Step 4: Handle zeros by adding a pseudocount
# Add a small constant to avoid zeros (pseudocount method)
pseudocount <- min(rpkm_wide[,-1][rpkm_wide[,-1] > 0]) * 0.01  # 1% of the smallest non-zero value
rpkm_wide[,-1] <- rpkm_wide[,-1] + pseudocount  # Add pseudocount to all values

# Step 5: Apply CLR transformation to the wide data
rpkm_matrix <- as.matrix(rpkm_wide[,-1])  # Convert to matrix, removing the PhaGCN column
rpkm_clr <- t(apply(rpkm_matrix, 1, clr_transform))  # Apply CLR transformation row-wise and transpose correctly

# Step 6: Ensure the row names are correctly set to PhaGCN labels
rownames(rpkm_clr) <- rpkm_wide$PhaGCN  # Set the row names to PhaGCN

# Step 7: Create the heatmap with a dendrogram using pheatmap
pheatmap(
  rpkm_clr, 
  clustering_distance_rows = "euclidean",  # Clustering method for rows
  clustering_distance_cols = "euclidean",  # Clustering method for columns
  clustering_method = "complete",  # Hierarchical clustering method
  color = colorRampPalette(c("#B43F3F", "#ECDFCC", "#522258"))(50),  # Color palette
  main = "Heatmap of CLR-Transformed RPKM by Sample and PhaGCN (With Zero Handling)",
  fontsize_row = 8,  # Font size for phage families (rows)
  fontsize_col = 8,  # Font size for samples (columns)
  border_color = NA  # No border between heatmap cells
)



# Diversity indices ####
# Load required libraries
library(vegan)
library(tidyverse)

# Example phage abundance matrix (rows: phage families, columns: samples)
phage_abundance <- as.data.frame(rpkm_wide[,-1])  # Remove the PhaGCN column
rownames(phage_abundance) <- rpkm_wide$PhaGCN  # Set row names to phage family

# Calculate Shannon Diversity Index for each sample
shannon_diversity <- diversity(phage_abundance, index = "shannon")

# Calculate Simpson Diversity Index for each sample
simpson_diversity <- diversity(phage_abundance, index = "simpson")


# View alpha diversity metrics
shannon_diversity
simpson_diversity

# Combine alpha diversity metrics into a data frame
alpha_diversity <- data.frame(
  Sample = colnames(phage_abundance),
  Shannon = shannon_diversity,
  Simpson = simpson_diversity
)

# Visualize Alpha Diversity
alpha_long <- alpha_diversity %>%
  pivot_longer(cols = c("Shannon", "Simpson"), names_to = "Metric", values_to = "Diversity")

# Alpha diversity plot (bar plot)
ggplot(alpha_long, aes(x = Sample, y = Diversity, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Alpha Diversity across Samples", x = "Sample", y = "Diversity") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# Calculate Bray-Curtis Dissimilarity between samples
bray_curtis <- vegdist(phage_abundance, method = "bray")

# Calculate Jaccard Dissimilarity between samples
jaccard_index <- vegdist(phage_abundance, method = "jaccard")

# View beta diversity matrices
bray_curtis
jaccard_index

# Perform PCoA on Bray-Curtis dissimilarity matrix
pcoa_bray <- cmdscale(bray_curtis, eig = TRUE, k = 2)
pcoa_df_bray <- as.data.frame(pcoa_bray$points)
colnames(pcoa_df_bray) <- c("PC1", "PC2")
pcoa_df_bray$Sample <- rownames(pcoa_df_bray)

# Plot Bray-Curtis PCoA
p1 <- ggplot(pcoa_df_bray, aes(x = PC1, y = PC2, label = Sample)) +
  geom_point() +
  geom_text(vjust = -1) +
  labs(title = "PCoA of Bray-Curtis Dissimilarity", x = "PC1", y = "PC2") +
  theme_minimal()

# Perform PCoA on Jaccard dissimilarity matrix
pcoa_jaccard <- cmdscale(jaccard_index, eig = TRUE, k = 2)
pcoa_df_jaccard <- as.data.frame(pcoa_jaccard$points)
colnames(pcoa_df_jaccard) <- c("PC1", "PC2")
pcoa_df_jaccard$Sample <- rownames(pcoa_df_jaccard)

# Plot Jaccard PCoA
p2 <- ggplot(pcoa_df_jaccard, aes(x = V1, y = V2, label = Sample)) +
  geom_point() +
  geom_text(vjust = -1) +
  labs(title = "PCoA of Jaccard Dissimilarity", x = "PC1", y = "PC2") +
  theme_minimal()

# Display both alpha and beta diversity plots
print(p1)
print(p2)
