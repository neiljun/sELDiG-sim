## code for relating various metrics of the root clade to time and making plots
require(abind)



Allen = 0;

#New parameter for taking into account which of us is running this code
if(Allen==1) {
  setwd('c:/documents and settings/hurlbert/species-energy-simulation')
  sim_dir = "C:/SENCoutput/longtime_reps"
  analysis_dir = "//bioark.bio.unc.edu/hurlbertallen/manuscripts/cladevscommunity/analyses/summaryplots"
} else {
  setwd('C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/species-energy-simulation')
  sim_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/sims.out.130204" #wherever all of your zipped output files are
  analysis_dir = "C:/Users/steg815/Desktop/Stegen_PNNL/Spp-Energy-Niche-Conserv/sims.out.130204" #wherever you want to store the results of these analyses
}

#Energy gradient sims
# currently has 100 sims
trop.sims = c(4065:4074, 4185:4274)
temp.sims = c(4075:4084, 4275:4364)

#No energy gradient sims
# currently has 100 sims
Ttrop.sims = 3465:3564
Ttemp.sims = c(3565:3646,3648:3664)

# next 5 lines are temporary
#run.sims = list.files(path = "//constance/people/steg815/senc.analysis", pattern='_time_seq_root_only.csv');
#run.sims = sub('SENC_Stats_sim','',run.sims);
#run.sims = as.numeric(sub('_time_seq_root_only.csv','',run.sims)); head(run.sims);
#Ttrop.sims = run.sims[run.sims <= 3564]; length(Ttrop.sims);
#Ttemp.sims = run.sims[run.sims >= 3565]; length(Ttemp.sims);

sim.matrix = read.csv("SENC_Master_Simulation_Matrix.csv",header=T);

metric.abind = function(sims, scenario = "K", min.n.regions = 4, min.richness = 30) {
  metrics = matrix(NA, nrow = 100, ncol = 28)
  for (i in sims) {
    if (scenario == "K") {
      temp = read.csv(paste(sim_dir,"/SENC_Stats_sim",i,"_mult_times.csv",sep=""),header=T)
    } else if (scenario == "T") {
      temp = read.csv(paste(sim_dir,"/SENC_Stats_sim",i,"_time_seq_root_only.csv",sep=""),header=T)
    }
    temp$r.lat.rich = -temp$r.env.rich
    # There is no output for timesteps in which no correlations could be calculated
    # so we add the relevant number of rows of data with NA's in that case
    if (nrow(temp) < 100) {
      temp.top = data.frame(matrix(NA, nrow = 100 - nrow(temp), ncol = 28))
      names(temp.top) = names(temp)
      temp = rbind(temp.top, temp)
    }
    # Only include metrics in analysis if simulation meets minimum region and richness criteria
    if (min(temp$n.regions, na.rm = T) < min.n.regions) {
      temp[which(temp$n.regions < min.n.regions),] = NA
    }
    if (min(temp$global.richness, na.rm = T) < min.richness) {
      temp[which(temp$global.richness < min.richness),] = NA
    }
    metrics = abind(metrics, temp, along = 3)
  }
  return(metrics[,,-1]) #don't include the first slice of NAs
}

metric.abind.new = function(sims, scenario = "K", min.div.regions = 4, min.richness = 30) {
  metrics = matrix(NA, nrow = 100, ncol = 39)
  for (i in sims) {
    #if (scenario == "K") {
    #  temp = read.csv(paste(sim_dir,"/NEW_Stats_sim",i,"_mult_times.csv",sep=""),header=T)
    #} else if (scenario == "T") {
      temp = read.csv(paste(sim_dir,"/NEW_Stats_sim",i,"_time_seq_root_only.csv",sep=""),header=T)
    #}
    temp$r.lat.rich = -temp$r.env.rich
    # There is no output for timesteps in which no correlations could be calculated
    # so we add the relevant number of rows of data with NA's in that case
    if (nrow(temp) < 100) {
      temp.top = data.frame(matrix(NA, nrow = 100 - nrow(temp), ncol = 39))
      names(temp.top) = names(temp)
      temp = rbind(temp.top, temp)
    }
    # Only include metrics in analysis if simulation meets minimum region and richness criteria
    if (min(temp$n.div.regions, na.rm = T) < min.div.regions) {
      temp[which(temp$n.div.regions < min.div.regions),] = NA
    }
    if (min(temp$global.richness, na.rm = T) < min.richness) {
      temp[which(temp$global.richness < min.richness),] = NA
    }
    metrics = abind(metrics, temp, along = 3)
    #print(c(i,range(temp$global.richness,na.rm=T),range(temp$n.div.regions,na.rm=T)))
  }
  return(metrics[,,-1]) #don't include the first slice of NAs
}

min.num.regions = 5
min.num.div.regions = 5
min.global.richness = 30

temp.metrics = metric.abind.new(temp.sims, scenario = "K", min.div.regions = min.num.div.regions, min.richness = min.global.richness)
trop.metrics = metric.abind.new(trop.sims, scenario = "K", min.div.regions = min.num.div.regions, min.richness = min.global.richness)
Ttemp.metrics = metric.abind.new(Ttemp.sims, scenario = "T", min.div.regions = min.num.div.regions, min.richness = min.global.richness)
Ttrop.metrics = metric.abind.new(Ttrop.sims, scenario = "T", min.div.regions = min.num.div.regions, min.richness = min.global.richness)

#Function for calculating mean or SD for simulations with a minimum number of non-NA values at a given time step
calc.meanSD = function(x, stat = 'mean', min.num.nonNA = 10) {
  if (stat == 'mean') {
    if(sum(!is.na(x)) >= min.num.nonNA) {
      mean(x, na.rm = T)
    } else { NA }
  } else if (stat == 'sd') {
    if(sum(!is.na(x)) >= min.num.nonNA) {
      var(x, na.rm = T)^0.5
    } else { NA }
  }
}

min.num.datapts = 10

temp.metrics.mean = data.frame(apply(temp.metrics, 1:2, function(x) calc.meanSD(x, stat = 'mean', min.num.nonNA = min.num.datapts)))
temp.metrics.sd = data.frame(apply(temp.metrics, 1:2, function(x) calc.meanSD(x, stat = 'sd', min.num.nonNA = min.num.datapts)))

trop.metrics.mean = data.frame(apply(trop.metrics, 1:2, function(x) calc.meanSD(x, stat = 'mean', min.num.nonNA = min.num.datapts)))
trop.metrics.sd = data.frame(apply(trop.metrics, 1:2, function(x) calc.meanSD(x, stat = 'sd', min.num.nonNA = min.num.datapts)))

Ttemp.metrics.mean = data.frame(apply(Ttemp.metrics, 1:2, function(x) calc.meanSD(x, stat = 'mean', min.num.nonNA = min.num.datapts)))
Ttemp.metrics.sd = data.frame(apply(Ttemp.metrics, 1:2, function(x) calc.meanSD(x, stat = 'sd', min.num.nonNA = min.num.datapts)))

Ttrop.metrics.mean = data.frame(apply(Ttrop.metrics, 1:2, function(x) calc.meanSD(x, stat = 'mean', min.num.nonNA = min.num.datapts)))
Ttrop.metrics.sd = data.frame(apply(Ttrop.metrics, 1:2, function(x) calc.meanSD(x, stat = 'sd', min.num.nonNA = min.num.datapts)))

metric.names = c('global.richness',
                 'r.lat.rich', 
                 'gamma.stat',
                 'r.env.PSV', 
                 'r.env.MRD', 
                 'r.MRD.rich',
                 'r.PSV.rich',
                 'MRD.rich.slope',
                 'MRD.env.slope',
                 'PSV.rich.slope',
                 'PSV.env.slope'
)
metric.labels = c('Global richness', 
                  expression(italic(r)[latitude-richness]), 
                  expression(gamma), 
                  expression(italic(r)[env-PSV]),
                  expression(italic(r)[env-MRD]), 
                  expression(italic(r)[MRD-richness]),
                  expression(italic(r)[PSV-richness]),
                  'MRD-Richness slope',
                  'MRD-Environment slope',
                  'PSV-Richness slope',
                  'PSV-Environment slope')


# Plot 4 metrics over the course of the simulation: global richness, the latitude-richness correlation, 
# gamma, and the MRD-richness correlation. Means +/- 2 SD are shown.
pdf(paste(analysis_dir,'/metrics_thru_time_inc_Tscenario',Sys.Date(),'_',min.num.regions,'.pdf',sep=""), height = 6, width = 8)
par(mfrow = c(2, 2), mar = c(5, 6, 1, 1), oma = c(5, 0, 0, 0), cex.lab = 2, las = 1, cex.axis = 1.3, mgp = c(4,1,0))

# Specify variables to plot here, and width of error bars
names4plotting = c('global.richness','r.lat.rich', 'gamma.stat','MRD.rich.slope')
#names4plotting = c('r.env.PSV', 'r.env.MRD', 'r.MRD.rich','r.PSV.rich')
#names4plotting = c('MRD.rich.slope', 'MRD.env.slope','PSV.rich.slope','PSV.env.slope')
error = 2 # error bars in SD units (+/-)
for (j in 1:4) {
  curr.metric = names4plotting[j]
  plot(trop.metrics.mean$time/1000, trop.metrics.mean[, curr.metric], xlim = c(0, max(trop.metrics.mean$time/1000)), 
       ylim = range(c(trop.metrics[, curr.metric, ], temp.metrics[, curr.metric, ], 
                      Ttrop.metrics[, curr.metric, ], Ttemp.metrics[, curr.metric, ]), na.rm= T), type = "n",
       ylab = metric.labels[metric.names == curr.metric], xlab = "")
  polygon(c(trop.metrics.mean$time/1000, rev(trop.metrics.mean$time/1000)), 
          c(trop.metrics.mean[, curr.metric] - error*trop.metrics.sd[, curr.metric], 
            rev(trop.metrics.mean[, curr.metric] + error*trop.metrics.sd[, curr.metric])), 
          col = rgb(.8, 0, 0, .3), border = NA)
  polygon(c(temp.metrics.mean$time/1000, rev(temp.metrics.mean$time/1000)), 
          c(temp.metrics.mean[, curr.metric] - error*temp.metrics.sd[, curr.metric], 
            rev(temp.metrics.mean[, curr.metric] + error*temp.metrics.sd[, curr.metric])), 
          col = rgb(0, 0, .8, .3), border = NA)
  points(trop.metrics.mean$time/1000, trop.metrics.mean[, curr.metric], type = 'l', col = 'red', lwd = 3)
  points(temp.metrics.mean$time/1000, temp.metrics.mean[, curr.metric], type = 'l', col = 'blue', lwd = 3)
  
  par(new = T)
  
  plot(Ttemp.metrics.mean$time - min(Ttemp.metrics.mean$time, na.rm = T), Ttrop.metrics.mean[, curr.metric], 
       xlim = c(0, max(c(Ttrop.metrics.mean$time, Ttemp.metrics.mean$time), na.rm = T) - min(Ttemp.metrics.mean$time, na.rm = T)), 
       ylim = range(c(trop.metrics[, curr.metric, ], temp.metrics[, curr.metric, ], 
                      Ttrop.metrics[, curr.metric, ], Ttemp.metrics[, curr.metric, ]), na.rm= T), type = "n",
       ylab = "", xlab = "", yaxt = "n", xaxt = "n")
  polygon(c(Ttrop.metrics.mean$time - min(Ttrop.metrics.mean$time, na.rm = T), rev(Ttrop.metrics.mean$time - min(Ttrop.metrics.mean$time, na.rm = T))), 
          c(Ttrop.metrics.mean[, curr.metric] - error*Ttrop.metrics.sd[, curr.metric], 
            rev(Ttrop.metrics.mean[, curr.metric] + error*Ttrop.metrics.sd[, curr.metric])), 
          col = rgb(.8, 0, 0, .3), border = NA)
  polygon(c(Ttemp.metrics.mean$time - min(Ttemp.metrics.mean$time, na.rm = T), rev(Ttemp.metrics.mean$time - min(Ttemp.metrics.mean$time, na.rm = T))), 
          c(Ttemp.metrics.mean[, curr.metric] - error*Ttemp.metrics.sd[, curr.metric], 
            rev(Ttemp.metrics.mean[, curr.metric] + error*Ttemp.metrics.sd[, curr.metric])), 
          col = rgb(0, 0, .8, .3), border = NA)
  points(Ttrop.metrics.mean$time - min(Ttrop.metrics.mean$time, na.rm = T), Ttrop.metrics.mean[, curr.metric], type = 'l', col = 'red', lwd = 3, lty = 'dashed')
  points(Ttemp.metrics.mean$time - min(Ttemp.metrics.mean$time, na.rm = T), Ttemp.metrics.mean[, curr.metric], type = 'l', col = 'blue', lwd = 3, lty = 'dashed')
  alt.x.vals = c(80, 120, 160, 200)
  mtext(alt.x.vals, 1, at = alt.x.vals - min(Ttemp.metrics.mean$time, na.rm=T), line = 2.5, col = 'gray50')
  
  if(curr.metric == 'gamma.stat') { abline(h = 0, lty = 'dashed')}
} 
mtext("Time (x1000, Energy Gradient)", 1, outer=T, cex = 1.75, line = 1.5) 
mtext("Time (No Energy Gradient)", 1, outer = T, cex = 1.75, line = 3.5, col = 'gray50')
dev.off()

## Plot histograms of metrics, putting all 4 scenarios on each panel and different panels had different metrics

#par(mfrow = c(2, 2), mar = c(3, 6, 1, 1), oma = c(3, 0, 0, 0), cex.lab = 2, las = 1, cex.axis = 1.3, mgp = c(4,1,0))
par(mfrow = c(2, 2), cex.lab = 2, cex.axis = 1.3,mar = c(5, 6, 1, 1),oma = c(3, 0, 0, 0),las=1,mgp = c(4,1,0))

metric.names = c('global.richness','r.lat.rich', 'gamma.stat','r.env.PSV', 'r.env.MRD', 'r.MRD.rich','r.PSV.rich')
metric.labels = c('Global richness', expression(italic(r)[latitude-richness]), 
                  expression(gamma), expression(italic(r)[env-PSV]),
                  expression(italic(r)[env-MRD]), expression(italic(r)[MRD-richness]),
                  expression(italic(r)[PSV-richness]))


names4plotting = c('r.env.PSV', 'r.env.MRD', 'r.MRD.rich','r.PSV.rich')
for (j in 1:4) {
  curr.metric = names4plotting[j]
  Ttrop.hist = density(Ttrop.metrics[, curr.metric,],na.rm=T); Ttrop.hist$y = Ttrop.hist$y / max(Ttrop.hist$y,rm.na=T);
  Ttemp.hist = density(Ttemp.metrics[, curr.metric,],na.rm=T); Ttemp.hist$y = Ttemp.hist$y / max(Ttemp.hist$y,rm.na=T);
  trop.hist = density(trop.metrics[, curr.metric,],na.rm=T); trop.hist$y = trop.hist$y / max(trop.hist$y,rm.na=T);
  temp.hist = density(temp.metrics[, curr.metric,],na.rm=T); temp.hist$y = temp.hist$y / max(temp.hist$y,rm.na=T);
  #max(c(Ttrop.hist$y,Ttemp.hist$y,trop.hist$y,temp.hist$y))
  
  plot(Ttrop.hist,xlim=c(-1,1),xlab = metric.labels[metric.names == curr.metric],main="",ylim=c(0,1),typ="n")
  points(Ttrop.hist,type = 'l', col = 'red', lwd = 3, lty = 'dashed')
  points(Ttemp.hist,type = 'l', col = 'blue', lwd = 3, lty = 'dashed')
  points(trop.hist,type = 'l', col = 'red', lwd = 3, lty = 1)
  points(temp.hist,type = 'l', col = 'blue', lwd = 3, lty = 1)
  
}

# just finding sims with odd metric values
for (i in 1:100) {
  
  print(Ttemp.metrics[which.min(Ttemp.metrics[,curr.metric,i]),c('sim',curr.metric),i])
    
}