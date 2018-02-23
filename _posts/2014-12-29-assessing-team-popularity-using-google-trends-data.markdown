---
layout: post
title: "Assessing Team Popularity Using Google Trends Data"
date: 2014-12-29 20:56
categories: Sports
tags: anova, four major sports, google trends, popularity, wordpress
---

I recently completed a small project in which I analyzed the popularity
of teams that compete in the four major sports. In the analysis, I
looked at metropolitan areas that have at least [one team in each of the
four major
sports](http://en.wikipedia.org/wiki/U.S._cities_with_teams_from_four_major_league_sports "one team in each of the four major sports"). Using
[Google Trends](http://www.google.com/trends/ "Google Trends"), I
gathered weekly data from 01/02/05 - 11/01/14 to assess the relative
popularity of teams in cities that met the inclusion criteria. Each data
point represents how frequently a team was queried on Google relative to
the Miami Heat in the week of 06/16/13 – 06/22/13. This data point
was set to 100. More importantly, higher numbers indicate a higher
search frequency and, for all intents and purposes, greater popularity.
Below, I've included a heat map that illustrates the contrasts in
average popularity among city-sport combinations over the time period.
Note that for cities home to more than one team in a given sport, I took
the maximum team score each week. For instance, if the Yankees had a
popularity score of 10 in one week and the Mets had a score of 5 in the
same week, I would set the Yankees' score to be the New York baseball
score for that week.

[![popularity](https://jskaza.files.wordpress.com/2014/12/popularity.png)](https://jskaza.files.wordpress.com/2014/12/popularity.png)

R code I used to produce the heatmap (will require the ``gplots`` and
``RColorBrewer`` libraries):

```r
row.names(all.data) <- all.data$City
all.data <- all.data[,-1]
scaleyellowred <- colorRampPalette(c("lightyellow", "red"), space = "rgb")(100)
heatmap.2(as.matrix(all.data), Rowv = NA, Colv = NA, col = scaleyellowred, density.info="none",
          trace="none", cexRow=0.8, cexCol=1, margins=c(6,6))
```

In my statistical analysis, I used three-way between-subjects ANOVA
(with a season variable as a block) to assess whether certain cities and
sports attract significantly greater levels of interest. I performed
this analysis using data only from the year 2013. Furthermore, to
account for violations of the normality
[assumption](http://en.wikipedia.org/wiki/Analysis_of_variance#Assumptions_of_ANOVA "assumption"),
I performed a log transformation on the data. This did not affect the
interpretability of results because, as alluded to above, the numeric
quantities themselves added little value to the analysis. Additionally,
the ordinal relationships remained intact after the log transformation.
Here
are [slides](https://www.dropbox.com/s/l9q7zmvy9dn02cr/Analysis%20of%20Sports%20Teams%20in%20Four-Sport%20Cities.pdf?dl=0 "slides") with
results from the project and the [raw
data](https://www.dropbox.com/s/9q9r43qmwrmkad7/City%20Data.zip?dl=0 "raw data")
from Google Trends.
