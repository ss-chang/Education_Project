# =====================================================================================
# title:   eda.R
# author:  Jared Wilber
# summary: 
#          Run this script after we created our BESTVALUE and MINORITY variables
#          Plots EDA for our variables, color coded by MINORITY and BESTVALUE
#          Plots:
#                1. PCA (color code for both examples, place side-by-side)          
#                2. Feature Plot (of Minority as x-axis factor)                     
#                3. T-sne (for both)                                                
#                4. Histogram/density of BESTVALUE scores
# =====================================================================================


# Run this script after we created our BESTVALUE and MINORITY variables
# =====================================================================================
# Loading Libraries
# =====================================================================================
library(corrplot)
library(car)
library(corrplot)
library(Rtsne)
library(caret)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(ggfortify)
library(cluster)
library(caret)
library(ggthemr)
library(ape)
library(ggdendro)

# =====================================================================================
# Source script
# =====================================================================================

source("calculate-best-value.R")

# =====================================================================================
# Load data
# =====================================================================================

dat <- dat_3

# data must be numeric for eda
dat_eda <- dat[,-106]

dat_eda <- apply(dat_eda, 2, function(x) as.numeric(x))
dat_eda <- data.frame(dat_eda)


# =====================================================================================
# Analyzing QUALITY_INDEX
# =====================================================================================

hist(dat_eda$QUALITY_INDEX)

# -------------------------------------------------------------------------------------
# save png and pdf
# -------------------------------------------------------------------------------------
dev.copy(png, "../../images/eda/hist-quality-index.png")
dev.off()
dev.copy(pdf, "../../images/eda/hist-quality-index.pdf")
dev.off()


# -------------------------------------------------------------------------------------
# histogram
# -------------------------------------------------------------------------------------
ggthemr('dust')
ggplot(dat_eda, aes(BV_SCORE)) +
  geom_histogram(aes(y=..density..), binwidth = .018) +
  geom_density() +
  ggtitle("Histogram of Best Value")

#save png and pdf
dev.copy(png, "../../images/eda/hist-best-value.png")
dev.off()
dev.copy(pdf, "../../images/eda/hist-best-value.pdf")
dev.off()


# -------------------------------------------------------------------------------------
# histogram
# -------------------------------------------------------------------------------------
ggthemr('dust')
ggplot(dat_eda, aes(ABOVE_MEDIAN_MINORITIES)) +
  geom_histogram(binwidth = .5) +
  ggtitle("Histogram of ABOVE_MEDIAN_MINORITIES")

#save png and pdf
dev.copy(png, "../../images/eda/hist-above-median-minorities.png")
dev.off()
dev.copy(pdf, "../../images/eda/hist-above-median-minorities.pdf")
dev.off()

# -------------------------------------------------------------------------------------
# Boxplots by Region
# -------------------------------------------------------------------------------------
ggplot(dat_eda, aes(as.factor(ABOVE_MEDIAN_MINORITIES),BV_SCORE)) +
  geom_boxplot() + 
  facet_wrap(~ REGION) +
  labs(title="Boxplots of School Value by Minority Count per Region", x="Above Median Minority",
       ylab = "BV_SCORE")

#save png and pdf
dev.copy(png, "../../images/eda/boxplots-school-value-minority-Count-per-region.png")
dev.off()
dev.copy(pdf, "../../images/eda/boxplots-school-value-minority-Count-per-region.pdf")
dev.off()


dat_eda <- dat_eda %>%
  mutate(quantile = ntile(BV_SCORE, 4))

# -------------------------------------------------------------------------------------
# Boxplots by Region
# -------------------------------------------------------------------------------------
ggplot(dat_eda, aes(as.factor(as.numeric(quantile)), MINORITIES)) +
  geom_boxplot() + 
  labs(title="Boxplots of Minority Percentage by Value Quartiles", 
       x="Quartiles of BV_SCORE",
       ylab = "Minority Count")

#save png and pdf
dev.copy(png, "../../images/eda/boxplots-minority-percentage-by-value-quartiles.png")
dev.off()
dev.copy(pdf, "../../images/eda/boxplots-minority-percentage-by-value-quartiles.pdf")
dev.off()

ggthemr_reset()

# =====================================================================================
# Clustering
# =====================================================================================
set.seed(2)

# -------------------------------------------------------------------------------------
# Make random sample so data clusters are visible
# -------------------------------------------------------------------------------------
random_sample_smaller <- sample(1:nrow(dat_eda), 15, replace = FALSE)
dat_for_hclust <- dat_eda[random_sample_smaller,]
rownames(dat_for_hclust) <- dat$INSTNM[random_sample_smaller]

d <- dist(dat_for_hclust)
hc <- hclust(d)

# -------------------------------------------------------------------------------------
# MDS
# -------------------------------------------------------------------------------------
autoplot(cmdscale(d, eig = TRUE), shape=FALSE, label.size = 3, col='tomato')
#save png and pdf
dev.copy(png, "../../images/eda/autoplot.png")
dev.off()
dev.copy(pdf, "../../images/eda/autoplot.pdf")
dev.off()

# =====================================================================================
# Phylo Tree
# =====================================================================================
plot(as.phylo(hc), type = "fan")

#save png and pdf
dev.copy(png, "../../images/eda/phylo-fan.png")
dev.off()
dev.copy(pdf, "../../images/eda/phylo-fan.pdf")

plot(as.phylo(hc), type = "unrooted")

#save png and pdf
dev.copy(png, "../../images/eda/phylo-unrooted.png")
dev.off()
dev.copy(pdf, "../../images/eda/phylo-unrooted.pdf")
dev.off()



# =====================================================================================
# Hierarchical Clustering
# =====================================================================================
plot(hc, cex = 0.7)
ggdendrogram(hc, rotate=T) + theme_solarized()

#save png and pdf
dev.copy(png, "../../images/eda/ggdendrogram.png")
dev.off()
dev.copy(pdf, "../../images/eda/ggdendrogram.pdf")
dev.off()

# =====================================================================================
# PCA
# =====================================================================================

# get data ready for pca
non_zero_var <- as.vector(sapply(dat_eda, function(x) var(x) != 0))
nonzero_columns <- names(dat_eda)[non_zero_var]
cols_to_keep <- names(dat_eda)[names(dat_eda) %in% nonzero_columns]

# perform pca
pca <- prcomp(dat_eda[,cols_to_keep], scale = T)

plot(pca, main="Scree Plot")

#save png and pdf
dev.copy(png, "../../images/pca/scree-plot.png")
dev.off()
dev.copy(pdf, "../../images/pca/scree-plot.pdf")
dev.off()

# =====================================================================================
# PCA for BV_SCORE
# =====================================================================================
autoplot(pca, data=dat_eda, colour = "BV_SCORE", alpha=.95, size=3) + 
  ggtitle("PCA of BV_SCORE") +
  theme_wsj() +
  scale_colour_gradient(limits=c(.04, .37), low="yellow2", high="red", space="Lab")

#save png and pdf
dev.copy(png, "../../images/pca/pca-best-value.png")
dev.off()
dev.copy(pdf, "../../images/pca/pca-best-value.pdf")
dev.off()

# =====================================================================================
# PCA for ABOVE_MEDIAN_MINORITIES
# =====================================================================================
autoplot(pca, data=dat_eda, colour = "ABOVE_MEDIAN_MINORITIES", alpha=.6, size=3, pch=4) + 
  ggtitle("PCA of Minority Enrollment Rate ") +
  theme_wsj() + 
  scale_colour_gradient(limits=c(0, 1), low="goldenrod", high="navyblue", space="Lab") 

#save png and pdf
dev.copy(png, "../../images/pca/pca-enrollment-rate-minority.png")
dev.off()
dev.copy(pdf, "../../images/pca/pca-enrollment-rate-minority.pdf")
dev.off()

# =====================================================================================
# Feature Plot:  See how minor_bin column relates to all other features
# =====================================================================================
featurePlot(dat_eda, as.factor(dat_eda$ABOVE_MEDIAN_MINORITIES), "strip")
#save png and pdf
dev.copy(png, "../../images/pca/feature-plot.png")
dev.off()
dev.copy(pdf, "../../images/pca/feature-plot.pdf")
dev.off()


# =====================================================================================
# t-sne Plot
# =====================================================================================

# t-Distributed Stochastic Neighbor Embedding
set.seed(420) 

# t-SNE for BV_SCORE
tsne = Rtsne(as.matrix(dat_eda), check_duplicates=FALSE, pca=TRUE, 
             perplexity=30, theta=0.3, dims=2)

embedding = as.data.frame(tsne$Y)
embedding$Class = dat_eda$BV_SCORE
g = ggplot(embedding, aes(x=V1, y=V2, color=Class)) +
  theme(plot.title = element_text(lineheight=2, face="bold"))+
  geom_point(size=2, alpha=1, shape=19) +
  guides(colour=guide_legend(override.aes=list(size=6))) +
  xlab("") + ylab("") +
  ggtitle("t-SNE 2D Embedding of School Value") +
  theme_light(base_size=20) +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank()) + 
  theme_solarized() +
  scale_colour_gradient(limits=c(.04, .37), low="yellow", high="red", space="Lab")
print(g)

#save png and pdf
dev.copy(png, "../../images/pca/tsne-best-value.png")
dev.off()
dev.copy(pdf, "../../images/pca/tsne-best-value.pdf")
dev.off()


# -------------------------------------------------------------------------------------
# t-SNE for ABOVE_MEDIAN_MINORITIES
# -------------------------------------------------------------------------------------
tsne = Rtsne(as.matrix(dat_eda), check_duplicates=FALSE, pca=TRUE, 
             perplexity=30, theta=0.3, dims=3)

embedding = as.data.frame(tsne$Y)
embedding$Class = dat_eda$ABOVE_MEDIAN_MINORITIES
g = ggplot(embedding, aes(x=V1, y=V2, color=Class)) +
  theme(plot.title = element_text(lineheight=2, face="bold"))+
  geom_point(size=2, alpha=1, shape=19) +
  guides(colour=guide_legend(override.aes=list(size=6))) +
  xlab("") + ylab("") +
  ggtitle("t-SNE 2D Embedding of Minority Count") +
  theme_light(base_size=20) +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank()) + 
  theme_solarized() 
print(g)

dev.copy(png, "../../images/pca/tsne-above-median-minorities.png")
dev.off()
dev.copy(pdf, "../../images/pca/tsne-above-median-minorities.pdf")
dev.off()

# these classes look like they can be easily classified, so we'll opt for a classification method

# =====================================================================================
# Correlation Plot
# =====================================================================================
set.seed(56)
corrplot.mixed(cor(dat_eda[,sample(108,5, replace=F)]), upper="color", 
               tl.pos="lt", diag="n", order="hclust", hclust.method="complete")

#save png and pdf
dev.copy(png, "../../images/eda/corrplot-eda.png")
dev.off()
dev.copy(pdf, "../../images/eda/corrplot-eda.pdf")
dev.off()

# Variables are fairly correlated. We can either fix this or opt for a method that can handle
# correlation easy.
# We'll go with the latter and choose xgboost

