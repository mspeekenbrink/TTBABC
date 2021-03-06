#This is an example 2 from the TTB-ABC paper
#Copyright@Schulz, Speekenbrink, Meder
#Recovering a data set that has been created by standard TTB
#This script demonstrates that TTB-ABC can succesfully cope with data generated by TTB

#Input for TTB-ABC: 
##4 trinary x variables: x_1,...,x_4 p(x_i=1)=p(x_i=-1)=1/4, p(x_i=0)=0.5
##1 binary y variable: y=TTB(x1,x2,x3) with c1>c2>c3, x4 is unimportant

#Result of script:
##traces of the 4 cue weight over time, averaged over 30 runs


#House keeping
rm(list=ls())

#Load ttbabc-sources
source("R/ttbabcfit.R")

#Load packages
packages <- c('plyr', 'ggplot2')
lapply(packages, library, character.only=TRUE)


#My Take The Best-Function
myttb<-function(x){
  y<-0
  for (i in seq_along(x)){
    y<-ifelse(y==0 & x[i]!=0,x[i],y)
  }
  y<-ifelse(y==0,sample(c(-1,1),1),y)
  return(y)
}

#Create X-frame
xttb<-data.frame(apply(matrix(NA, nrow=1000, ncol=4), 2, function(x){ sample(c(-1,0,0,1), 1000, replace = TRUE)}))
#Create y-frame, with x_4 unimportant
yttb<-apply(xttb[,1:3],1,myttb)

#30 trials of 100 simulations
trial<-rep(100, 30)

#set seed to eric's birthday
set.seed(310887)

#get traces for 30 trials with 100 simulations, TAKE CARE: this will run for a while...
dout<-lapply(trial, function(x){ttbabcfit(xttb, yttb, x)})

#get the mean for each sim point over all 30 trials
##apply to all 4 cues
mul<-lapply(1:4, function(x){
  #the mean
  apply( 
    #unlisted
    sapply( 
      #get element
      lapply(dout,function(y) {y$abc[,x]}),unlist), 1, mean
    )
  })

#get the mean for each sim point over all 30 trials
##apply to all 4 cues
sel<-lapply(1:4, function(x){ 
  #the standard error
  apply( 
    #unlisted
    sapply( 
      #
      lapply(dout, function(y) {y$abc[,x]}), unlist), 1, function(z){
        #standard error
        sd(z)/sqrt(length(z))}
    )
  })  

#Plot
dplot<-data.frame(mu=unlist(mul), se=unlist(sel),  trials=rep(1:100, 4), Cue=rep(c("c1","c2","c3","c4"), each=100))

#Position of points
pd <- position_dodge(.1)

#Create plot:
##mu(p) over trials per Cue
p<-ggplot(dplot, aes(x=trials, y=mu, color=Cue)) + 
  #black line
  geom_line(position=pd, size=0.5)+
  #points with bigger size
  geom_point(position=pd, size=1)+
  #error-bars
  geom_errorbar(aes(ymin=mu-se, ymax=mu+se), width=0.5, size=0.5, position=pd) +
  #xlab
  xlab("Trials")+
  #ylab
  ylab("Probabilities")+
  #title
  ggtitle("Trace Plot")+
    #white theme
  theme_bw()+
  #bigger fonts
  theme(text = element_text(size=22))

#What does it look like?
print(p)

#save pdf
pdf("figs/ttbrecovertrace.pdf")
print(p)
dev.off()
#END