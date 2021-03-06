rm(list=ls()) 

setwd("C:/Users/ARON/Desktop/edwisor projects/bike rental")
getwd()

Load Libraries
# x = c("ggplot2", "corrgram", "DMwR", "caret", "randomForest", "unbalanced", "C50", "dummies", "e1071", "Information",
#       "MASS", "rpart", "gbm", "ROSE", 'sampling', 'DataCombine', 'inTrees')
# 
# install.packages(x)
# lapply(x, require, character.only = TRUE)
# rm(x)

library(xlsx)
library(rlang)
library(ggplot2)


data_original=read.csv("day.csv")
data=data_original

########analysing dataset################################################

#let us sse the structure

View(data)

str(data)

colnames(data)
dim(data)

class(data$dteday)



#no of unique values in each variables
apply(data, 2,function(x) length(table(x)))

unique(data$weekday)
unique(data$mnth)

# we can see that season,year,month,holiday,weekday,workingday,weathersit are to converted into factor for proper analysis .

###########################EDA###########################################

#let us convert the required dtype into factor

fact_names=c('season','yr','mnth','holiday','weekday','workingday','weathersit')

for (i in fact_names){
  print(i)
  data[,i]=as.factor(data[,i])
}
str(data)

#let us convert the integer into numeric dtype
data$instant=as.numeric(data$instant)
data$casual=as.numeric(data$casual)
data$registered=as.numeric(data$registered)
data$cnt=as.numeric(data$cnt)

#let us convert date into date dtype
#data$dteday=as.Date(data$dteday)


str(data)


#getting all numeric varaibles together
num_index = sapply(data, is.numeric)
num_data = data[,num_index]
num_col = colnames(num_data) #storing all the column name

#getting all categorical variables together

cat_ind=sapply(data, is.factor)
cat_data=data[,cat_ind]
cat_col= colnames(cat_data)

str(data)

num_col
cat_col



# #####analysing data (univariate)##########################

#let us see the distribution of  target variable
hist(data$cnt)
#we see that, the target variable is normally distributed


hist(data$temp)
hist(data$atemp)
hist(data$windspeed)
#most of the data is normally distributed





###############analysing data (bivariate)##########################

names(data)

#let us see if the count in the rental bikes depends on the season

boxplot(data$cnt~data$season,xlab="seasons",ylab="count",mail="")
#we see that the bikes for rental are high in season3 (fall), followed by season2(summer),and season4 (winter), bike rentals are very less in season 1(spring)


#let us see which year had more bikes rented

boxplot(data$cnt~data$yr,xlab="year",ylab="count",mail="")
#compared to 2011, most of the bikes were rented in 2012



#let us see which month has the more bikes rented
boxplot(data$cnt~data$mnth,xlab="year",ylab="count",mail="")
#september had more number of bikes rented, which relates to our hypothesis by analysing season


#let us see whethere the bikes are rented more in working days or holidays
boxplot(data$cnt~data$workingday,xlab="workingday",ylab="count",mail="")
#there is almost similar bike renting at both the days



#let us see on which day in a week the bikes are rented the most
boxplot(data$cnt~data$weekday,xlab="weekday",ylab="count",mail="")
#the data distribution is almost similar on all days, let us check the casual and registered users

boxplot(data$casual~data$weekday,xlab="weekday",ylab="casual users",mail="")
#we see that the most of the bikes are rented by the casual users during the weekend (i.e. saturday, sunday followed by friday)
boxplot(data$registered~data$weekday,xlab="weekday",ylab="registered users",mail="")
#registered users data is almost uniform

#let us see how does the number of bike rental users depends on the weather condition
boxplot(data$cnt~data$weathersit,xlab="weather",ylab=" count",mail="")
#we see that the most of the users rent bikes during clean whether and less users during rainy weather and when the weather is bad there is 0 instance of users 


#let us see if the temperature affects the count of users renting bike
plot(data$cnt,data$temp)
#the scatter plot shows that,as the temperature increases, the count increase
plot(data$cnt,data$atemp)
#the scatter plot shows that,as the feeling temperature increases, the count increase



#let us see if humidity affects the count of bikes
plot(data$cnt,data$hum)
#humidity doesnt affect the count





####### missing value analysis and outlier analysis##############


#checking missing value
apply(data,2,function(x){sum(is.na(x))})

#From missing value analysis we see that there are no missing values in the data


library(DMwR)
library(lattice)
library(grid)

#let us first check outliers 

library(ggplot2)

for (i in 1:length(num_col))
{
  assign(paste0("gn",i),
         ggplot(aes_string(y = (num_col[i]), x = 'cnt'),data = data) +
           stat_boxplot(geom = "errorbar", width = 0.5) +
           geom_boxplot(outlier.colour="blue", fill = "skyblue",
                        outlier.shape=18,outlier.size=1, notch=FALSE) +
           labs(y=num_col[i],x="cnt")+
           ggtitle(paste("box plot for count",num_col[i])))
}



## Plotting plots together


gridExtra::grid.arrange(gn1,gn2,gn3,ncol=3)
gridExtra::grid.arrange(gn4,gn5,gn6,ncol=3)
gridExtra::grid.arrange(gn7,gn8,ncol=2)

#we see that the humidity,windspeed casual variable has outliers, out of which we are removing casual in future as the casual and registered variables sums up to explain the target variable.
#there are two variables in humidity, let us see the two variables
boxplot.stats(data$hum,coef=1.5)
#outliers are 0.187917 and 0, so let us remove them
data$hum[data$hum %in% boxplot.stats(data$hum)$out] = NA

boxplot.stats(data$windspeed,coef=1.5)
#there are 13 variables in windspeed, so let us remove them
data$windspeed[data$windspeed %in% boxplot.stats(data$windspeed)$out]=NA



# #checking all the missing values
library(DMwR)
sum(is.na(data))
data = knnImputation(data, k=3)  

# let us check missing values left  
apply(data,2,function(x){sum(is.na(x))})
dim(data)



#let us check if the outliers have been removed or not
boxplot(data$hum)
boxplot(data$windspeed)

#so, the outlier has been removed

#######feature selection###########################

library(corrgram)


corrgram(data[,num_index],
         order = F,  #we don't want to reorder
         upper.panel=panel.pie,
         lower.panel=panel.shade,
         text.panel=panel.txt,
         main = 'CORRELATION PLOT')
#We can see var the highly corr related var in plot marked dark blue. 
#Dark blue color means highly positive correlated
#we see that that the temp is highly correlated to atemp, so let us remove temp


##---------anova ----------------------------------
names(data)
colnames(cat_data)


#Anova test
library("lsr")
anova_test=aov(cnt~season+yr+mnth+holiday+weekday+
                 workingday+weathersit,data = data)


summary(anova_test)

####################Removing Highly Corelated and Independent var##################
#we will remove instant and date variable as they are unique and dont exolain much about the target variable
#Also, we will remove casual and registered variable as they sum up to give the target variable total count of bikes
#as temp is highly correlated to atemp we will remove atemp

data= subset(data,select= -c(instant,dteday,atemp,casual,registered))

colnames(data)
str(data)
da
#####feature scaling######################

View(data)
#we see that the data is already normalized, so the data is ready to be fitted in the model for development



############model development##########################

####decision tree########

library(MASS)
library(rpart)

train_index= sample(1:nrow(data),0.8*nrow(data))
train= data[train_index,]
test= data[-train_index,]

DT_regression=rpart(cnt ~.,data=train,method="anova")

summary(DT_regression)

DT_predict=predict(DT_regression,test[,-11])


#evaluate
View(test[,11])

#install.packages("DMwR")

library(DMwR)
regr.eval(test[,11],DT_predict,stats = c("mae","mape","rmse"))

#mae        mape        rmse 
#670.8904240   0.2206328 965.9852495 

####random forest######

library(randomForest)

rf_model= randomForest(cnt~.,train,importance=TRUE,ntree=100)

summary(rf_model)

rf_predict=predict(rf_model,test[,-11])


regr.eval(test[,11],rf_predict,stats = c("mae","mape","rmse"))

#mae        mape        rmse 
#496.1101195   0.1649831 694.3410299

####linear regression#######


library(usdm)


lm_model= lm(cnt~.,data=train)

summary(lm_model)

lm_predict=predict(lm_model,test[,-11])


regr.eval(test[,11],lm_predict,stats = c("mae","mape","rmse"))

#mae        mape        rmse 
#598.3067621   0.1812669 807.3537860 







