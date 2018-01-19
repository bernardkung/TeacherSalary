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


Filtering for all the unique combinations of _JobCategory_ and _Position_, luckily it appears that _Position_ is indeed a subcategory of _JobCategory_. Overall, this data is looking exactly the way it should coming out of a well-maintained relational database. 
