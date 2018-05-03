---
layout: post
title: Fresh Legs or Spaghetti Legs?
date: 2018-04-16
category: Sports
tags: nba, basketball, data-viz
---
The NBA playoffs are in full swing. I saw an [interesting graphic](https://fansided.com/2018/04/13/nylon-calculus-playoffs-west-talent-advantage/) that compared the star power among the 16 playoff teams. I thought it would be interesting to modify this graphic to look at which teams rely most heavily on their starters. After an 82 game regular season, minutes played start to add up and can take a toll on players' bodies. In the figure below, we can see the total minutes played for each playoff starter. Note that the plot reflects starting lineups from Game 1 of the playoffs, so Curry and Embiid are not represented in the graphic. 




```r
library(ggplot2)
library(RCurl)
library(ggthemes)
library(dplyr)

df = read.csv(text=getURL("https://raw.githubusercontent.com/jskaza/data/master/nba-minutes/minutes.csv"))

df$Team = factor(df$Team, levels = c("TOR","BOS","PHI","CLE",
                                     "IND","MIA","MIL","WAS",
                                     "MIN", "SAS","NOP","UTA",
                                     "OKC","POR","GSW","HOU"))
df$Pos = factor(df$Pos, levels = c("PG","SG","SF","PF","C"))
ggplot(df, aes(x=Team,y=Min,group=Pos,fill=Team)) + 
  geom_bar(stat="identity", position=position_dodge()) + 
  coord_polar() + theme_solarized() + 
  scale_fill_manual(values=c("#BA0C2F", "#007A33", "#003DA5",
                              "#6F263D", "#FFCD00", "#862633",
                              "#00471B", "#0C2340", "#005083",
                              "#C6CFD4", "#85714D", "#FFA300",
                              "#0072CE", "#C8102E", "#FFC72C",
                              "#BA0C2F")) +
  theme(legend.position="none") + 
  labs(title = "Minutes Played by Starting 5, Playoff Teams",
       caption = "Source: Basketball Reference", 
       x = "", y = "Minutes") 
```

<img src="{{ site.url }}/images/nba-minutes-plot-1.png" title="plot of chunk plot" alt="plot of chunk plot" width="100%" />

We can see that LeBron is leading a cast without many regular season minutes. We will see if this indicates fresh legs or inexpereince and rustiness. Additionally, we see that the Timberwolves have relied most heavily on their starting five. Heavy workloads for starters is of course a trademark of Tom Thibodeau-coached teams.  


```r
df %>% 
  group_by(Team) %>% 
  summarise(Total = sum(Min)) %>%
  arrange(-Total)
```

```
## # A tibble: 16 x 2
##      Team Total
##    <fctr> <int>
##  1    MIN 13098
##  2    OKC 12001
##  3    MIL 12000
##  4    POR 11787
##  5    IND 11477
##  6    NOP 11439
##  7    UTA 11439
##  8    HOU 10982
##  9    WAS 10862
## 10    PHI 10861
## 11    TOR 10522
## 12    MIA 10426
## 13    BOS 10420
## 14    SAS 10128
## 15    CLE  9933
## 16    GSW  9355
```
