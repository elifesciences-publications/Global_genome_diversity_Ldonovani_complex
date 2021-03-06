
# circos plots for samples of interest



setwd("~/work/Leish_donovaniComplex/MS01_globalDiversity_Ldonovani/github_scripts/Global_genome_diversity_Ldonovani_complex/06_hybridisation_signatures/")

library(data.table)
library(foreach)
library(StAMPP)
library(ggplot2)
library(circlize)



# get Neis distance matrix for windows along the chromosome
# this was calculated in 01_phylogenetic_reconstruction/A01_leish_donovaniComplex_StAMPP_window.R lines 174-210



####
#
# make circos plots for sample of interests for 10kb windows with
# 2. heatmap with ordered NeisD coloured by groups
# 3. min and max Neisd present for the sample

load("../01_phylogenetic_reconstruction/sample.info_NEWsubgroups.RData")
load("../05_heterozygosities/het.wins.RData")

# n.plot.samp: indicates the number of nearest sample to be plotted inthe circos
plot_circos_part <-function(c.sample, n.plot.samp=60)
{
  ploidy <-data.table(read.table("~/work/Leish_donovaniComplex/MS01_globalDiversity_Ldonovani/github_scripts/04_aneuploidy/somies_updated.txt", head=T))
  load(file=paste0("../01_phylogenetic_reconstruction/window/dat/all.chr.dists_",c.sample,".RData"))
  all.chr.dists[,group.col:=as.character(group.col)]
  # update groups and colours
  for (gg in unique(sample.info[,groups]))
  {
    all.chr.dists[sample %in% sample.info[groups==gg, sample], group:=gg]
    all.chr.dists[sample %in% sample.info[groups==gg, sample], group.col:=unique(sample.info[groups==gg, group.col])]
  }
  all.chr.dists[,chr:=as.character(chr)]
  all.chr.dists[chr %in% c(1,2,3,4,5,6,7,8,9), chr:=paste0("0",chr)]
  #
  
  dcir <- het.wins[,.(chr,w10kb,get(c.sample))]
  dcir[,chr:= gsub("LinJ.","",chr)]
  setnames(dcir, colnames(dcir)[3], c("y"))
  summary(dcir[,y])
  #
  png(paste0("Circos_firstX/Circos",c.sample,"_first",n.plot.samp,"_maxhet",max(dcir$y),".png"),width=1200,height=1200)
  circos.clear()
  par(mar = c(1,1,1,1))#
  circos.par(cell.padding = c(0, 0, 0, 0), "track.height" = 0.2, start.degree=90)
  circos.initialize( factors=dcir$chr, x=dcir$w10kb )
  circos.trackPlotRegion(ylim = c(0, max(dcir$y)), factors = as.character(dcir$chr), y = dcir$y, panel.fun = function(x, y) 
  {
    name = get.cell.meta.data("sector.index")
    i = get.cell.meta.data("sector.numeric.index")
    xlim = get.cell.meta.data("xlim")
    ylim = get.cell.meta.data("ylim")
    
    circos.axis(
      h="top",                   # x axis on the inner or outer part of the track?
      labels=FALSE,              # show the labels of the axis?
      major.tick=TRUE,           # show ticks?
      labels.cex=0.5,            # labels size (higher=bigger)
      labels.font=2,             # labels font (1, 2, 3 , 4)
      direction="outside",       # ticks point to the outside or inside of the circle ?
      minor.ticks=4,             # Number of minor (=small) ticks
      major.tick.percentage=0.1, # The size of the ticks in percentage of the track height
      lwd=1.5                      # thickness of ticks and x axis.   
    )
    
    #text direction (dd) and adjusmtents (aa)
    theta = circlize(mean(xlim), 1.3)[1, 1] %% 360
    dd <- ifelse(theta < 90 || theta > 270, "clockwise", "reverse.clockwise")
    a1 <- ifelse(theta < 90 || theta > 270, c(-4.4), c(5.4))
    a2 <- 0.5; aa<-c(a1,a2) # 0.5 mean text willl be printed inthe middle of the cell
    circos.text(x=mean(xlim), y=0.2, labels=name, facing = dd, cex=2,  adj = aa)
    # circos.text(x=mean(xlim), y=4, labels=name, facing = dd, cex=2,  adj = aa)
  })
  # add lines
  circos.trackLines(as.character(dcir$chr), dcir$w10kb, dcir$y, col="blue", lwd=2.5)
  #
  # add next tract
  circos.par(cell.padding = c(0, 0, 0, 0))
#   n.plot.samp=50
  circos.trackPlotRegion(ylim = c(0, n.plot.samp), factors = dcir$chr, track.height=0.3,
                         panel.fun = function(x, y) {
                           #select details of current sector
                           name = get.cell.meta.data("sector.index")
                           i = get.cell.meta.data("sector.numeric.index")
                           xlim = get.cell.meta.data("xlim")
                           ylim = get.cell.meta.data("ylim")
                         })
  # add samples
  for (os in 1:n.plot.samp) # os : ordered sample
  {
    aa<-all.chr.dists[ordered.sample==os]# & chr<10]
    circos.trackPoints(as.character(aa$chr), x=aa$win, y=rep((n.plot.samp+1)-os,nrow(aa)), 
                       col=aa$group.col , pch = 20, cex = 0.5-(os*0.0005))
    #                       col=paste0("#",unlist(phylocol[aa$group.col])) , pch = 20, cex = 0.1-(os*0.0005))
  }
  #
  # add track
  circos.par(cell.padding = c(0, 0, 0, 0))
  circos.trackPlotRegion(ylim = c(0, 1), factors = dcir$chr, track.height=0.15,
                         panel.fun = function(x, y) {
                           #select details of current sector
                           name = get.cell.meta.data("sector.index")
                           i = get.cell.meta.data("sector.numeric.index")
                           xlim = get.cell.meta.data("xlim")
                           ylim = get.cell.meta.data("ylim")
                         })
  # add lines
  aa<-all.chr.dists[ordered.sample==1] # closest sample
  circos.trackLines(as.character(aa$chr), aa$win, aa$NeisD, col="darkgreen", lwd=2)
  aa<-all.chr.dists[ordered.sample==n.plot.samp]; aa[NeisD==Inf,NeisD:=NA] # furthest sample
  circos.trackLines(as.character(aa$chr), aa$win, aa$NeisD, col="orange", lwd=1.2)
  #
  # add somy tract
  circos.trackPlotRegion(ylim = c(0, 1), factors = as.character(aa$chr), track.height=0.15,
                         #panel.fun for each sector
                         panel.fun = function(x, y) {
                           #select details of current sector
                           name = get.cell.meta.data("sector.index")
                           i = get.cell.meta.data("sector.numeric.index")
                           xlim = get.cell.meta.data("xlim")
                           ylim = get.cell.meta.data("ylim")
                           
                           #plot main sector
                           somycol <- colorRampPalette(c("orange","yellow","green4","blue","red","pink"))(8)
                           circos.rect(xleft=xlim[1], ybottom=ylim[1], xright=xlim[2], ytop=ylim[2], 
                                       col = somycol[ploidy[,get(c.sample)][i]], 
                                       border=somycol[ploidy[,get(c.sample)][i]])
                         })
  
  dev.off()
}

dir.create("Circos_firstX", showWarnings = F)


for (i in c("EP")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("MAM","EP")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("CH32","CH34")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("GE","LEM3472","BUMM3","LRC.L740","SUKKAR2")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("BPK157A1")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("LRC.L53")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in sample.info[groups=="Ldon3"]$sample){plot_circos_part(c.sample=i, n.plot.samp = 60)}

for (i in c("BPK512A1","BPK612A1")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("ISS2429","ISS2426","ISS174","Inf055","Inf152")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}

for (i in c("L60b","CL.SL","OVN3")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}
for (i in c("LRC.L1311","LRC.L1312")) {plot_circos_part(c.sample=i, n.plot.samp = 60)}



