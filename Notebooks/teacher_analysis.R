# 
# Bernard Kung
# original source: http://www.openpagov.org/k12_payroll.asp
# filtered by 2015-2016 only
#


library('readr')
library('tidyr')
library('dplyr')
library('ggplot2')

data_url = 'https://raw.githubusercontent.com/bernardkung/TeacherSalary/master/2015_2016_PA_Salaries.csv'
data = read_csv(data_url)

district_url = 'https://raw.githubusercontent.com/bernardkung/TeacherSalary/master/PA_Districts.csv'
district = read_csv(district_url)
colnames(district) <- gsub(' ', '', colnames(district))    

head(data)
dim(data)

# remove whitespace
colnames(data) <- gsub(' ', '', colnames(data))    
colnames(data)

# find NAs
apply(data, 2, function(x) any(is.na(x)))

# coerce AnnualSalary
summary(data)
AnnualSalary <- as.numeric(gsub('[$,]', '', data$AnnualSalary))
head(AnnualSalary)
typeof(AnnualSalary)
data$AnnualSalary <- AnnualSalary

summary(data$AnnualSalary)
hist(data$AnnualSalary)
sum(data$AnnualSalary < 30000)/146744
data[data$AnnualSalary < 50, ]
data[data$AnnualSalary < 1000, ]
unique(data$JobCategory)
unique(data$Position)


# find unique values
data_unique <- apply(data, 2, unique)
lapply(data_unique, length)

# find repeated names
nrow(data)-length(data_unique$Name)    # 2095 rows contain repeated names
name_table <- data.frame(table(data$Name))
colnames(name_table) <- c('Name', 'Freq')
table(name_table$Freq)    # how are the repeated names distributed by repetition

name_table[name_table$Freq==8, 'Name']
data[data$Name %in% name_table[name_table$Freq==8, 'Name'], ]

data[data$Name %in% name_table[name_table$Freq==7, 'Name'], ]

two_names <- data[data$Name %in% name_table[name_table$Freq==2, 'Name'], ]
two_names %>% arrange(by = Name) %>% head()


data[,c('JobCategory', 'Position')] %>% group_by(JobCategory) %>% unique()
data[,c('JobCategory', 'Position')] %>% group_by(JobCategory) %>% tally()

h <- 2*IQR(data$AnnualSalary)*nrow(data)^(-1/3)
bins <- (max(data$AnnualSalary)-min(data$AnnualSalary))/h

ggplot(data, aes(x=AnnualSalary)) +
  geom_histogram(bins = bins, fill = 'steelblue') +
  ggtitle("Histogram of Annual Salaries (2015-2016)") +
  ylab("Count") + xlab("Annual Salary ($100,000)") +
  scale_x_continuous(labels = 0:3) + theme_bw()

ggplot(data, aes(x=AnnualSalary, fill = JobCategory)) +
  geom_histogram(bins = bins) +
  ggtitle("Histogram of Annual Salaries by Category (2015-2016)") +
  ylab("Count") + xlab("Annual Salary ($100,000)") + labs(fill="Job Category") +
  scale_x_continuous(labels = 0:3) + theme_bw()


smmy_category <- data[,c('JobCategory', 'AnnualSalary')] %>% group_by(JobCategory) %>% 
  summarize(
            Min = min(AnnualSalary), 
            FirstQu = quantile(AnnualSalary, 0.25), 
            Med = median(AnnualSalary),
            Avg = mean(AnnualSalary),
            ThirdQu = quantile(AnnualSalary, 0.75),
            Max = max(AnnualSalary))


summ_cat_dist <- data[,c('SchoolDistrict', 'JobCategory', 'AnnualSalary')] %>% 
  group_by(.dots=c('SchoolDistrict', 'JobCategory')) %>% 
  summarize(
    Avg = mean(AnnualSalary)
  ) %>%
  spread(JobCategory, Avg)

colnames(summ_cat_dist) <- c("SchoolDistrict", "Administrators", "Teachers", "Coordinators", "Others")

summ_percdiff <- summ_cat_dist %>% group_by(SchoolDistrict) %>%
  summarize(PercDiff = Administrators/Teachers)

summary(summ_percdiff)

summ_cat_dist[is.na(summ_cat_dist),]
sum(is.na(data$SchoolDistrict))

dist_noadmins <- pull(summ_cat_dist[is.na(summ_cat_dist$Administrators), "SchoolDistrict"])

print.data.frame(data[data$SchoolDistrict %in% dist_noadmins[11],c('Name','SchoolDistrict','JobCategory','Position','AnnualSalary')])
print.data.frame(data[data$SchoolDistrict=="Youth Forestry Camp #2",c('Name','SchoolDistrict','JobCategory','Position','AnnualSalary')])


summ_dist_count <- data %>% group_by(SchoolDistrict) %>% 
  filter(JobCategory %in% c("Administrative / Supervisory", "Classroom Teachers")) %>%
  count(SchoolDistrict, sort= TRUE)

summ_district <- merge(summ_cat_dist, summ_dist_count, by="SchoolDistrict")

summ_cat_dist[,1:3] %>% 
  gather(key= "JobCategory", value = "AvgSalary", -SchoolDistrict) %>%
  group_by(SchoolDistrict) %>%
  ggplot(aes(x=SchoolDistrict, y=AvgSalary, fill=JobCategory)) +
  geom_bar(stat='identity', position = "dodge") +
  coord_flip()

summ_district[,c(1,2,3,6)] %>%
  gather(key="JobCategory", value="AvgSalary", -SchoolDistrict, -n) %>%
  ggplot(aes(x=n, y=AvgSalary, color=JobCategory)) +
  geom_point()



summ_district[,"PercDiff"] <- summ_district$Administrators/summ_district$Teachers

head(summ_district)

# plotting PercDiff by district size
summ_district[,c(1,2,3,6,7)] %>%
  gather(key="JobCategory", value="AvgSalary", -SchoolDistrict, -n, -PercDiff) %>%
  ggplot(aes(x=n, y=PercDiff, color=JobCategory)) +
  geom_point()

# removing philly
cutoff_size <- 1500
summ_district[summ_district$n < cutoff_size,c(1,2,3,6,7)] %>%
  gather(key="JobCategory", value="AvgSalary", -SchoolDistrict, -n, -PercDiff) %>%
  ggplot(aes(x=PercDiff, y=n)) +
  geom_point(aes(size=n), alpha = 0.4, color="tomato") +
  ggtitle("Percent Difference in Salaries of Administrators over Teachers (PA 2015-2016)") +
  ylab("Count") + 
  scale_x_continuous(name="Percent Difference", breaks = 1:3,labels = c("100%", "200%", "300%")) +
  theme_bw()

cutoff_size <- 1500
summ_district[summ_district$n < cutoff_size,c(1,2,3,6,7)] %>%
  gather(key="JobCategory", value="AvgSalary", -SchoolDistrict, -n, -PercDiff) %>%
  ggplot(aes(x=PercDiff)) +
  geom_histogram(fill="#0072B2") +
  ggtitle("Percent Difference in Salaries of Administrators over Teachers (PA 2015-2016)") +
  ylab("Count") + 
  scale_x_continuous(name="Percent Difference", breaks = 1:3,labels = c("100%", "200%", "300%")) +
  theme_bw()

cutoff_size <- 250
summ_district[summ_district$n < cutoff_size,c(1,2,3,6)] %>%
gather(key="JobCategory", value="AvgSalary", -SchoolDistrict, -n) %>%
  ggplot(aes(x=AvgSalary, y=n, color=JobCategory)) +
  geom_point(alpha = 0.4) +
  ylab("Number of District Staff") + 
  scale_x_continuous(name="Average Salary", 
                     breaks = c(50000, 100000, 150000),
                     labels = c("$50000", "$100000", "$150000")) +
  ggtitle("Average Salary vs District Size (PA 2015-2016)") +
  coord_flip() + theme_bw()


head(data)

ggplot(data, aes(x=AnnualSalary, y=YearsInLEA, color=JobCategory)) +
  geom_point(alpha = 0.1, position = position_jitter(w = 0, h = 0.2))

ggplot(data, aes(x=AnnualSalary, y=YearsInEd, color=JobCategory)) +
  geom_point(alpha = 0.1)


Job_LEA_salary <- data %>% group_by(.dots=c("YearsInLEA","JobCategory")) %>% 
  summarize(AverageSalaryByLEA = mean(AnnualSalary)) 

LEA_salary <- data %>% group_by(YearsInLEA) %>% summarize(AverageSalary = mean(AnnualSalary))

Job_Ed_salary <- data %>% group_by(.dots=c("YearsInEd","JobCategory")) %>% 
  summarize(AverageSalaryByEd = mean(AnnualSalary)) 

Ed_salary <- data %>% group_by(YearsInEd) %>% summarize(AverageSalary = mean(AnnualSalary))

ggplot() +
  geom_line(data = Job_LEA_salary, aes(x=YearsInLEA,  y=AverageSalaryByLEA, color=JobCategory)) + 
  geom_point(data = Job_LEA_salary, aes(x=YearsInLEA,  y=AverageSalaryByLEA, color=JobCategory)) +
  geom_line(data=LEA_salary, aes(x=YearsInLEA, y=AverageSalary)) +
  geom_point(data=LEA_salary, aes(x=YearsInLEA, y=AverageSalary))


  ggplot(aes(x=YearsInLEA,  y=AverageSalary)) +
  geom_line() + geom_point()

data %>% group_by(.dots=c("YearsInEd","JobCategory")) %>% 
  summarize(AverageSalaryByEd = mean(AnnualSalary)) %>%
  ggplot(aes(x=YearsInEd,  y=AverageSalaryByEd, color=JobCategory)) +
  geom_line()

