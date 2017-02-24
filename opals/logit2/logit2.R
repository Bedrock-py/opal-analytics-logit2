#Created by Pablo Diego Rosell, PhD, for Gallup inc. in February 2017
#Stata logit2 emulation

#Load data after preparing it in Stata

# setwd("C:/Users/pablo_diego-rosell/Desktop/Projects/DARPA/Cycle 1/Research Protocols/Registration/Experiment 1/Rand2011PNAS_data_and_code")
cooperation<-read.csv(commandArgs(TRUE)[1])

# Install function for packages    
packages<-function(x){
  x<-as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.cnr.berkeley.edu")
    require(x,character.only=TRUE)
  }
}
packages(multiwayvcov)
packages(lmtest)


#STATA LINES
# char condition[omit] "Fluid"
#   xi: logit2 decision i.condition  if round_num==1, fcluster(sessionnum) tcluster(playerid)

#R EQUIVALENT

cooperation$condition.f <- factor(cooperation$condition)
cooperationR1<-subset(cooperation, round_num==1)
logitR1 <- glm(decision0d1c ~ condition.f, data = cooperationR1, family = "binomial")
logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
coeftest(logitR1, logitR1.multiwayvcov)


