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

# district_url = 'https://raw.githubusercontent.com/bernardkung/TeacherSalary/master/PA_Districts.csv'
# district = read_csv(district_url)
# colnames(district) <- gsub(' ', '', colnames(district))    

head(data)
dim(data)

# remove whitespace
colnames(data) <- gsub(' ', '', colnames(data))    
colnames(data)

# find NAs
apply(data, 2, function(x) any(is.na(x)))


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

