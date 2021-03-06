


library(data.table)
library(foreach)
library(reshape2)
library(stringr)
library(gplots)
library(igraph)
library(ggplot2)


setwd("~/work/Leish_donovaniComplex/MS01_globalDiversity_Ldonovani/github_scripts/Global_genome_diversity_Ldonovani_complex/10_CNVs/")
dir.create("CNV_drug_resis", showWarnings = F)
setwd("CNV_drug_resis")
  

# load somy and median chr coverage data
load(file="../somy_all.RData")
setnames(all, c("chr","sample"), c("chrom","samp"))
# load sample - group information
load("../../01_phylogenetic_reconstruction/sample.info_NEWsubgroups.RData")


#####################
#
# run for tag in c("MSL","Hlocus_ins.3g.4g")
#
#####################
#
# tag="MSL"
# tag="Hlocus_ins.3g.4g"
# tag="Hlocus_ins.2g4m"
# tag="Hlocus_out"

if (tag=="MSL")
{
  winsize=50; chromosomes=c("LinJ.31"); chromosomes.n=c(31); samples.sub<-c("WC","Cha001","HN167","HN336","ARL","MAM",                                                                          "IMT373cl1","CH35","AM563WTI","BHU1139A1")
} else if (tag=="Hlocus_ins.3g.4g")
{
  winsize=200; chromosomes=c("LinJ.23"); chromosomes.n=c(23); samples.sub<-c("BPK157A1","LRC.L51p","AG83","BD09","BD12","BD14","BD15","BD17","BD21","BD22","BD24","BD25",      
                                                                             "BD27","BHU1062.4","BHU1064A1","BHU1065A1","BHU1137A1","BHU1139A1","BHU220A1", "BHU41","BHU816A1",
                                                                             "BHU824A1","BHU931A1","BPK029A1","BPK035A1","BPK067A1","BPK077A1","BPK164A1","BPK282I9","BPK294A1",
                                                                             "BPK471A1","BPK562A1","BPK649A1","BUCK","Chowd5","DD8","Don201","GEBRE1","IECDR1","Inf206",
                                                                             "Ldon282cl2","LdonLV9","LRC.L61","Malta33","Nandi","STL2.78","STL2.79","SUDAN1","X1S","X356WTV",
                                                                             "X363SKWTI","X364SPWTII","X38.UMK","X383WTI","X45.UMK","X762L",
                                                                             "L60b","X452BM","AM560WTI")
} else if (tag=="Hlocus_ins.2g4m") # 2 genes increased when 4 is max
{
  winsize=200; chromosomes=c("LinJ.23"); chromosomes.n=c(23); samples.sub<-c("Cha001","CL.SL","Inf001","LRC.L740")
} else if (tag=="Hlocus_out")
{
  winsize=200; chromosomes=c("LinJ.23"); chromosomes.n=c(23); samples.sub<-c("L60b","X452BM","AM560WTI")
}




                                                                                          

# genome.cov<-foreach(sample.c=samples.sub, .combine=rbind) %do%
# {
#   # sample.c="WC"
#   # sample.c="X1026.8"
# 
#   somy<-all[samp==sample.c, .(chrom, RDmedian, Somy)]
#   somy[, haploid.cov:=round(RDmedian/Somy)] # haploid coverage
# 
#   # files in /lustre/scratch118/infgen/team133/sf18/leish_donovaniComplex/A14_gene_cov_annotv38
#   ss<-sample.c
#   ss<-gsub("[.]", "-", ss)
#   ss<-gsub("X", "", ss)
# 
#   if (server)
#   {
#     file=paste0("/lustre/scratch118/infgen/team133/sf18/leish_donovaniComplex/A14_gene_cov_annotv38/genomecov/linj.",ss,".sorted.markdup.realigned.PP.rmdup.genome.cov")
# 
#   } else {
#     # file=paste0("/Volumes/sf18/tmp/linj.",ss,".sorted.markdup.realigned.PP.rmdup.genome.cov")
#     file=paste0("/Users/sf18/work/tmp/linj.",ss,".sorted.markdup.realigned.PP.rmdup.genome.cov")
#   }
#   #
#   if (!file.exists(file))
#   {
#     print(paste("file", file, " does not exist!"))
#   } else {
#     print(paste("sample", file))
#   }
# 
#   dat<-data.table(read.table(file))
#   setnames(dat, colnames(dat),c("chr","pos","cov"))
#   dat<-dat[chr !="LinJ.00"][order(chr)]
# 
#   dat[,win:=round(pos/winsize)]
#   dat[,cov:=as.double(cov)]
#   dat[,cov.median.win:=median(cov), by=.(chr,win)]
#   dat[,cov.median.chr:=median(cov), by=chr]
# 
#   dat.win<-unique(dat[,.(chr,win,cov.median.win,cov.median.chr)])[chr %in% chromosomes]
#   dat.win[,win.chr:=1:nrow(dat.win)]
#   dat.win[, cov.median.win.somynorm:=cov.median.win/median(somy[,haploid.cov])]
# 
#   # pdf(paste0("genomecov_",sample.c,"_",winsize,"bp.pdf"),width=10,height=2)
#   # gg<-ggplot(dat.win, aes(win.chr, cov.median.win.somynorm)) +
#   #   geom_point(size=0.01) +
#   #   labs(x=paste0("Window [",winsize/1000," kb]"), y="Median coverage") +
#   #   facet_wrap(.~chr)
#   # print(gg)
#   # dev.off()
# 
#   for (cc in chromosomes)#c(paste0("LinJ.0",1:9),paste0("LinJ.",10:36)))
#   {
#     dat.win[chr==cc, ploidy:=somy[chrom==cc,Somy]]
#   }
#   dat.win[,ploidy:=as.factor(ploidy)]
# 
#   dat.win[,sample:=sample.c]
#   dat.win[,chr:=as.numeric(str_sub(as.character(dat.win[,chr]), -2,-1))]
#   dat.win
# }
# 
# for (sample.c in samples.sub) {genome.cov[sample==sample.c, group:=sample.info[sample==sample.c,groups]]}
# genome.cov<-genome.cov[order(group)]
# genome.cov[,cov.median.win.somynorm:=NULL]
# genome.cov[,ploidy:=as.numeric(as.character(ploidy))]
# # normalise the median window coverage by the median haploid coverage of the respective chromosome -> cov.chrSomyNorm
# # note cov.median.win.somynorm was normalised by the haploid coverage of the respective chromosome using the haploid coverage calulated ACRoss chromosomes using the window based data from here
# for(sample.c in samples.sub)
# {
#   # sample.c="WC"
#   for(chromosome in chromosomes.n)
#   {
#     medcov_across_win<-median(genome.cov[sample==sample.c & chr==chromosome, cov.median.win])
#     genome.cov[sample==sample.c & chr==chromosome, cov.chrSomyNorm:=cov.median.win*ploidy/medcov_across_win]
#   }
# }
# genome.cov[, cov.chrSomyNorm.diff:=cov.chrSomyNorm-ploidy]
# print(paste0("all.genome.cov.median_",tag,"_",winsize/1000,"kb.RData"))
# save(genome.cov,file=paste0("all.genome.cov.median_",tag,"_",winsize/1000,"kb.RData"))
load(file=paste0("all.genome.cov.median_",tag,"_",winsize/1000,"kb.RData"))
genome.cov[,ploidy:=as.numeric(as.character(ploidy))]



# -----------------------------------------------------
#
# Hlocus sourrounding locus
#
if (tag %in% c("Hlocus_ins.3g.4g", "Hlocus_ins.2g4m"))
{
  spos=70000
  epos=135000
  # spos=1 # all chr
  # epos=774050 # all chr
  # ~/leish_donovaniComplex/A14_gene_cov/candidate_loci_drug_resistance$
  # grep 'LinJ.23' /lustre/scratch118/infgen/team133/sf18/refgenomes/annotation/TriTrypDB-38_LinfantumJPCM5.gff | grep 'gene' | awk '{if($4>=68038 && $4<=125879) print $4,$5,$9}' | sort -n |awk -F'[ =;]' '{print $1,$2,$4}' > Hlocus_genes.txt
  genes<-data.table(read.table("Hlocus_genes.txt")); setnames(genes,colnames(genes),c("sp","ep","gene"))
  
  load(file=paste0("all.genome.cov.median_",tag,"_",winsize/1000,"kb.RData"))
  xx<-genome.cov[win>=spos/winsize & win<=epos/winsize & sample %in% samples.sub]
  xx[,sample:=as.factor(sample)]
  table(unique(xx[,.(group,sample)])[,group])
  # Ldon1 Ldon3 Ldon5 -> tag "Hlocus_ins.3g.4g"
  # 42    13     1
  # Ldon1      Linf1 other_Ldon  -> tag "Hlocus_ins.2g4m"
  # 1          2          1
  xx$sample<-factor(xx$sample, levels = c(sort(as.character(unique(xx[group=="Ldon1",sample]))),
                                          sort(as.character(unique(xx[group=="Ldon3",sample]))),
                                          sort(as.character(unique(xx[group=="Ldon5",sample]))),
                                          sort(as.character(unique(xx[group=="other_Ldon",sample]))),
                                          sort(as.character(unique(xx[group=="Linf1",sample])))))

  somy.col  <- c(colorRampPalette(c("yellow","orange","green4","blue","red"))(6) ,c("purple","pink"))
  #
  if (tag=="Hlocus_ins.3g.4g")
  {
    load(file=paste0("all.genome.cov.median_","Hlocus_out","_",winsize/1000,"kb.RData"))
    yy<-genome.cov[win>=spos/winsize & win<=epos/winsize]
    yy[,sample:=as.factor(sample)]
    xx<-rbind(xx,yy)
    xx$sample<-factor(xx$sample, levels = c(sort(as.character(unique(xx[group=="Ldon1",sample]))),
                                            sort(as.character(unique(xx[group=="Ldon3",sample]))),
                                            sort(as.character(unique(xx[group=="Ldon5",sample])))))
    
    pdf(paste0(tag,".pdf"),width=12,height=12)
    gg<-ggplot(xx, aes(win.chr*winsize, cov.chrSomyNorm, col=as.factor(ploidy))) +#as.factor(ploidy))) +
      geom_point(size=0.6) +
      labs(x=paste0("Genomic position [bp]"), y=paste0("Normalized median coverage [",winsize,"bp win]")) +
      # facet_grid(sample~chr, scale="free_y") +
      facet_wrap(~sample, ncol = 4, scale="free_y") +
      scale_color_manual(values=somy.col[c(2,3,4,5,6)], name="Somy") +
      theme_bw()
    for (i in 1:nrow(genes))
    {
      if (genes[i,gene] %in% c("LinJ.23.0280","LinJ.23.0290","LinJ.23.0300","LinJ.23.0310"))
      {
        gg <- gg + geom_segment(x = genes[i,sp], y = 2, xend = genes[i,ep], yend = 2,
                                color="black", size=1)
      }
    }
    print(gg)
    dev.off()
  }
  
  if (tag=="Hlocus_ins.2g4m")
  {
    #
    pdf(paste0(tag,"_col.pdf"),width=10,height=8)
    # pdf(paste0(tag,"_col.pdf"),width=8,height=5)
    gg<-ggplot(xx, aes(win.chr*winsize, cov.chrSomyNorm, col=as.factor(round(cov.chrSomyNorm)))) +#as.factor(ploidy))) +
      geom_point(size=0.6) +
      labs(x=paste0("Genomic position [bp]"), y=paste0("Normalized median coverage [",winsize,"bp win]")) +
      # facet_grid(sample~chr) +#, scale="free_y") +
      facet_wrap(~sample, ncol = 1, scale="free_y") +
      scale_colour_manual(values =c("black",somy.col,rep("grey",190)), name="Somy") +
      # scale_colour_gradientn(colours =c("black",somy.col,"grey","grey"), name="Somy") +
      # scale_color_manual(values=somy.col[c(4,8)], name="Somy") +
      theme_bw()
    for (i in 1:nrow(genes))
    {
      if (genes[i,gene] %in% c("LinJ.23.0280","LinJ.23.0290","LinJ.23.0300","LinJ.23.0310"))
      {
        gg <- gg + geom_segment(x = genes[i,sp], y = 2, xend = genes[i,ep], yend = 2,
                                color="black", size=1)
      }
    }
    print(gg)
    dev.off()
  }
}







# -----------------------------------------------------
#
# MSL sourrounding locus
#
if (tag=="MSL")
{
  spos=1105000
  epos=1220000
  # ~/leish_donovaniComplex/A14_gene_cov/candidate_loci_drug_resistance$
  # grep 'LinJ.31' /lustre/scratch118/infgen/team133/sf18/refgenomes/annotation/TriTrypDB-38_LinfantumJPCM5.gff | grep 'gene' | awk '{if($4>=1105000 && $4<=1220000) print $4,$5,$9}' | sort -n |awk -F'[ =;]' '{print $1,$2,$4}' > MSL_genes.txt
  genes<-data.table(read.table("MSL_genes.txt")); setnames(genes,colnames(genes),c("sp","ep","gene"))
  
  xx<-genome.cov[win>=spos/winsize & win<=epos/winsize & sample %in% c("WC","Cha001","HN167","HN336","ARL","IMT373cl1","CH35")]
  xx[,sample:=as.factor(sample)]
  xx$sample<-factor(xx$sample, levels = c("WC","Cha001","ARL","HN167","HN336","IMT373cl1","CH35"))
  
  somy.col  <- c(colorRampPalette(c("yellow","orange","green4","blue","red"))(6) ,c("purple","pink"))
  #
  pdf("MST_col.pdf",width=10,height=8)
  gg<-ggplot(xx, aes(win.chr*winsize, cov.chrSomyNorm, col=as.factor(round(cov.chrSomyNorm)))) +#as.factor(ploidy))) +
    geom_point(size=0.6) +
    labs(x=paste0("Genomic position [bp]"), y=paste0("Normalized median coverage [",winsize,"bp win]")) +
    facet_grid(sample~chr) +#, scale="free_y") +
    scale_colour_manual(values =c("black",somy.col,"grey","grey"), name="Somy") +
    # scale_colour_gradientn(colours =c("black",somy.col,"grey","grey"), name="Somy") +
    # scale_color_manual(values=somy.col[c(4,8)], name="Somy") +
    theme_bw()
  for (i in 1:nrow(genes))
  {
    gg <- gg + geom_segment(x = genes[i,sp], y = 10, xend = genes[i,ep], yend = 10,
                            color=ifelse(genes[i,gene] %in% c("LinJ.31.2370","LinJ.31.2380","LinJ.31.2390","LinJ.31.2400"),
                                         "black","white"))
  }
  print(gg)
  dev.off()
  
}




