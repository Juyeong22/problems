# Kaggle.com 
# Competition
# < Bike Sharing Demand >

# ���̳� �ð� 2�ð�
# ���� : 1�� 17�� ����� ����.
# ����Ǫ�� �ð�. ĳ�� �Ұ�, ���� ����, ������ �ְ�, ����
# �߰��߰� �̸� �غ��� �ڵ� �����ָ� ����ֱ�. ��ü ���μ��� ����

# 1. ��Ȳ �ľ��ϱ�(�����ͼ� �ҷ�����)

sample_submission = read.csv("sampleSubmission.csv", header = TRUE)
test = read.csv("test.csv", header = TRUE)
train = read.csv("train.csv", header = TRUE)

head(sample_submission, 20) # ���� ������ Ȯ���غ��ô�.
head(train, 20) # �� ���� �����ͼ��� Ȯ���غ��ô�.
head(test, 20) # ���� �����ͼ��� Ȯ���غ��ô�.

summary(train)
summary(test)
summary(sample_submission)

# 2. ��ǥ ���ϱ�

# �츮�� �����ؾ� �� ������?

head(sample_submission)
# count �Դϴ�.


# �� ������ ���� ����!

# join $ -> take -> ride -> return

# datetime - hourly date + timestamp  
# season -  1 = spring, 2 = summer, 3 = fall, 4 = winter 
# holiday - whether the day is considered a holiday
# workingday - whether the day is neither a weekend nor holiday
# weather - 1: Clear, Few clouds, Partly cloudy 
#           2: Mist + Cloudy, Mist + Broken clouds, Mist + Few clouds, Mist 
#           3: Light Snow, Light Rain + Thunderstorm + Scattered clouds, Light Rain + Scattered clouds 
#           4: Heavy Rain + Ice Pallets + Thunderstorm + Mist, Snow + Fog 
# temp - temperature in Celsius
# atemp - "feels like" temperature in Celsius
# humidity - relative humidity
# windspeed - wind speed
# casual - number of non-registered user rentals initiated
# registered - number of registered user rentals initiated
# count - number of total rentals


# �� �� �˾ƺ���

sub_date = as.data.frame(substr(train[,"datetime"], 1, 10))

sub_unique_date = unique(sub_date)
start_end = c(as.character(sub_unique_date[1,]), as.character(sub_unique_date[nrow(sub_unique_date),]))
start_end # ������, ������ Ȯ��

difftime(sub_unique_date[nrow(sub_unique_date),1], sub_unique_date[1,1])
nrow(sub_unique_date) # ���۰� ���� ���̴� 718��, ���� ������ 456��. �� 40%������ �����Ͱ� ����.


nchar(as.character(train[1,1])) # �� ���ڷ� �ð��� ǥ���Ǿ����� Ȯ���غ��ô�.
train_sub_date = as.data.frame(substr(train[,1], 1, 10))  # ��¥
train_sub_year = as.data.frame(as.numeric(substr(train[,1], 1, 4)))  # �⵵
train_sub_month = as.data.frame(as.numeric(substr(train[,1], 6, 7)))  # ��
train_sub_day = as.data.frame(as.numeric(substr(train[,1], 9, 10)))  # ��
train_sub_hour = as.data.frame(as.numeric(substr(train[,1], 12, 13)))  # �ð�

head(train_sub_date) # �ð� Ȯ�� ����

train_sub = cbind(train_sub_date, train_sub_year, train_sub_month, train_sub_day, train_sub_hour, train[,2:ncol(train)])
head(train_sub)

colnames(train_sub) = c("date", "year", "month", "day", "hour", colnames(train_sub)[6:ncol(train_sub)]) # �̸� �ٲ��ֱ�
head(train_sub)


# �������� ���� ����!

summary(train_sub) # ����ġ(NA)�� ����.

year_unique = unique(train_sub$year)
month_unique = unique(train_sub$month)

year_unique
month_unique


table(train_sub$hour) # �ð� ���� ���ڰ� �ٸ� -> �����Ͱ� ���ݾ� ����.
max(table(train_sub$hour)) # �ִ밪 = 456. ����ġ�� ���� ����� ������ ������ 456�� �� �ִ�.

# �����ͼ�[ �� ��ȣ , �� ��ȣ]
train_sub[1:24 , 1:4]
train_sub[25:35 , 1:4] # �ټ����� �����Ͱ� ����!!


# Calendar ���̱�
# 2011��, 2012�� �޷��� �ҷ��´�.

calendar = read.csv("2011_2012_calendar.csv", header = TRUE)
head(calendar)

calendar_2 = as.data.frame(matrix(NA, nrow=nrow(calendar)*24, ncol=ncol(calendar)+1))
head(calendar_2)

# 0�� ���� 23�� ���� ���ڸ� �����鼭 24��� �ÿ��� �Ѵ�.

matrix_hour = matrix(c(seq(0,23,1)), nrow=24, ncol=1)

for(n in 1:nrow(calendar))
{
  if(n == 1)
  {
    calendar_2[1:24,1:10] = calendar[1,]
    calendar_2[1:24,11] = matrix_hour
  } else {
    calendar_2[(24*(n-1)+1):(24*n), 1:10] = calendar[n,]
    calendar_2[(24*(n-1)+1):(24*n), 11] = matrix_hour
  }
  
}

head(calendar_2)

colnames(calendar_2) = c("year", "month", "day", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "hour")
head(calendar_2)

calendar_3 = calendar_2[,c(1,2,3,11,seq(4,10,1))] # ���� �ִ� "hour" column�� "day" ���� �ڷ� �Ű��ݽô�.
head(calendar_3)

# �����ͼ��� �����غ��ô�.

# install.packages("plyr")
library("plyr")

head(train_sub)
head(calendar_3) # ����Ǵ� column�� Ȯ��.

train_calendar_join = join(calendar_3, train_sub, type = "left")
head(train_calendar_join, 50) # 30��° row�� ����ġ(NA) Ȯ�� ����

write.csv(train_calendar_join, "train_calendar_join.csv", row.names = FALSE)


train_calendar_join = train_calendar_join[is.na(train_calendar_join$season) == 0,]

train_2 = train_calendar_join

# install.packages("ggplot2")
library("ggplot2")


ggplot(train_2, aes(x=factor(month), y=casual)) + geom_boxplot()
ggplot(train_2, aes(x=factor(month), y=registered)) + geom_boxplot()


ggplot(train_2, aes(x=factor(hour), y=casual)) + geom_boxplot()
ggplot(train_2, aes(x=factor(hour), y=registered)) + geom_boxplot()


month = 1
ggplot(train_2[train_2$month == month,], aes(x=factor(hour), y=casual)) + geom_boxplot()
ggplot(train_2[train_2$month == month,], aes(x=factor(hour), y=registered)) + geom_boxplot()


hour = 3
ggplot(train_2[train_2$hour == hour,], aes(x=factor(month), y=casual)) + geom_boxplot()
ggplot(train_2[train_2$hour == hour,], aes(x=factor(month), y=registered)) + geom_boxplot()

ggplot(train_2[train_2$Tue == 1,], aes(x=factor(hour), y=casual)) + geom_boxplot()
ggplot(train_2[train_2$Tue == 1,], aes(x=factor(hour), y=registered)) + geom_boxplot()

ggplot(train_2[train_2$Sat == 1,], aes(x=factor(hour), y=casual)) + geom_boxplot()
ggplot(train_2[train_2$Sat == 1,], aes(x=factor(hour), y=registered)) + geom_boxplot()

ggplot(train_2[train_2$Sun == 1,], aes(x=factor(hour), y=casual)) + geom_boxplot()
ggplot(train_2[train_2$Sun == 1,], aes(x=factor(hour), y=registered)) + geom_boxplot()


write.csv(train_2, "train_2.csv", row.names = FALSE)

train_2 = read.csv("train_2.csv", header = TRUE)
head(train_2)


# �ܿ￡�� ��ٽð��� registered�� �̿��� ����.
# �ܿ� �̿ܿ��� ��ٽð��� registered�� �̿��� ����.

# �ָ����� registered�� �뿩������ casual�� ����ϴ�.

# casual�� ������ ������� ���ɽð� ���� 1~2�ÿ� �ְ����� ��� ����� ����

# casual�� registered�� ��踦 ���� �����.
# ������ ���Ͽ� ���� / �ð��� / ���Ϻ� ��踦 ���� �����.

colnames(train_2)
train_2_month = train_2[, c(2:11, 21, 22)]
train_2_hour = train_2[, c("hour", "casual", "registered")]
train_2_weekday = train_2[train_2$Sat != 1 & train_2$Sun != 1, c("Mon", "Tue", "Wed", "Thu", "Fri", "hour", "casual", "registered")]
train_2_weekend = train_2[train_2$Sat == 1 | train_2$Sun == 1, c("Sat", "Sun", "hour", "casual", "registered")]

fix(train_2_weekday)

agg_month = aggregate(train_2_month[, c("casual", "registered")], by = list(train_2_month[, "month"]), mean)  # <-- �ԷµǴ� �����ͼ��� nrow�� 'by =' �� ���� ����Ʈ ���̰� ���ƾ� �Ѵ�.
agg_hour = aggregate(train_2_hour[, c("casual", "registered")], by = list(train_2_hour[, "hour"]), mean)
agg_weekday = aggregate(train_2_weekday[, c("casual", "registered")], by = list(train_2_weekday[, "hour"]), mean)

agg_mon = aggregate(train_2_weekday[train_2_weekday$Mon == 1, c("casual", "registered")], by = list(train_2_weekday[train_2_weekday$Mon == 1, "hour"]), mean)
agg_tue = aggregate(train_2_weekday[train_2_weekday$Tue == 1, c("casual", "registered")], by = list(train_2_weekday[train_2_weekday$Tue == 1, "hour"]), mean)
agg_wed = aggregate(train_2_weekday[train_2_weekday$Wed == 1, c("casual", "registered")], by = list(train_2_weekday[train_2_weekday$Wed == 1, "hour"]), mean)
agg_thu = aggregate(train_2_weekday[train_2_weekday$Thu == 1, c("casual", "registered")], by = list(train_2_weekday[train_2_weekday$Thu == 1, "hour"]), mean)
agg_fri = aggregate(train_2_weekday[train_2_weekday$Fri == 1, c("casual", "registered")], by = list(train_2_weekday[train_2_weekday$Fri == 1, "hour"]), mean)
agg_sat = aggregate(train_2_weekend[train_2_weekend$Sat == 1, c("casual", "registered")], by = list(train_2_weekend[train_2_weekend$Sat == 1, "hour"]), mean)
agg_sun = aggregate(train_2_weekend[train_2_weekend$Sun == 1, c("casual", "registered")], by = list(train_2_weekend[train_2_weekend$Sun == 1, "hour"]), mean)

colSums(agg_mon)

day_list = c("mon", "tue", "wed", "thu", "fri", "sat", "sun")
day_list_2 = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

for(n in 1:length(day_list))
{
  agg_sub = get(paste0("agg_", day_list[n]))
  col_max = apply(agg_sub, 2, max)
  
  for(m in 2:3)
  {
    agg_sub[,m] = round(agg_sub[,m]/as.numeric(col_max[m]), 2)
  }
  
  assign(paste0("agg_", day_list[n]), agg_sub)
}

# install.packages("ggplot2")
library("ggplot2")

agg_casual_cbind = as.data.frame(cbind(c(1:24), agg_mon[,2], agg_tue[,2], agg_wed[,2], agg_thu[,2], agg_fri[,2], agg_sat[,2], agg_sun[,2] ))
agg_registered_cbind = as.data.frame(cbind(c(1:24), agg_mon[,3], agg_tue[,3], agg_wed[,3], agg_thu[,3], agg_fri[,3], agg_sat[,3], agg_sun[,3] ))

colnames(agg_casual_cbind) = c("Hour", day_list_2)
colnames(agg_registered_cbind) = c("Hour", day_list_2)


# install.packages("reshape")
library("reshape")

agg_casual_melt = melt(agg_casual_cbind, id = "Hour")
agg_registered_melt = melt(agg_registered_cbind, id = "Hour")

head(agg_casual_melt)

ggplot(agg_casual_melt, aes(x = agg_casual_melt$Hour, y = agg_casual_melt$value, color = agg_casual_melt$variable)) + geom_line(size = 1) + geom_point(size = 3) + xlab("Hour") + ylab("Rantal Ratio") + theme(legend.position = c(0.12, 0.8)) 
ggplot(agg_registered_melt, aes(x = agg_registered_melt$Hour, y = agg_registered_melt$value, color = agg_registered_melt$variable)) + geom_line(size = 1) + geom_point(size = 3) + xlab("Hour") + ylab("Rantal Ratio") + theme(legend.position = c(0.13, 0.8)) 

##################################

# ���� - ���Ϻ�

head(train_2_month)

agg_month_mon = aggregate(train_2_month[train_2_month$Mon == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Mon == 1, "month"]), mean)
agg_month_tue = aggregate(train_2_month[train_2_month$Tue == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Tue == 1, "month"]), mean)
agg_month_wed = aggregate(train_2_month[train_2_month$Wed == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Wed == 1, "month"]), mean)
agg_month_thu = aggregate(train_2_month[train_2_month$Thu == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Thu == 1, "month"]), mean)
agg_month_fri = aggregate(train_2_month[train_2_month$Fri == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Fri == 1, "month"]), mean)
agg_month_sat = aggregate(train_2_month[train_2_month$Sat == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Sat == 1, "month"]), mean)
agg_month_sun = aggregate(train_2_month[train_2_month$Sun == 1, c("casual", "registered")], by = list(train_2_month[train_2_month$Sun == 1, "month"]), mean)

for(n in 1:length(day_list))
{
  agg_sub = get(paste0("agg_month_", day_list[n]))
  col_max = apply(agg_sub, 2, max)
  
  for(m in 2:3)
  {
    agg_sub[,m] = round(agg_sub[,m]/as.numeric(col_max[m]), 2)
  }
  
  assign(paste0("agg_month_", day_list[n]), agg_sub)
}

agg_month_casual_cbind = as.data.frame(cbind(c(1:12), agg_month_mon[,2], agg_month_tue[,2], agg_month_wed[,2], agg_month_thu[,2], agg_month_fri[,2], agg_month_sat[,2], agg_month_sun[,2] ))
agg_month_registered_cbind = as.data.frame(cbind(c(1:12), agg_month_mon[,3], agg_month_tue[,3], agg_month_wed[,3], agg_month_thu[,3], agg_month_fri[,3], agg_month_sat[,3], agg_month_sun[,3] ))

colnames(agg_month_casual_cbind) = c("Month", day_list_2)
colnames(agg_month_registered_cbind) = c("Month", day_list_2)

# install.packages("reshape")
library("reshape")

agg_month_casual_melt = melt(agg_month_casual_cbind, id = "Month")
agg_month_registered_melt = melt(agg_month_registered_cbind, id = "Month")

head(agg_month_casual_melt)


Weekday = agg_month_casual_melt$variable
ggplot(agg_month_casual_melt, aes(x = agg_month_casual_melt$Month, y = agg_month_casual_melt$value, color = Weekday)) + geom_line(size = 1) + geom_point(size = 3) + xlab("Month") + ylab("Rantal Ratio") + theme(legend.position = c(0.05, 0.8)) 

Weekday = agg_month_registered_melt$variable
ggplot(agg_month_registered_melt, aes(x = agg_month_registered_melt$Month, y = agg_month_registered_melt$value, color = Weekday)) + geom_line(size = 1) + geom_point(size = 3) + xlab("Month") + ylab("Rantal Ratio") + theme(legend.position = c(0.05, 0.8)) 



##########################################
# �Ļ������� : factor_x
#              �µ�, ����, ǳ���� �����Ͽ� ����� ���ο� ����
# �߰��۾� : �׷��� �׷�����

ncol(train_2)
# ������ ���� ����� �Է��� ���ô�.
# train_2[,ncol(train_2)+1] = round(���_1 * train_2$temp + ���_2 * train_2$humidity + ���_3 * train_2$windspeed, 3)

colnames(train_2) = c(colnames(train_2)[1:(ncol(train_2)-1)], "factor_x")
head(train_2)

plot(train_2$hour, train_2$factor_x)
plot(train_2$month, train_2$factor_x)
plot(1:nrow(train_2), train_2$factor_x)



######################################
# �Ļ������� : work_holi_wtr
#              ������, ����, ������ �����Ͽ� ���ο� ���� ����
#

head(train_2)


######################################
# ǥ��ȭ �ϱ�
# casual, registered ������ log�� ���� ���� 1�� ���ϰ�...
# ���ϰ� ���õ� ��� �������� ����
#
# ��� �������� z-score�� ��ȯ
# z = (x - mean)/stdev
#
# sd(x, na.rm = FALSE)
# sapply( ������, sd)
# colMeans( ������ )


colnames(train_2)
train_2 = train_2[,16:ncol(train_2)]
head(train_2)




#install.packages("car")
library("car")

######################################
# ȸ��ȸ��

colnames(train_2_score_join)
lm_train = lm(casual ~ weather + weather + temp + humidity + windspeed + factor_x + h_score, data = train_2_score_join)
summary(lm_train)
vif(lm_train)

lm_train = update(lm_train, ~ . -factor_x)
summary(lm_train)
vif(lm_train)


######################################
# ȸ�ͽ����� �����ϱ�.

# train �����ͷ� ���� ȸ�ͽ����� test �������� ����� ����
# test = read.csv("test.csv", header = TRUE)

head(test)
summary(test)


prediction = predict(lm_train, test_score_join)
head(prediction)

prediction = round(prediction,0)
prediction = abs(prediction)
head(prediction)

prediction_cbind = cbind(test$datetime, as.data.frame(prediction))
head(prediction_cbind)

head(sample_submission)
colnames(prediction_cbind) = c("datetime", "count") 
head(prediction_cbind)


######################################
# ����� ���� ���� �����!!!

write.csv(prediction_cbind, "submission.csv", row.names = FALSE)


# ����!!!



# �׸���.. ������ �ݺ�...


# ��� ���������� ����� �м��� �Ѵٸ�?
# �� ���� ���� ��ĥ ��.
# 
# casual - number of non-registered user rentals initiated
# registered - number of registered user rentals initiated
# count - number of total rentals
#
# count = casual + registered
#
# ��, casual ���� �����ϱ� ���� �𵨰� registered ���� �����ϱ� ���� ���� ���� ����
# �� ��� ���� ���Ͽ� submission ������ ���� ��.


# ����
# assign(), get()