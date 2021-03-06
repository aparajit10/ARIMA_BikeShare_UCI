# Time Series forecasting on UCI Bike Share dataset using Box-Jenkins Method
install.packages("forecast")
install.packages("tseries")
install.packages("ggplot2")
install.packages("tseries")
library("forecast","tseries","ggplot2")
library(tseries)
bike_data= read.csv('/Users/aparajit/Desktop/PROJECTS/R/ARIMA/Bike-Sharing-Dataset/day.csv',
                    header = TRUE,stringsAsFactors = FALSE)
# Data Exploration
bike_data$Date=as.Date(bike_data$dteday)
ggplot(bike_data,aes(Date, cnt))+ geom_line()+scale_x_date('month')+
  ylab('Number of bikes')
# Outlier treatment 
count_ts=ts(bike_data[,c('cnt')])
bike_data$clean_cnt=tsclean(count_ts)
ggplot(bike_data,aes(Date, clean_cnt))+ geom_line()+scale_x_date('month')+
  ylab('Number of bikes')
# taking moving averages 
bike_data$ma7_cnt= ma(bike_data$clean_cnt,order = 7)
bike_data$ma30_cnt= ma(bike_data$clean_cnt,order = 30)

ggplot()+
  geom_line(data = bike_data,aes(x= Date,y =clean_cnt,colour='Counts' ))+
  geom_line(data = bike_data,aes(x= Date,y =ma7_cnt,colour='Weekly Moving Avg' ))+
  geom_line(data = bike_data,aes(x= Date,y =ma30_cnt,colour='Monthly Moving Avg' ))

# Data Decomposition 
count_ma=ts(na.omit(bike_data$ma7_cnt), frequency = 30)
decomp=stl(count_ma,s.window = 'periodic')
deseasonal_cnt <- seasadj(decomp)
plot(decomp)
# running dickey- fuller test to check stationarity
adf.test(count_ma, alternative='stationary')
# as a rseult of dicky-fuller test we conclude that series isnt stationary
# as a next step deciding the order of differencing to be applied
acf(count_ma)
pacf(count_ma)
# attempting differencing of order 1 
count_d1 <- diff(deseasonal_cnt,differences = 1)
plot(count_d1)
adf.test(count_d1, alternative='stationary')
# series is stationary with d =1
acf(count_d1)
pacf(count_d1)
# fitting ARIMA model
fit <- auto.arima(deseasonal_cnt,seasonal = FALSE)
# Model Evaluation
tsdisplay(residuals(fit),lag.max = 45,main = '(1,1,1) Residuals')
# significant lag at laf  7 is observed 
fit2 <- arima(deseasonal_cnt,order = c(1,1,7))
fit2
tsdisplay(residuals(fit2),lag.max = 15,main = '(1,1,7) Residuals')
# Forecasting using this model
pred <- forecast(fit2,h = 50)
plot(pred)
# including seasonality in the model
fit3 <- auto.arima(deseasonal_cnt,seasonal = TRUE)
fit3
pred2 <- forecast(fit3,h=30)
plot(pred2)
tsdisplay(residuals(fit3),lag.max = 15,main = '(2,1,2) Residuals')
