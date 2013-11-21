# Plot boxplots of gamma (phylogenetic tree shape statistic) across 3 scenarios
# (K gradient, disturbance gradient, or no limit) and 2 regions of origin.

Allen = 0;

if (Allen ==1) {
  
  sim_dir = "C:/SENCoutput"
  analysis_dir = "//bioark.bio.unc.edu/hurlbertallen/manuscripts/cladevscommunity/analyses/"
  repo_dir = "C:/Documents and Settings/Hurlbert/species-energy-simulation"

}

if (Allen == 0) {
  
  sim_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/sims.out.130204"
  analysis_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/sims.out.130204"
  repo_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/species-energy-simulation"  
  
}

  
sim.matrix = read.csv(paste(repo_dir,'/SENC_Master_Simulation_Matrix.csv',sep=""),header=T)

new=0 # 0 for old plot using only 10 reps, 1 for new plot using all 100 reps

# Scenarios
if(new) { #old assignment using all 100 reps
dist.tr = subset(sim.matrix, max.K==22000 & reg.of.origin=='tropical')
dist.te = subset(sim.matrix, max.K==22000 & reg.of.origin=='temperate')
Kgrad.tr = subset(sim.matrix, w==3 & sigma_E==1 & max.K==40000 & alpha==1e-6 & beta==1e-4 & disturb_frequency==0
                  & reg.of.origin=='tropical' & carry.cap=='on' & energy.gradient=='on' & max.richness==10000)
Kgrad.te = subset(sim.matrix, w==3 & sigma_E==1 & max.K==40000 & alpha==1e-6 & beta==1e-4 & disturb_frequency==0
                  & reg.of.origin=='temperate' & carry.cap=='on' & energy.gradient=='on' & max.richness==10000)
NoLim.tr = subset(sim.matrix, w==3 & sigma_E==1 & max.K==40000 & alpha==1e-6 & beta==1e-4 & disturb_frequency==0
                  & reg.of.origin=='tropical' & carry.cap=='off' & energy.gradient=='off' & max.richness==10000)
NoLim.te = subset(sim.matrix, w==3 & sigma_E==1 & max.K==40000 & alpha==1e-6 & beta==1e-4 & disturb_frequency==0
                  & reg.of.origin=='temperate' & carry.cap=='off' & energy.gradient=='off' & max.richness==10000)
}

if(new==0) {
dist.tr = subset(sim.matrix, sim.id %in% 3445:3454)
dist.te = subset(sim.matrix, sim.id %in% 3455:3464)
Kgrad.tr = subset(sim.matrix, sim.id %in% 3325:3334)
Kgrad.te = subset(sim.matrix, sim.id %in% 3345:3354)
NoLim.tr = subset(sim.matrix, sim.id %in% 3365:3374)
NoLim.te = subset(sim.matrix, sim.id %in% 3385:3394)
}

# Function rbinds together latitudinal richness gradient data across specified simulations from the most recent timestep
recent.lat.grad = function(sim.ids,cut.ends=T) {
  latgrad.sim.reps = c()
  for (i in sim.ids) {
    tmp = read.csv(paste(sim_dir,'/SENC_time.rich_sim',i,'.csv',sep=''), header=T)
    max.time = max(tmp$time)
    tmp2 = tmp[tmp$time==max.time,]
    tmp2$max.time = max.time
    tmp2$sim = i
    latgrad.sim.reps = rbind(latgrad.sim.reps, tmp2)
  }  
  if(cut.ends) { latgrad.sim.reps = subset(latgrad.sim.reps, region %in% 1:10)} #eliminate regions 0 and 11 from output
  return(latgrad.sim.reps)
}

old.lat.grad = function(sim.ids, time, cut.ends = T) {
  latgrad.sim.reps = c()
  for (i in sim.ids) {
    tmp = read.csv(paste(sim_dir,'/SENC_time.rich_sim',i,'.csv',sep=''), header=T)
    tmp2 = tmp[tmp$time==time,]
    tmp2$time = time
    tmp2$sim = i
    latgrad.sim.reps = rbind(latgrad.sim.reps, tmp2)
  }  
  if(cut.ends) { latgrad.sim.reps = subset(latgrad.sim.reps, region %in% 1:10)} #eliminate regions 0 and 11 from output
  return(latgrad.sim.reps)
}

latgrad.dist.tr = recent.lat.grad(dist.tr$sim.id)
latgrad.dist.te = recent.lat.grad(dist.te$sim.id)
latgrad.Kgrad.tr = recent.lat.grad(Kgrad.tr$sim.id)
latgrad.Kgrad.te = recent.lat.grad(Kgrad.te$sim.id)
latgrad.NoLim.tr = recent.lat.grad(NoLim.tr$sim.id)
latgrad.NoLim.te = recent.lat.grad(NoLim.te$sim.id)

oldgrad.dist.tr = old.lat.grad(dist.tr$sim.id, time = 2000)
oldgrad.dist.te = old.lat.grad(dist.te$sim.id, time = 2000)
oldgrad.Kgrad.tr = old.lat.grad(Kgrad.tr$sim.id, time = 5459)
oldgrad.Kgrad.te = old.lat.grad(Kgrad.te$sim.id, time = 5459)
oldgrad.NoLim.tr = old.lat.grad(NoLim.tr$sim.id, time = 140)
oldgrad.NoLim.te = old.lat.grad(NoLim.te$sim.id, time = 140)

plot.disturbance = 0; # toggle to turn disturbance scenario on or off

if (plot.disturbance == 1) {pdf(paste(analysis_dir,'/summaryplots/3scenarios_lat_grads',Sys.Date(),'.pdf',sep=''), height = 3, width = 8) ; par(mfrow=c(1,3), mar = c(2,5,2,0), oma = c(1,0,1,1))}
if (plot.disturbance == 0) {pdf(paste(analysis_dir,'/summaryplots/3scenarios_lat_grads',Sys.Date(),'.pdf',sep=''), height = 3, width = 7) ; par(mfrow=c(1,2), mar = c(2,5,2,0), oma = c(1,0,1,1))}

## Time scenario
plot(c(1,10),c(0,1.1*max(latgrad.NoLim.tr$spp.rich)),type="n",xlab="",ylab="Species Richness", 
     main="Time",cex.lab=1.25, cex.main=1.25, xaxt="n")
mtext("Tropics",1,adj=.05,line=.5, cex=.8)
mtext("Temperate",1,adj=.95,line=.5, cex=.8)

#recent gradient
sapply(NoLim.tr$sim.id, function(x)
       points(11 - latgrad.NoLim.tr[latgrad.NoLim.tr$sim==x,'region'], 
              latgrad.NoLim.tr[latgrad.NoLim.tr$sim==x,'spp.rich'], 
              type = 'l', lwd=2, col = 'red'))
sapply(NoLim.te$sim.id, function(x)
  points(11 - latgrad.NoLim.te[latgrad.NoLim.te$sim==x,'region'], 
         latgrad.NoLim.te[latgrad.NoLim.te$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'blue'))
#old gradient
sapply(NoLim.tr$sim.id, function(x)
  points(11 - oldgrad.NoLim.tr[oldgrad.NoLim.tr$sim==x,'region'], 
         oldgrad.NoLim.tr[oldgrad.NoLim.tr$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'pink', lty='dashed'))
sapply(NoLim.te$sim.id, function(x)
  points(11 - oldgrad.NoLim.te[oldgrad.NoLim.te$sim==x,'region'], 
         oldgrad.NoLim.te[oldgrad.NoLim.te$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'light blue', lty='dashed'))

if (plot.disturbance == 1) {

## Disturbance scenario
plot(c(1,10),c(0,1.1*max(latgrad.dist.tr$spp.rich)),type="n",xlab="",
     ylab="", main="Disturbance",cex.lab=1.5, xaxt="n")
mtext("Tropics",1,adj=.05,line=.5, cex=.8)
mtext("Temperate",1,adj=.95,line=.5, cex=.8)

#recent gradient
sapply(dist.tr$sim.id, function(x)
  points(11 - latgrad.dist.tr[latgrad.dist.tr$sim==x,'region'], 
         latgrad.dist.tr[latgrad.dist.tr$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'red'))
sapply(dist.te$sim.id, function(x)
  points(11 - latgrad.dist.te[latgrad.dist.te$sim==x,'region'], 
         latgrad.dist.te[latgrad.dist.te$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'blue'))

#old gradient
sapply(dist.tr$sim.id, function(x)
  points(11 - oldgrad.dist.tr[oldgrad.dist.tr$sim==x,'region'], 
         oldgrad.dist.tr[oldgrad.dist.tr$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'pink', lty='dashed'))
sapply(dist.te$sim.id, function(x)
  points(11 - oldgrad.dist.te[oldgrad.dist.te$sim==x,'region'], 
         oldgrad.dist.te[oldgrad.dist.te$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'light blue', lty='dashed'))

} # close if statement related to plotting disturbance scenario

## K gradient scenario
plot(c(1,10),c(0,1.1*max(latgrad.Kgrad.tr$spp.rich)),type="n",xlab="",
     ylab="", main="Energy Gradient",cex.lab=1.5, xaxt="n")
mtext("Tropics",1,adj=.05,line=.5, cex=.8)
mtext("Temperate",1,adj=.95,line=.5, cex=.8)

#recent gradient
sapply(Kgrad.tr$sim.id, function(x)
  points(11 - latgrad.Kgrad.tr[latgrad.Kgrad.tr$sim==x,'region'], 
         latgrad.Kgrad.tr[latgrad.Kgrad.tr$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'red'))
sapply(Kgrad.te$sim.id, function(x)
  points(11 - latgrad.Kgrad.te[latgrad.Kgrad.te$sim==x,'region'], 
         latgrad.Kgrad.te[latgrad.Kgrad.te$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'blue'))

#old gradient
sapply(Kgrad.tr$sim.id, function(x)
  points(11 - oldgrad.Kgrad.tr[oldgrad.Kgrad.tr$sim==x,'region'], 
         oldgrad.Kgrad.tr[oldgrad.Kgrad.tr$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'pink', lty='dashed'))
sapply(Kgrad.te$sim.id, function(x)
  points(11 - oldgrad.Kgrad.te[oldgrad.Kgrad.te$sim==x,'region'], 
         oldgrad.Kgrad.te[oldgrad.Kgrad.te$sim==x,'spp.rich'], 
         type = 'l', lwd=2, col = 'light blue', lty='dashed'))

#legend
legend("topright",c('temperate origin','tropical origin','mid-simulation','end of simulation'), lwd = 1.5,
       col = c('blue','red','gray60','black'), lty=c('solid','solid','dashed','solid'),cex=0.5)
dev.off()