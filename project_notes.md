2015-2016 PA Salaries

Read in data using _read_csv()_ from _library('readr')_
146744 rows, 9 columns

Remove white space from column names; this is a stylistic preference and makes it easier to refer to individual columns. For example, _data$'School District'_ becomes _data$SchoolDistrict_. Of course, similarly useful with square brackets.

I'm also going to run a quick apply to check for NA values. This is strictly preliminary, NA values could also appear as blank fields, entries of 0, or something else depending on style guides.

A quick summary call reveals that most of the dataframe is _char_ columns. That said, the _int_ columns look very clean, no impossibly extreme outliers. However the _AnnualSalary_ column is a _char_ column, and I should convert to an _int_ column.

First step is to remove the '$', so it's time to break out the regex. Very straightforward since the data is clean, which is exactly how I like my regex. Coercing to _int_ at this point introduces error from commas. So going back, instead I'm rewriting my regex to remove '$' and ',' leaving just the digits which easily coerce into integer and we replace the column.
The _summary()_ call now looks pretty reasonable. The only item of possible concern is that the lowest paycheck was $39. Not alarming, but worth a quick check. A simple histogram reveals that the distribution is not unusual. In fact, fewer than 1% of employees were paid less than $30,000. Doing a little investigation, it looks like it's just personnel being paid for small administrative or miscellaneous jobs. Additionally, it's possible a significant number of these are unclassified substitute teachers. Either way, it doesn't seem unreasonable as of yet.

 So because of all the character strings I have to get a little creative instead of doing _summary()_. I'm going to pull all the unique values with an _apply()_. This generates a list, each entry is a sublist of all the unique values for a single column. This list still ends up being pretty big, so I'm going to inspect the lengths of these lists. Name is huge as expected, but I'll get into it later. Lots of school districts, which is potentially very useful for plotting chloropleths. _JobCategory_ and _Position_ seem pretty useful, hopefully sets of _Positions_ are unique to _JobCategory_. Both _YearsinLEA_ and _YearsinED_ are interesting, continuous variables instead too. Finally _HighestDegree_ has 10 unique values, which seems like a lot and might be worth breaking down.

Something I noticed when I initially looked up the CSV is that there are repeated names. My suspicion is that people are filling multiple roles and being paid as such. That said, there's some scenarios I want to consider.

1. Few repeated names. If it's only a few names, I can probably ignore the problem, either by adding the rows or removing the data. It all depends on where I want to go with the other columns.
2. Unusual behavior. It's hard to say going forward what this might entail exactly, but one possible scenario might include a consistent group of people being double-listed erroneously. But you get the idea; basically a significant outlier might exist in these repeated names.
Or significant errors.


146744 rows in data
144649 rows in data_unique$Name, or unique names

2095 names appear in multiple rows, or 1.42% of the data.

name_table
     1      2      3      4      5      6      7      8
142900   1512    180     27     17      5      7      1

Starting from the name repeated 8 times, it actually looks like it's 8 different people who have the same names. So happily I checked because I was completely wrong in a way that seems really obvious in retrospect. At this point, the data looks like it might be really clean.


Filtering for all the unique combinations of _JobCategory_ and _Position_, luckily it appears that _Position_ is indeed a subcategory of _JobCategory_. Overall, this data is looking exactly the way it should coming out of a well-maintained relational database. Noodle around a little bit, but it's time to start looking at the salary.


Two initial plots; first is a histogram of _AnnualSalary_, the second is the same histogram grouped by _JobCategory_. Probably the only thing worth noting is that administrators get paid more than teachers et al, and there's a long tail to the right of mostly administrators. But there's also too much disparity considering this is a state-wide dataset. Probably the ticket is breaking it down by school district, which I wanted to do anyways.

So I'm going to try to get average _AnnualSalary_ by _JobCategory_ for each _SchoolDistrict_.
Initially, I put together an ad hoc _summary()_ call using _dplyr_; but really I only want averages at the moment.

First I'm pulling out the columns I want. Then I group by _SchoolDistrict_ and _JobCategory_ and average _AnnualSalary_. But I want to be able to compare average _AnnualSalary_ between _JobCategory_ for each _SchoolDistrict_. This took a bit of thinking since I don't do a ton of data restructuring (yet). So the _spread()_ command flattens the dataframe so that _SchoolDistrict_ is the Primary Key (PK), and _JobCategory_ are the columns, with each entry being the average _AnnualSalary_. Also, rename the columns just to make everything easier for _dplyr_ piping.

So before I go any further, the most interesting thing is that despite my earlier check, it appears there are NAs that I missed! So what happened? These are average _AnnualSalary_; so while there weren't any missing values in the data, there are some _SchoolDistrict_ missing some _JobCategory_. So while it's good that all _SchoolDistrict_ have teachers, it's interesting that some _SchoolDistrict_ have no ""Administrative / Supervisory" on the payroll. Of course there are also (many more) missing values for "Coordinate Services" aka Coordinators, and "Others".

So to take a closer look, I can pull just the 12 districts without administrator salaries. Since I know nothing about PA school districts, time to do some Google research.

For example: \
* "Ambridge Area SD" is a ["midsized, urban public school district in Beaver County, Pennsylvania"](https://en.wikipedia.org/wiki/Ambridge_Area_School_District). Wikipedia link states 2,822 pupils in the district. Also interesting, a superintendent with salary is listed for the district for the time period of the data.
* "North Central Secure Trmnt Unt" is the North Central Secure Treatment Unit (NCSTU). It's part of the [PA Juvenile Justice System.](http://www.dhs.pa.gov/citizens/juvenilejstcsrvcs/centercamp/)
* "Youth Forestry Camp #3" similarly is part of the [PA Juvenile Justice System.](http://www.dhs.pa.gov/citizens/juvenilejstcsrvcs/centercamp/) Altogether, it looks like there's about 300 beds across all facilities.
* "Wonderland CS" is a charter school in State College, PA. By the looks of it, it's fairly small, easily less than 100 students.

So very interesting. By pulling directly from our original data, it looks like the juvenile facilities maintain just teachers and guidance counselors and may be administrated from outside the education system. Here's the problem: Youth Forestry Camp #2 does have an administrator. Similarly, Wonderland CS has teachers on payroll, but no administrators. There may be something worth digging into here, but frankly I think it's a problem to be shelved for now. 
