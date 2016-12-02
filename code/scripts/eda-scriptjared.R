# Run this script after we created our BESTVALUE and MINORITY variables


# What this script does
# Plots EDA for our variables, color coded by MINORITY and BESTVALUE
# Plots:
#   1. PCA (color code for both examples, place side-by-side)          done
#   2. Feature Plot (of Minority as x-axis factor)                     done
#   3. T-sne (for both)                                                done
#   4. Histogram/density of BESTVALUE scores


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

# =====================================================================================
# loading data
# =====================================================================================

# select file to load
setwd("~/Desktop/Education_Project/")

# read in your file, call it "dat"
dat     <- read.csv("complete-data.csv", row.names = 1)

# data must be numeric for eda
dat_eda <- dat[,-106]
dat_eda <- apply(dat_eda, 2, function(x) as.numeric(x))
dat_eda <- data.frame(dat_eda)


# =====================================================================================
# Analyzing QUALITY_INDEX
# =====================================================================================

hist(dat_eda$QUALITY_INDEX)



# Histogram
ggthemr('dust')
ggplot(dat_eda, aes(QUALITY_INDEX)) +
  geom_histogram(aes(y=..density..), binwidth = .018) +
  geom_density() +
  ggtitle("Histogram of QUALITY_INDEX")

# Histogram
ggthemr('dust')
ggplot(dat_eda, aes(ABOVE_MEDIAN_MINORITIES)) +
  geom_histogram(binwidth = .5) +
  ggtitle("Histogram of ABOVE_MEDIAN_MINORITIES")


# Boxplots by Region
ggplot(dat_eda, aes(as.factor(ABOVE_MEDIAN_MINORITIES),QUALITY_INDEX)) +
  geom_boxplot() + 
  facet_wrap(~ REGION) +
  labs(title="Boxplots of Quality by Minority Count per Region", x="Above Median Minority",
       ylab = "Quality_Index")


dat_eda <- dat_eda %>%
  mutate(quantile = ntile(QUALITY_INDEX, 4))
# Boxplots by Region
ggplot(dat_eda, aes(as.factor(as.numeric(quantile)), MINORITIES)) +
  geom_boxplot() + 
  labs(title="Boxplots of Minority Percentage by Value Quartiles", 
       x="Quartiles of Quality_Index",
       ylab = "Minority Count")

ggthemr_reset()

# =====================================================================================
# CLUSTERING
# =====================================================================================
set.seed(2)
cali <- grep("University of California-", dat$INSTNM)
dat_cali <- dat_eda[cali,]
random_sample_smaller <- sample(1:nrow(dat), 10, replace = FALSE)
dat_for_hclust <- dat_eda[random_sample_smaller,]
rownames(dat_for_hclust) <- dat$INSTNM[random_sample_smaller]

rownames(dat_cali) <- as.character(dat$INSTNM[cali])
d <- dist(dat_cali)
hc <- hclust(d)


# MDS
autoplot(cmdscale(d, eig = TRUE), shape=FALSE, label.size = 2.6, col='tomato')

# PHYLOGENIX TREE
mypal = c("#fdae61","#a6d96a","#1a9641")
# cutting dendrogram in 5 clusters
clus5 = cutree(hc, 3)
# plot
op = par(bg = "#ffffbf")
# Size reflects miles per gallon
plot(as.phylo(hc), type = "fan", tip.color = mypal[clus5], label.offset = 1, 
     cex = 1, col = "red")
plot(as.phylo(hc), type = "unrooted")
# HIERARCHICAL CLUSTERING
plot(hc, cex = 0.7)


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

# PCA for QUALITY_INDEX
autoplot(pca, data=dat_eda, colour = "QUALITY_INDEX", alpha=.95, size=3) + 
  ggtitle("PCA of QUALITY_INDEX") +
  theme_wsj() +
  scale_colour_gradient(limits=c(0, 1), low="yellow2", high="red", space="Lab")

# PCA for ABOVE_MEDIAN_MINORITIES
autoplot(pca, data=dat_eda, colour = "ABOVE_MEDIAN_MINORITIES", alpha=.6, size=3, pch=4) + 
  ggtitle("PCA of Minority Enrollment Rate ") +
  theme_wsj() + 
  scale_colour_gradient(limits=c(0, 1), low="goldenrod", high="navyblue", space="Lab") 



# =====================================================================================
# Feature Plot:
# See how minor_bin column relates to all other features
# =====================================================================================
featurePlot(dat_eda, as.factor(dat_eda$ABOVE_MEDIAN_MINORITIES), "strip")



# =====================================================================================
# t-sne Plot:
# =====================================================================================

# t-Distributed Stochastic Neighbor Embedding
set.seed(420)

# t-SNE for QUALITY_INDEX
tsne = Rtsne(as.matrix(dat_eda), check_duplicates=FALSE, pca=TRUE, 
             perplexity=30, theta=0.3, dims=2)

embedding = as.data.frame(tsne$Y)
embedding$Class = dat_eda$QUALITY_INDEX
g = ggplot(embedding, aes(x=V1, y=V2, color=Class)) +
  theme(plot.title = element_text(lineheight=2, face="bold"))+
  geom_point(size=2, alpha=1, shape=19) +
  guides(colour=guide_legend(override.aes=list(size=6))) +
  xlab("") + ylab("") +
  ggtitle("t-SNE 2D Embedding of School Quality") +
  theme_light(base_size=20) +
  theme(axis.text.x=element_blank(),
        axis.text.y=element_blank()) + 
  theme_solarized() +
  scale_colour_gradient(limits=c(0, 1), low="yellow", high="red", space="Lab")
print(g)



# t-SNE for ABOVE_MEDIAN_MINORITIES
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

# these classes look like they can be easily classified, so we'll opt for a classification method









# =====================================================================================
# Correlation Plot
# =====================================================================================
set.seed(54)
corrplot.mixed(cor(dat_eda[,sample(108,15, replace=F)]), upper="color", 
               tl.pos="lt", diag="n", order="hclust", hclust.method="complete")

# Variables are fairly correlated. We can either fix this or opt for a method that can handle
# correlation easy.
# We'll go with the latter and choose xgboost

