# Code for analyzing patterns in geographic dataset of Northeast Pacific rockfish,
# genus Sebastes, from data provided by Travis Ingram and used in his 2011 PRSB paper.

# Purpose: To estimate species richness, mean root distance, and phylogenetic species
# variability in each latitudinal bin, and to relate those values to each other.

# Author: Allen Hurlbert

setwd('//bioark.bio.unc.edu/hurlbertallen/manuscripts/cladevscommunity/analyses/sebastes')
require(ape)
require(plyr)
require(picante)

sebastes = read.csv('sebastes_data_for_allen.csv',header=T)
phy = read.tree('Sebastes_tree_Ingram2011PRSB.phy')

lat = min(sebastes$min_latitude, na.rm=T):max(sebastes$max_latitude, na.rm=T)


richness = sapply(lat, function(x) nrow(sebastes[sebastes$min_latitude <= x & sebastes$max_latitude >= x, ]))

phylo.bl1 <- compute.brlen(phy, 1)
all.dist <- dist.nodes(phylo.bl1)
root.dist <- all.dist[length(phy$tip.label)+1, 1:length(phy$tip.label)]
tips.to.root <- data.frame(spp.name=phy$tip.label,root.dist)

output = c()
for (i in lat) {
  species = subset(sebastes, min_latitude <= i & max_latitude >= i, select='X')
  
  #MRD
  MRD.ini <- merge(species, tips.to.root, by.x="X", by.y="spp.name",sort = FALSE)
  MRD <- mean(MRD.ini$root.dist)
  
  #PSV
  Vmatrix = vcv(phy, corr=F)
  psvs = matrix(NA, ncol=2)
  
  index = row.names(Vmatrix) %in% species$X
  v.matrix = Vmatrix[index,index]
  n = nrow(v.matrix)
  psv = (n*sum(diag(v.matrix)) - sum(v.matrix))/(sum(diag(v.matrix))*(n-1))
  
  output = rbind(output, c(i, MRD, psv))
}

output2 = data.frame(cbind(output, richness))
names(output2) = c('lat','MRD','PSV','S')

pdf('sebastes_MRD-PSV_corrs.pdf',height=6,width=8)
plot(lat,richness)
text(45,52,"Entire gradient:\nMRD-S = 0.47\nPSV-S = -0.14")
text(45,40,"North of 34N:\nMRD-S = 0.94\nPSV-S = -0.27")
par(new=T)
plot(lat, output2$MRD, col='blue',xaxt="n",yaxt="n",ylab="", pch=16)
par(new=T)
plot(lat,output2$PSV, col='red',xaxt="n",yaxt="n",ylab="",pch=16)
legend("topright",c('richness','MRD','PSV'),pch=c(1,16,16),col=c('black','blue','red'))
dev.off()


# For Energy Gradient temperate origin,
#   MRD-S correlation predicted to be positive 
#   PSV-S correlation predicted to be negative
cor(output2)

#restricting analysis to north of Point Conception
output3 = output2[output2$lat >= 34,]
cor(output3)