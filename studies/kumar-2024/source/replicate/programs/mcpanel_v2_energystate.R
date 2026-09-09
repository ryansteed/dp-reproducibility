rm(list=ls())

#install packages if not already installed
#install.packages("MCPanel")
#install.packages("glmnet")
#install.packages("ggplot2")
#install.packages("latex2exp")
#install.packages("foreign")

## Loading Source files
library(MCPanel)
library(glmnet)
library(ggplot2)
library(latex2exp)

## Reading data
## Set working directory
setwd("C:\\Users\\k1ank00\\OneDrive - FR Banks\\anil\\research\\texas_home_equity\\credit_constraints\\replicate")

##read credit constraints data
df_Y<-read.csv("data\\data_for_Matrix_Completion_energystate.csv", header = TRUE)
df_treat <- read.csv("data\\treat_matrix_for_Matrix_Completion_energystate.csv", header = TRUE)
##drop rows pertaining to years 1980-1991
df_Y<-subset(df_Y,select=-c(lfpr1980,lfpr1981,lfpr1982,lfpr1983,lfpr1984,lfpr1985,lfpr1986,lfpr1987,lfpr1988,lfpr1989,lfpr1990,lfpr1991))
df_treat<-subset(df_treat,select=-c(texas_post1980,texas_post1981,texas_post1982,texas_post1983,texas_post1984,texas_post1985,texas_post1986,texas_post1987,texas_post1988,texas_post1989,texas_post1990,texas_post1991))
years <- 1992:2007

#convert to matrix and remove the first column
Y<-as.matrix(df_Y)
treat=as.matrix(df_treat)
Y<-Y[,-1]
treat<-treat[,-1]

Yorig=Y
mcpanel<-matrix(0, nrow = nrow(treat), ncol = ncol(treat))
elasticnet<-matrix(0, nrow = nrow(treat), ncol = ncol(treat))
elasticnetT<-matrix(0, nrow = nrow(treat), ncol = ncol(treat))
DID<-matrix(0, nrow = nrow(treat), ncol = ncol(treat))
ADH<-matrix(0, nrow = nrow(treat), ncol = ncol(treat))

for (i in 1:nrow(treat)) {
#for (i in 2) {
  
placebo=Yorig[i,]

if (i==1) {
Y<-rbind(placebo,Yorig[-i,])
## Setting up the configuration
N <- nrow(treat)
T <- ncol(treat)
treat_mat<-1-treat
Y_obs=Y*treat_mat
}

#note that first row (i=1) of Yorig is treated (Texas). we want to use all other counties to in the donor pool for Texas
#however, for each control county, we do not want treated (Texas) in the donor pool

else if (i>1) {
  ##one control county will pretend to be treated after removing Texas
  Y<-rbind(placebo,Yorig[c(-1,-i),])
  ## Setting up the configuration
  ##note that treat matrix will have one less rwo as Texas has been removed ftrom donor pool
  N <- nrow(treat[-nrow(treat),])
  T <- ncol(treat[-nrow(treat),])
  treat_mat<-1-treat[-nrow(treat),]
  Y_obs=Y*treat_mat
}

est_model_MCPanel <- mcnnm_cv(Y_obs, treat_mat, to_estimate_u = 1, to_estimate_v = 1)
est_model_MCPanel$Mhat <- est_model_MCPanel$L + replicate(T,est_model_MCPanel$u) + t(replicate(N,est_model_MCPanel$v))
mcpanel[i,]<-est_model_MCPanel$Mhat[1,]

## -----
## EN : It does Not cross validate on alpha (only on lambda) and keep alpha = 1 (LASSO).
##      Change num_alpha to a larger number, if you are willing to wait a little longer.
## -----

#est_model_EN <- en_mp_rows(Y_obs, treat_mat, num_alpha = 1)
est_model_EN <- en_mp_rows(Y_obs, treat_mat, num_alpha = 10)
elasticnet[i,]<-est_model_EN[1,]

## -----
## EN_T : It does Not cross validate on alpha (only on lambda) and keep alpha = 1 (LASSO).
##        Change num_alpha to a larger number, if you are willing to wait a little longer.
## -----
est_model_ENT <- t(en_mp_rows(t(Y_obs), t(treat_mat), num_alpha = 1))
elasticnetT[i,]<-est_model_ENT[1,]

## -----
## DID
## -----

est_model_DID <- DID(Y_obs, treat_mat)
DID[i,]<-est_model_DID[1,]

## -----
## ADH
## -----
est_model_ADH <- adh_mp_rows(Y_obs, treat_mat)
ADH[i,]<-est_model_ADH[1,]

}

#write results to stata file
year<-seq(1992,2007,1)
tmcpanel<-t(Yorig-mcpanel)
colnames(tmcpanel)<-paste("mcplacebo", 1:ncol(tmcpanel), sep="")
colnames(tmcpanel)[1]<-"mcpanel"
telasticnet<-t(Yorig-elasticnet)
colnames(telasticnet)<-paste("enplacebo", 1:ncol(telasticnet), sep="")
colnames(telasticnet)[1]<-"elasticnet"
telasticnetT<-t(Yorig-elasticnetT)
colnames(telasticnetT)<-paste("enTplacebo", 1:ncol(telasticnetT), sep="")
colnames(telasticnetT)[1]<-"elasticnetT"
tDID<-t(Yorig-DID)
colnames(tDID)<-paste("DIDplacebo", 1:ncol(tDID), sep="")
colnames(tDID)[1]<-"DID"
tADH<-t(Yorig-ADH)
colnames(tADH)<-paste("ADHplacebo", 1:ncol(tADH), sep="")
colnames(tADH)[1]<-"ADH"
library(foreign)
write.dta(data.frame(cbind(year,tmcpanel,telasticnet,telasticnetT,tDID,tADH)),"results\\mcpanel_energystate.dta")


