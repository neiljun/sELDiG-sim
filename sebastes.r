# Code for analyzing patterns in geographic dataset of Northeast Pacific rockfish,
# genus Sebastes, from data provided by Travis Ingram and used in his 2011 PRSB paper.

# Purpose: To estimate species richness, mean root distance, and phylogenetic species
# variability in each latitudinal bin, and to relate those values to each other.

# Author: Allen Hurlbert

setwd('//bioark.bio.unc.edu/hurlbertallen/manuscripts/cladevscommunity/analyses/sebastes')
require(ape)
require(plyr)
require(picante)
require(caper) #for clade.members()

sebastes = read.csv('sebastes_data_for_allen.csv',header=T)
phy = read.tree('Sebastes_tree_Ingram2011PRSB.phy')

lat = min(sebastes$min_latitude, na.rm=T):max(sebastes$max_latitude, na.rm=T)

##############################################################################
# MRD-PSV-Richness analyses
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

############################################################################
#Gamma plot

Allen = 1;

if (Allen ==1) {
  
  sim_dir = "C:/SENCoutput/senc_reps_analysis"
  analysis_dir = "//bioark.bio.unc.edu/hurlbertallen/manuscripts/cladevscommunity/analyses/"
  repo_dir = "C:/Documents and Settings/Hurlbert/species-energy-simulation"
  
}

if (Allen == 0) {
  
  sim_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/sims.out.130204"
  analysis_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/sims.out.130204"
  repo_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/species-energy-simulation"  
  
}

Ttrop = read.csv(paste(sim_dir,'/SENC_Stats_T.sims.trop.csv',sep=''), header=T)
Ktrop = read.csv(paste(sim_dir,'/SENC_Stats_K.sims.trop.csv',sep=''), header=T)
Ktrop.slice = read.csv(paste(sim_dir,'/SENC_Stats_K.slice.sims.trop.csv',sep=''), header=T)

Ktemp = read.csv(paste(sim_dir,'/SENC_Stats_K.sims.temp.csv',sep=''), header=T)
Ktemp.slice = read.csv(paste(sim_dir,'/SENC_Stats_K.slice.sims.temp.csv',sep=''), header=T)

Tline = 'olivedrab3'
Kline = 'mediumorchid2'
Kline.slice = 'goldenrod2'

#Sebastes phylogeny has 99 species, so pull out clades for each scenario of roughly the same size
Ttrop99 = subset(Ttrop, clade.richness > 90 & clade.richness < 110)
Ktrop99 = subset(Ktrop, clade.richness > 90 & clade.richness < 110)
Ktrop.slice99 = subset(Ktrop.slice, clade.richness > 90 & clade.richness < 110)
Ktemp99 = subset(Ktemp, clade.richness > 90 & clade.richness < 110)
Ktemp.slice99 = subset(Ktemp.slice, clade.richness > 90 & clade.richness < 110)

pdf(paste(analysis_dir, '/sebastes/sebastes_gamma.pdf', sep=''), height = 6, width = 8)
plot(density(Ttrop99$gamma.stat), col=Tline, main="", xlab="Gamma", lwd=3, xlim = c(-8,2))
points(density(Ktrop99$gamma.stat), type='l',col=Kline, lty='dotted',lwd=3)
points(density(Ktemp99$gamma.stat), type='l',col=Kline, lwd=3)
abline(v = gammaStat(phy), lwd=2, lty='dashed')
legend("topleft",c('no zero-sum constraint','zero-sum w/ tropical origin', 'zero-sum w/ temperate origin', 'observed gamma'),
       col = c(Tline, Kline, Kline, 'black'), lty = c('solid', 'dotted', 'solid', 'dashed'), lwd=3)
dev.off()


#points(density(Ktrop.slice99$gamma.stat), col=Kline.slice, lty='dotted', lwd=2)
#points(density(Ktemp.slice99$gamma.stat), col=Kline.slice, lwd=2)

#############################################################################
#Plotting depth range on phylogeny
sebastes$mean_depth = apply(sebastes[,c('min_common_depth','max_common_depth')], 1, function(x) mean(x, na.rm=T))
depth.col = colorRampPalette(colors()[c(405,431,616,619,566)]) #dark blue = deep, light blue = shallow

plot(phy)
#reflect continuous depth
tiplabels(pch=15,col = depth.col(100)[floor(100*sebastes$mean_depth/max(sebastes$mean_depth, na.rm=T))], adj=4, cex=1.25)
#reflect categorical shallow/deep
depth.threshold = 180
sebastes$shde.col[sebastes$mean_depth < depth.threshold] = colors()[405]
sebastes$shde.col[sebastes$mean_depth >= depth.threshold] = colors()[566]
tiplabels(pch=15,col = sebastes$shde.col, adj=4.2, cex=1.25)  


##############################################################################
# Subclade correlations

#Drop non-NEP species (with no latitude data)
nonNEPsp = as.character(sebastes[is.na(sebastes$min_latitude), 'X'])
NEPphy = drop.tip(phy,nonNEPsp)
min.num.spp = 5

lat.corr.output = c()
for (c in (NEPphy$Nnode+2):max(NEPphy$edge)) {
  
  #pull out list of species names belonging to each subclade
  sub.clade = clade.members(c, NEPphy, tip.labels=T)
  sub.populations = subset(sebastes, X %in% sub.clade);
  
  sub.richness = sapply(lat, function(x) nrow(sub.populations[sub.populations$min_latitude <= x & sub.populations$max_latitude >= x, ]))
  if(length(sub.clade) >= min.num.spp) {
    lat.corr = cor(lat[sub.richness>0], sub.richness[sub.richness>0])
    lat.corr2 = cor(lat[sub.richness>0 & lat >= 34], sub.richness[sub.richness > 0 & lat >=34])
    lat.corr.output = rbind(lat.corr.output, c(c, length(sub.clade), lat.corr, lat.corr2))
  }
}
lat.corr.output = data.frame(lat.corr.output)
names(lat.corr.output) = c('cladeID','clade.richness','r.lat.rich','r.lat.rich34')  
# Correlations calculated from entire gradient (Alaska-to Baja), and for the gradient
# north of 34N (Alaska-Point Conception)

pdf(paste(analysis_dir,'/sebastes/sebastes_corrplot.pdf',sep=''),height=6,width=6)
par(mar=c(4,4,1,1))
plot(log10(lat.corr.output$clade.richness), lat.corr.output$r.lat.rich, ylim = c(-1,1), 
     xlab = expression(paste(plain(log)[10]," Clade Richness")),ylab = 'Latitude-richness correlation')
points(log10(lat.corr.output$clade.richness), lat.corr.output$r.lat.rich34, pch=17)
abline(h=0,lty='dashed')
legend("topright", c('Entire gradient','North of 34N'), pch = c(1,17))
dev.off()
