---
layout: post
title: Assessing NBA Mock Drafts
date: 2016--07-08 12:22
category: Sports
tags: basketball, nba, statistics, correlation, draft, mock
---

I know most have probably shifted their attention to free agency, but here is my late contribution to the NBA Draft discussion.

In the days after the NBA Draft it is very common to come across many different sets of rankings or grades intended to assess the level of success of each NBA team's particular draft night. These are fun to read and discuss but, in most cases, we will not know the true winners and losers for some time. The Thunder seemed to have a great night, but who knows if [Domantas Sabonis](http://espn.go.com/nba/player/_/id/3155942/domantas-sabonis) will follow in the footsteps of his pops, [Arvydas](https://www.youtube.com/watch?v=LW9q-0x2gu8), and become an all-timer or not. It will take years to tell.  

However, the conclusion of the NBA Draft does allow us to determine a different set of winners and losers. Namely, we can determine which mock drafts performed best, as the completion of the actual draft presents us with validation data to score predictions. There was an [article on Nylon Calculus](http://nyloncalculus.com/2016/06/28/grading-the-2016-nba-mock-drafts/) which did just this; i.e., ranked several of the popular mock drafts based on accuracy. The article experimented with several methods&mdash;number of "hits" (correct predictions), Root Mean Squared Error (RMSE), and what I'll call a weighted absolute error. 

Here, I decided to take a different approach and see how it compared. I used data from 8 of the 10 sites listed in the Nylon Calculus article:

- [~~Chad Ford (ESPN)~~](http://espn.go.com/nba/insider/story/_/id/16436916/chad-ford-nba-mock-draft-10-picks-boston-celtics-los-angeles-lakers-minnesota-timberwolves-more)
- [DraftExpress](http://www.draftexpress.com/nba-mock-draft/2016/)
- [Gary Parrish (CBS)](http://www.cbssports.com/nba/news/nba-mock-draft-2016-lsus-ben-simmons-to-the-sixers-at-no-1-looks-to-be-done/)
- [Sam Vecenie (CBS)](http://www.cbssports.com/nba/draft/mock-draft/expert/sam-vecenie)
- [Scott Howard-Cooper (NBA.com)](http://www.nba.com/2016/news/features/scott_howard_cooper/06/23/2016-nba-mock-draft-4-0/)
- [Andrew Sharp (SI)](http://www.si.com/nba/2016/06/23/nba-mock-draft-trades-buzz-ben-simmons-dragan-bender-brandon-ingram)
- [~~Hoopshype~~](http://hoopshype.com/2016/06/22/nba-mock-draft-2016/)
- [Jonathan Wasserman (Bleacher Report)](http://bleacherreport.com/articles/2647672-2016-nba-mock-draft-jonathan-wassermans-final-2-round-predictions/page/2)
- [NBADraft.net](http://www.nbadraft.net/2016mock_draft)
- [NBADraft.net User Consensus](http://www.nbadraft.net/nba_mock_drafts/consensus)

### The Basics of Correlation 

Correlation deals with the relationship between two random variables. Correlation coefficients measure the strength of association between variables by assigning a number between -1 and 1. Generally speaking, correlation coefficients close to -1 represent strong inverse relationships, correlation coefficients close to 0 represent little association between the variables,  while correlation coefficients close to 1 represent strong positive relationships between the variables. There are three *main* flavors of the correlation coefficient used in statistics: Pearson, Spearman, and Kendall. Here, we will denote these as $r$, $\rho$, and $\tau$, respectively. 

[$r$ is the most familiar form of correlation](https://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient). It simply measures the linear association between two variables, $X$ and $Y$. 

$$ r_{XY} = \frac{\sum_{i=1}^n (x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum_{i=1}^n (x_i - \bar{x})^2}\sqrt{\sum_{i=1}^n (y_i - \bar{y})^2}} $$

where:
- $n$ is the number of observations
- $x_i$ is the $i^{th}$ observation of the variable $X$
- $y_i$ is the $i^{th}$ observation of the variable $Y$
- $\bar{x} = \frac{1}{n} \sum_{i=1}^n x_i$
- $\bar{y} = \frac{1}{n} \sum_{i=1}^n y_i$

Below is an example of this calculation on a simulated dataset intended to be negatively correlated.


```python
import numpy as np
import scipy.stats as stats
n = 10
np.random.seed(4277)
X = np.random.randint(1, 100, n)
Y = -X + np.random.randint(1, 50, n)
print('X: ', X)
print('Y: ', Y)
print('r: ', stats.pearsonr(X,Y)[0])
```

    X:  [22 57 68  8 17 49 15  4 53 56]
    Y:  [-16 -30 -40  29  -7 -37  13  22 -28 -19]
    r:  -0.902473138512


Both [Spearman's $\rho$](https://en.wikipedia.org/wiki/Spearman%27s_rank_correlation_coefficient) and [Kendall's $\tau$](https://en.wikipedia.org/wiki/Kendall_rank_correlation_coefficient) are known as [rank correlation coefficients](https://en.wikipedia.org/wiki/Rank_correlation) and are nonparametric methods. They remove an underlying normality assumption present in Pearson's method. In essence, these methods are intended to answer the following question: As $X$ increases, does $Y$ tend to increase, *regardless of that increase being linear*? 

To compute $\rho_{XY}$, we convert the raw values of the $n$ $x_i$'s and $n$ $y_i$'s to ranks, $rg_{x_i}$ and $rg_{y_i}$.  $\rho$ is then defined as $r_{rg_X, rg_Y}$, the Pearson correlation between the ranked variables. If all $n$ ranks are distinct integers, it can be computed using the following shortcut formula,

$$\rho_{XY} = 1 - \frac{6 \sum_{i=1}^n d_i^2}{n(n^2 - 1)}$$

where:
- $d_i = rg_{x_i} - rg_{y_i}$

An implementation of this formula, applied to the data generated above, is illustrated below.



```python
from __future__ import division
# An implementation of Spearman's rho
def spearman(x, y, raw = True):
    # if the data are not ranked yet, we must rank them
    if raw:
        rg_x = stats.rankdata(x)
        rg_y = stats.rankdata(y)
    else:
        rg_x = x
        rg_y = y
    rho = 1 - (6*(((rg_x - rg_y)**2).sum()))/(len(rg_x)*(len(rg_x)**2 - 1))
    return rho
```


```python
# Using the same data generated in the previous example
print("Spearman's Rho:", spearman(X, Y))
```

    Spearman's Rho: -0.90303030303


On the other hand, to compute Kendall's $\tau$, we calculate:

$$\tau_{XY} = \frac{C-D}{C+D}$$

where:
- C = $\#$ of concordant pairs
- D = $\#$ of discordant pairs

Pairs of obsevations are said to be concordant if the ranks for both elements agree. This idea of concordance is best illustrated by example, as in the YouTube videos embedded below.


```python
from IPython.display import YouTubeVideo
# Part 1
YouTubeVideo("oXVxaSoY94k")
```





        <iframe
            width="400"
            height="300"
            src="https://www.youtube.com/embed/oXVxaSoY94k"
            frameborder="0"
            allowfullscreen
        ></iframe>
        




```python
# Part 2
YouTubeVideo("V4MgE43SrgM")
```





        <iframe
            width="400"
            height="300"
            src="https://www.youtube.com/embed/V4MgE43SrgM"
            frameborder="0"
            allowfullscreen
        ></iframe>
        



Below, I calculate Kendall's $\tau$ for the simulated data.


```python
rg_X, rg_Y = stats.rankdata(X), stats.rankdata(Y)
print("Kendall's tau:", stats.kendalltau(rg_X, rg_Y)[0])
```

    Kendall's tau: -0.777777777778


### Applying Rank Correlation Methods to NBA Mock Drafts

While RMSE and absolute error are generally good ways to validate predictions, these methods are better used when the data are continuous. NBA draft data are inherently ordered and this must be taken into account when scoring predictions. Hence, I decided to assess the accuracy of the mock drafts by computing ranked correlations (Spearman's $\rho$ and Kendall's $\tau$) between the mocks and the actual draft. Generally speaking, $\rho > \tau$, though $\rho$ is particularly sensitive to "bad" misses.

Some technical details:
- Andrew Sharp (SI) only had a first round mock and thus was not graded on his overall performance
- I dealt with drafted players that were not projected to be drafted in the following manner:
    - Let $u$ represent the number of players drafted that were not projected to be drafted and let $p_i$ represent one such player, i.e., $i \in 1, 2, \dots, u$
    - I randomly assign (without replacement) each $p_i$ a slot in $(61, 62, \dots, 61 + u)$ 
    - Consequently, correlation coefficients can change slightly with different random orderings
- The same "missing" methodology applied above was applied to the second round analysis
- For the first round analysis, if a player was not projected to be drafted in the first round but was indeed selected in the first round, then, borrowing the notation from above, he was randomly assigned a slot in $31, 32, \dots, 31 +u$. This choice was made due to the fact that the SI mock only contained Round 1. In effect, the application of the aforementioned imputation methodology puts all Round 1 mocks on a level playing field.  It does not, for instance, seriously penalize a mock for projecting a true first rounder in the 50s&mdash;something the SI mock may or may not have done as well.


```python
import pandas as pd
import os
```


```python
# read-in the data files
mocks_raw = {}
actuals_raw = {}
for file in os.listdir('../supps/nba_draft'):
    if file.endswith("Mock.csv"):
        mocks_raw[str(file).split('_')[0]] = pd.read_csv('../supps/nba_draft/'+file)
    elif file.endswith("Actual.csv"):
        actuals_raw[str(file).split('_')[0]] = pd.read_csv('../supps/nba_draft/'+file)
```


```python
# we eventually want to convert the raw files into properly formatted files
mocks = mocks_raw.copy()
actuals = actuals_raw.copy()
```


```python
def de_name(l):
    '''
    Extract player names from the DraftExpress data
    '''
    name = ''
    for i in range(0, len(l)-1):
        if i != (len(l)-2):
            name += l[i]
            name += ' '
        else:
            name += l[i]
    return name
```


```python
def cbs_name(x):
    '''
    Extract player names from the CBS data
    '''
    return x.split('\n')[0].strip()
```


```python
# DraftExpress cleaning
mocks['DraftExpress']['Player'] = mocks_raw['DraftExpress']['Pick'].str.split('\n').str.get(
    0).str.split().apply(de_name)
```


```python
# CBSSports cleaning
for name in ['Parrish', 'Vecenie']:
    mocks[name]['Player'] = mocks_raw[name]['Player'].apply(cbs_name)
    # Vecenie drafted AJ Hammons and Denzel Valentine twice -- in each case one
    # of the two picks was exactly correct (ironic?), so we'll penalize a bit
    if name == 'Vecenie':
        mocks[name].ix[45, 'Player'] = 'abcd'
        mocks[name].ix[13, 'Player'] = 'abcde'
    mocks[name]['Player'] = mocks[name]['Player'].replace('Wade Baldwin IV',
                                                          'Wade Baldwin')
    mocks[name]['Player'] = mocks[name]['Player'].replace("DeAndre' Bembry",
                                                          'DeAndre Bembry')
    mocks[name]['Player'] = mocks[name]['Player'].replace('Stephen Zimmerman Jr.', 
                                                      'Stephen Zimmerman')
    actuals[name] = actuals['DraftExpress']
```


```python
# Bleacher Report cleaning
mocks['BR']['Player'] = mocks['BR']['Player'].replace('Wade Baldwin IV',
                                                      'Wade Baldwin')
mocks['BR']['Player'] = mocks['BR']['Player'].replace("DeAndre' Bembry",
                                                      'DeAndre Bembry')
actuals['BR'] = actuals['DraftExpress']
```


```python
# NBA.com cleaning
mocks['NBA']['Player'] = mocks['NBA']['Player'].replace('Domatas Sabonis',
                                                        'Domantas Sabonis')
mocks['NBA']['Player'] = mocks['NBA']['Player'].replace('Wade Baldwin IV',
                                                        'Wade Baldwin')
mocks['NBA']['Player'] = mocks['NBA']['Player'].replace("DeAndre' Bembry",
                                                        'DeAndre Bembry')
actuals['NBA'] = actuals['DraftExpress']
```


```python
# SI cleaning
mocks['SI']['Player'] = mocks['SI']['Player'].replace('WADE BALDWIN IV',
                                                      'WADE BALDWIN')
actuals['SI'] = actuals['DraftExpress'][:30].copy()
actuals['SI']['Player'] = actuals['SI']['Player'].str.upper()
```


```python
def correlations(actual, mock, on='Player', picknum = '#'):
    '''
    Calculate tau and rho between the given mock draft and the actual draft.
    ----------------------------------------------------------------------------------
    actual: df containing the actual draft data (be careful, could differ based on 
    naming conventions of site)
    
    mock: df containing the mock draft data
    
    on: Name of var on which we the df's are merged; corresponds to names of players
    
    picknum: Name of var containing pick #'s 
    '''
    merged = pd.merge(actual, mock, on=on,
            how='outer')
    for i in merged:
        if on not in i and picknum not in i:
            merged = merged.drop(i, axis=1)
    merged = merged[np.isfinite(merged[picknum+'_x'])]
    if len(mock) == 60:
        round1 = merged[:30].copy()
        round1_miss = round1.loc[round1['#_y'] > 30, '#_y'].count() + 30 - round1['#_y'].count()
        random_picks1 = np.random.choice(np.arange(31, 31+round1_miss), round1_miss, replace=False)
        counter1 = 0
        for i,j in zip(round1.index, round1['#_y']):
            if j > 30 or not np.isfinite(j):
                round1.ix[i, '#_y'] = random_picks1[counter1]
                counter1 += 1 
                
        x1_1, x2_1 = round1[picknum+'_x'].values, round1[picknum+'_y'].values
        tau_1 = stats.kendalltau(x1_1, x2_1)[0]
        rho_1 = spearman(x1_1, x2_1, raw = False)
        
        round2 = merged[30:].copy()
        round2_miss = 30 - round2['#_y'].count()
        random_picks2 = np.random.choice(np.arange(61, 61+round2_miss), round2_miss, replace=False)
        counter2 = 0
        for i,j in zip(round2.index, round2['#_y']):
            if not np.isfinite(j):
                round2.ix[i, '#_y'] = random_picks2[counter2]
                counter2 += 1 
        
        x1_2, x2_2 = round2[picknum+'_x'].values, round2[picknum+'_y'].values
        tau_2 = stats.kendalltau(x1_2, x2_2)[0]
        rho_2 = spearman(x1_2, x2_2, raw = False)
        
        full = merged.copy()
        full_miss = 60 - full['#_y'].count()
        random_picks3 = np.random.choice(np.arange(61, 61+full_miss), full_miss, replace=False)
        counter3 = 0
        for i,j in zip(full.index, full['#_y']):
            if not np.isfinite(j):
                full.ix[i, '#_y'] = random_picks3[counter3]
                counter3 += 1 
        
        x1_full, x2_full = full[picknum+'_x'].values, full[picknum+'_y'].values
        tau_full = stats.kendalltau(x1_full, x2_full)[0]
        rho_full = spearman(x1_full, x2_full, raw = False)
        
        return tau_1, rho_1, tau_2, rho_2, tau_full, rho_full
                
    elif len(mock) == 30:
        round1 = merged
        round1_miss = round1.loc[round1['#_y'] > 30, '#_y'].count() + 30 - round1['#_y'].count()
        random_picks1 = np.random.choice(np.arange(31, 31+round1_miss), round1_miss, replace=False)
        counter1 = 0
        for i,j in zip(round1.index, round1['#_y']):
            if j > 30 or not np.isfinite(j):
                round1.ix[i, '#_y'] = random_picks1[counter1]
                counter1 += 1
                
        x1_1, x2_1 = round1[picknum+'_x'].values, round1[picknum+'_y'].values
        tau_1 = stats.kendalltau(x1_1, x2_1)[0]
        rho_1 = spearman(x1_1, x2_1, raw = False)

        return tau_1, rho_1
```


```python
# create dicts of correlation results and store draft names in list
drafts = []
taus = {'Round1': [],
       'Round2': [],
       'Full': []}
rhos = {'Round1': [],
       'Round2': [],
       'Full': []}
for i in actuals:
    drafts.append(i)
    results = correlations(actuals[i], mocks[i])
    if len(results) == 6:
        taus['Round1'].append(results[0])
        rhos['Round1'].append(results[1])
        taus['Round2'].append(results[2])
        rhos['Round2'].append(results[3])
        taus['Full'].append(results[4])
        rhos['Full'].append(results[5])
    elif len(results) == 2:
        taus['Round1'].append(results[0])
        rhos['Round1'].append(results[1])
        taus['Round2'].append(np.nan)
        rhos['Round2'].append(np.nan)
        taus['Full'].append(np.nan)
        rhos['Full'].append(np.nan)
```


```python
# create a df of results
draft_scores = pd.DataFrame({'Tau_Round1': taus['Round1'], 
                             'Tau_Round2': taus['Round2'],
                             'Tau_Overall': taus['Full'],
                             'Rho_Round1': rhos['Round1'], 
                             'Rho_Round2': rhos['Round2'],
                             'Rho_Overall': rhos['Full']}, index = drafts)
```

In the table below, I've sorted the results by Kendall's $\tau$ for the entire draft (which by default places SI last). I personally think that Kendall's $\tau$ does a better job than Spearman's $\rho$ because it is not nearly as sensitive to "bad" misses. For instance, Spearman's $\rho$ seriously penalizes several of the mocks for their second round performance. I would expect second round scores to be considerbaly lower than those of the first round due to the inclusion of first round projections (e.g., [Deyonta Davis](http://www.sbnation.com/nba/2016/6/23/11873304/nba-draft-2016-deyonta-davis-boston-celtics-trade-memphis-grizzlies)) as well as the inherent unpredictability and obscurity of those picks. That said, zero&mdash;or even negative&mdash;correlation is not intuitively appealing. Regardless of the metric used, DraftExpress is the clear winner, as was also the case in the Nylon Calculus article.


```python
draft_scores.sort_values('Tau_Overall', ascending = False)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Rho_Overall</th>
      <th>Rho_Round1</th>
      <th>Rho_Round2</th>
      <th>Tau_Overall</th>
      <th>Tau_Round1</th>
      <th>Tau_Round2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>DraftExpress</th>
      <td>0.863823</td>
      <td>0.728365</td>
      <td>0.404894</td>
      <td>0.726554</td>
      <td>0.604598</td>
      <td>0.540230</td>
    </tr>
    <tr>
      <th>NBA</th>
      <td>0.798138</td>
      <td>0.468743</td>
      <td>0.315907</td>
      <td>0.649718</td>
      <td>0.457471</td>
      <td>0.512644</td>
    </tr>
    <tr>
      <th>NBADraft</th>
      <td>0.806891</td>
      <td>0.528142</td>
      <td>-0.008454</td>
      <td>0.648588</td>
      <td>0.425287</td>
      <td>0.388506</td>
    </tr>
    <tr>
      <th>Vecenie</th>
      <td>0.801278</td>
      <td>0.382870</td>
      <td>0.198220</td>
      <td>0.641808</td>
      <td>0.388506</td>
      <td>0.512644</td>
    </tr>
    <tr>
      <th>Parrish</th>
      <td>0.765351</td>
      <td>0.554171</td>
      <td>0.236707</td>
      <td>0.637288</td>
      <td>0.494253</td>
      <td>0.540230</td>
    </tr>
    <tr>
      <th>NBADraftConsensus</th>
      <td>0.752931</td>
      <td>0.415350</td>
      <td>-0.145717</td>
      <td>0.624859</td>
      <td>0.416092</td>
      <td>0.365517</td>
    </tr>
    <tr>
      <th>BR</th>
      <td>0.764379</td>
      <td>0.349722</td>
      <td>-0.008676</td>
      <td>0.596610</td>
      <td>0.379310</td>
      <td>0.439080</td>
    </tr>
    <tr>
      <th>SI</th>
      <td>NaN</td>
      <td>0.486318</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>0.494253</td>
      <td>NaN</td>
    </tr>
  </tbody>
</table>
</div>



Below, I've included a full comparison of several rankings.


```python
ranks = pd.DataFrame({"Kendall's Tau": draft_scores.sort_values('Tau_Overall', ascending = False).index,
                      "Spearman's Rho": draft_scores.sort_values('Rho_Overall', ascending = False).index,
                      "Kendall's Tau Round 1": draft_scores.sort_values('Rho_Round1', ascending = False).index,
                      'Nylon Calculus': ['DraftExpress', 'NBADraft', 'NBA', 'Parrish', 'Vecenie',
                                      'NBADraftConsensus', 'BR', 'SI']
                              })
ranks.index = np.arange(1,9) 
ranks.index.name = 'Rank'
ranks
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>Kendall's Tau</th>
      <th>Kendall's Tau Round 1</th>
      <th>Nylon Calculus</th>
      <th>Spearman's Rho</th>
    </tr>
    <tr>
      <th>Rank</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>1</th>
      <td>DraftExpress</td>
      <td>DraftExpress</td>
      <td>DraftExpress</td>
      <td>DraftExpress</td>
    </tr>
    <tr>
      <th>2</th>
      <td>NBA</td>
      <td>Parrish</td>
      <td>NBADraft</td>
      <td>NBADraft</td>
    </tr>
    <tr>
      <th>3</th>
      <td>NBADraft</td>
      <td>NBADraft</td>
      <td>NBA</td>
      <td>Vecenie</td>
    </tr>
    <tr>
      <th>4</th>
      <td>Vecenie</td>
      <td>SI</td>
      <td>Parrish</td>
      <td>NBA</td>
    </tr>
    <tr>
      <th>5</th>
      <td>Parrish</td>
      <td>NBA</td>
      <td>Vecenie</td>
      <td>Parrish</td>
    </tr>
    <tr>
      <th>6</th>
      <td>NBADraftConsensus</td>
      <td>NBADraftConsensus</td>
      <td>NBADraftConsensus</td>
      <td>BR</td>
    </tr>
    <tr>
      <th>7</th>
      <td>BR</td>
      <td>Vecenie</td>
      <td>BR</td>
      <td>NBADraftConsensus</td>
    </tr>
    <tr>
      <th>8</th>
      <td>SI</td>
      <td>BR</td>
      <td>SI</td>
      <td>SI</td>
    </tr>
  </tbody>
</table>
</div>



I think my rankings compare favorably with the weighted absolute error-based rankings presented in the Nylon Calculus article. There are a few switched positions here and there, but I would argue that in the aggregrate they are very similar. Perhaps the most glaring discrepancy concerns the NBADraft.net rankings. By Kendall's $\tau$, it was the fourth best mock, while Nylon Calculus placed it second. In the end, I believe that rank correlation-based metrics are more suitable to assess the mock draft predictions, as NBA draft picks are ordinal by nature. 

The rank methods are not perfect, however. Most notably, it should be a bigger deal to miss the first pick by one slot than the $52^{nd}$ selection by one slot. This is not captured in the correlation methods presented here and hopefully can be incorporated in the future. Nevertheless, I would still lend a good deal of credence to the correlation-based methods. 
