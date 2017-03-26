#Created by Pablo Diego Rosell, PhD, for Gallup inc. in February 2017
#Stata logit2 emulation

#Load data after preparing it in Stata

# Usage: logit2.R CSV_PATH ANALYSIS_STAGE
#	ANALYSIS_STAGE is an integer from 1 to 11

# setwd("C:/Users/pablo_diego-rosell/Desktop/Projects/DARPA/Cycle 1/Research Protocols/Registration/Experiment 1/Rand2011PNAS_data_and_code")
cooperation<-read.csv(commandArgs(TRUE)[1])
analysis_stage<-commandArgs(TRUE)[2]


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
packages(dplyr)


#STATA LINES
# char condition[omit] "Fluid"
#   xi: logit2 decision i.condition  if round_num==1, fcluster(sessionnum) tcluster(playerid)

#R EQUIVALENT
# Need to get list of columns to factor and pass as param
# Interaction terms : "condition.f * interactionTerm"


# Multi-line comment workaround
if(FALSE){
	factor_reference <- ""
	if(analysis_stage == 3 || analysis_stage == 5){
		factor_reference <- "Fluid"
	}
	if(analysis_stage == 7 || analysis_stage == 9){
		factor_reference <- "Random"
	}
	if(analysis_stage == 8 || analysis_stage == 10){
		factor_reference <- "Static"
	}

	if(analysis_stage == 3) {
		cooperationR1<-subset(cooperation, round_num == 1)
	} else if(analysis_stage == 5 || analysis_stage == 6 || analysis_stage == 9 || analysis_stage == 10) {
		cooperationR1<-subset(cooperation, round_num >= 7)
	} else {
		cooperationR1<-cooperation
	}


	if(factor_reference == ""){
		cooperation$fluid.f <- factor(cooperation$fluid)
	} else {
		cooperation$condition.f <- relevel(cooperation$condition,factor_reference)
	}

	logitR1 <- glm(decision0d1c ~ condition.f, data = cooperationR1, family = "binomial")
	logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
	coeftest(logitR1, logitR1.multiwayvcov)
}
# if(FALSE){

	# by condition round_num: sum decision
	# by condition: logit2 decision round_num, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 1){
		byC_RN <- group_by(cooperation,  condition, round_num)
		stage1 <- summarize(byC_RN, count=n(), mn=mean(decision0d1c),sd=sd(decision0d1c), min= min(decision0d1c), max=max(decision0d1c))
		cooperation$round_num <- factor(cooperation$round_num)
		logitR1 <- glm(decision0d1c ~ round_num, data = cooperation, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperation$sessionnum, cooperation$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	# by condition round_num: sum decision if num_neighbors>0
	# by condition: logit2 decision round_num if num_neighbors>0, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 2){
		cooperationR1<-subset(cooperation, num_neighbors>0)
		byC_RN <- group_by(cooperationR1, condition, round_num)
		stage1 <- summarize(byC_RN, count=n(), mn=mean(decision0d1c),sd=sd(decision0d1c), min= min(decision0d1c), max=max(decision0d1c))
		cooperationR1$round_num <- factor(cooperationR1$round_num)
		logitR1 <- glm(decision0d1c ~ round_num, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}
	#char condition[omit] "Fluid"
	#xi: logit2 decision i.condition  if round_num==1, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 3){
		cooperation$condition.f <- relevel(cooperation$condition,"Fluid")
		cooperationR1<-subset(cooperation, round_num==1)
		logitR1 <- glm(decision0d1c ~ condition.f, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	#xi: logit2 decision i.fluid*round_num , fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 4){
		cooperation$fluid.f <- factor(cooperation$fluid)
		logitR1 <- glm(decision0d1c ~ fluid.f * round_num, data = cooperation, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperation$sessionnum, cooperation$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}


	#char condition[omit] "Fluid"
	#xi: logit2 decision i.condition if round_num>=7, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 5){
		cooperation$condition.f <- relevel(cooperation$condition,"Fluid")
		cooperationR1<-subset(cooperation, round_num>=7)
		logitR1 <- glm(decision0d1c ~ condition.f, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	#xi: logit2 decision i.fluid if round_num>=7, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 6){
		cooperation$fluid.f <- factor(cooperation$fluid)
		cooperationR1<-subset(cooperation, round_num>=7)
		logitR1 <- glm(decision0d1c ~ fluid.f, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	#char condition[omit] "Random"
	#xi: logit2 decision i.condition  , fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 7){
		cooperation$condition.f <- relevel(cooperation$condition,"Random")
		logitR1 <- glm(decision0d1c ~ condition.f, data = cooperation, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperation$sessionnum, cooperation$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	# char condition[omit] "Static"
	# xi: logit2 decision i.condition  , fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 8){
		cooperation$condition.f <- relevel(cooperation$condition,"Static")
		logitR1 <- glm(decision0d1c ~ condition.f, data = cooperation, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperation$sessionnum, cooperation$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	# char condition[omit] "Random"
	# xi: logit2 decision i.condition  if round_num>=7, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 9){
		cooperation$condition.f <- relevel(cooperation$condition,"Random")
		cooperationR1<-subset(cooperation, round_num>=7)
		logitR1 <- glm(decision0d1c ~ condition.f, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	# char condition[omit] "Static"
	# xi: logit2 decision i.condition  if round_num>=7, fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 10){
		cooperation$condition.f <- relevel(cooperation$condition,"Static")
		cooperationR1<-subset(cooperation, round_num>=7)
		logitR1 <- glm(decision0d1c ~ condition.f, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}

	# logit2 decision num_neighbors if condition=="Fluid", fcluster(sessionnum) tcluster(playerid)
	if(analysis_stage == 11){
		cooperation$num_neighbors <- factor(cooperation$num_neighbors)
		cooperationR1<-subset(cooperation, condition=="Fluid")
		logitR1 <- glm(decision0d1c ~ num_neighbors, data = cooperationR1, family = "binomial")
		logitR1.multiwayvcov <- cluster.vcov(logitR1, cbind(cooperationR1$sessionnum, cooperationR1$playerid))
		coeftest(logitR1, logitR1.multiwayvcov)
	}
# }
