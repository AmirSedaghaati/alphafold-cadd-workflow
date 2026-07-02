# Installing and activating the graphics package
install.packages("ggplot2")
library(ggplot2)

print("Starting visualization process...")

# --- Chart 1: Drug binding propensity ranking ---
df_binding <- read.csv("results/binding_results.csv")

p1 <- ggplot(df_binding, aes(x=reorder(Compound, Binding_Affinity), y=Binding_Affinity, fill=Lipinski_Pass)) +
  geom_bar(stat="identity", width=0.5, color="black") +
  coord_flip() + 
  scale_fill_manual(values=c("Yes"="#4CAF50", "No"="#F44336")) +
  labs(title="Binding Affinity of Compounds to TREM2",
       subtitle="More negative values indicate stronger binding",
       x="Compound", 
       y="Binding Affinity (kcal/mol)",
       fill="Lipinski Pass") +
  theme_minimal(base_size = 14)

ggsave("plot_binding_affinity.png", plot=p1, width=8, height=4, dpi=300)
print("1. 'plot_binding_affinity.png' saved.")

# --- Second chart: Measuring the quality of the Alphafold structure ---
df_af <- read.csv("results/alphafold_confidence.csv")

p2 <- ggplot(df_af, aes(x=Residue, y=Confidence_pLDDT)) +
  geom_line(color="#2196F3", size=0.8) +
  geom_hline(yintercept=70, linetype="dashed", color="#F44336", size=1) +
  annotate("text", x=max(df_af$Residue)*0.8, y=73, label="Confidence Threshold (>70)", color="#F44336") +
  labs(title="AlphaFold Prediction Confidence (pLDDT) per Residue",
       subtitle="Scores above 70 indicate good structural confidence",
       x="Residue Number", 
       y="pLDDT Score") +
  theme_minimal(base_size = 14)

ggsave("plot_alphafold_confidence.png", plot=p2, width=10, height=4, dpi=300)
print("2. 'plot_alphafold_confidence.png' saved.")