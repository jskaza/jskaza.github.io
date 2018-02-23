---
layout: post
title: Pokémon Viz
date: 2016-07-20 13:25
category: Misc
tags: pokémon, data-viz
---

Below, I generate two plots using data from the [Pokémon Database](http://pokemondb.net/). I used data on Generation I Pokémon species [base stats](http://bulbapedia.bulbagarden.net/wiki/Base_stats), as *individual* Pokémon can possess variable base stats. Total, as depicted in the first chart, is the sum of HP, Attack, Defense, Special Attack, Special Defense, and Speed.


```python
from bs4 import BeautifulSoup
import urllib.request
import pandas as pd
import numpy as np
from __future__ import division
from bokeh.models import HoverTool
from bokeh.plotting import ColumnDataSource, figure, show
from bokeh.io import output_notebook
from bokeh.models import Circle
from bokeh.resources import CDN
output_notebook()
%matplotlib inline
```



    <div class="bk-root">
        <a href="https://bokeh.pydata.org" target="_blank" class="bk-logo bk-logo-small bk-logo-notebook"></a>
        <span id="7eb253a8-29fb-46d4-ab10-3eff21a81c5f">Loading BokehJS ...</span>
    </div>





```python
url1 = "http://pokemondb.net/pokedex/stats/height-weight" # pokemon ht/wt database
req = urllib.request.Request(url1, headers={'User-Agent' : "Magic Browser"}) 
page1 = urllib.request.urlopen(req)
soup1 = BeautifulSoup(page1, "html.parser")
table1 = soup1.find("table")

pokemon = []
ht = []
wt = []
bmi = []

# scrape the gen 1 pokemon
counter = 1
for row in table1.findAll("tr"):
    cells = row.findAll("td")
    if len(cells) >=4 and len(cells[1].findAll(text=True)) == 1 and counter < 152:
        pokemon.append(cells[1].findAll(text=True)[0])
        ht.append(cells[3].findAll(text=True)[0]) 
        wt.append(cells[4].findAll(text=True)[0]) 
        bmi.append(cells[5].findAll(text=True)[0])
        counter += 1
```


```python
pokedex1 = pd.DataFrame({'pokemon': pokemon,
                        'ht': ht,
                        'wt': wt,
                        'bmi': bmi})
```


```python
def get_ht_wt(x):
    '''
    function for formatting data
    '''
    return float(x.split('(')[1].split(')')[0].split('m')[0].split()[0])
```


```python
# format the data
for col in pokedex1:
    if col == 'ht' or col == 'wt':
        pokedex1[col] = pokedex1[col].apply(get_ht_wt)
    elif col == 'bmi':
        pokedex1[col] = pokedex1[col].apply(float)
```


```python
url2 = "http://pokemondb.net/pokedex/all" # pokemon main stats
req = urllib.request.Request(url2, headers={'User-Agent' : "Magic Browser"}) 
page2 = urllib.request.urlopen(req)
soup2 = BeautifulSoup(page2, "html.parser")
table2 = soup2.find("table")

pokemon = []
total = []

# scrape the gen 1 pokemon
counter = 1
for row in table2.findAll("tr"):
    cells = row.findAll("td")
    if len(cells) >=4 and len(cells[1].findAll(text=True)) == 1 and counter < 152:
        pokemon.append(cells[1].findAll(text=True)[0])
        total.append(cells[3].findAll(text=True)[0]) 
        counter += 1
```


```python
pokedex2 = pd.DataFrame({'pokemon': pokemon,
                        'total': total
                       })
```


```python
# group pokemon by evolution group
evolution = [1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,8,8,9,9,10,10,11,11,12,12,12,13,13,
13,14,14,15,15,16,16,17,17,18,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,26,26,27,
27,27,28,28,28,29,29,29,30,30,31,31,31,32,32,33,33,34,34,35,36,36,37,37,38,38,39,39,40,40,
40,41,42,42,43,43,44,44,45,45,46,46,'47a','47b',48,49,49,50,50,51,52,53,54,54,55,55,56,56,57,58,
59,60,61,62,63,64,64,65,66,67,67,67,67,68,69,69,70,71,72,73,74,75,76,77,77,77,78,79]
pokedex1['evolution'] = pd.Series(evolution)
```


```python
# merge pokedexes
merged = pd.merge(pokedex1,pokedex2)
merged['total'] = merged['total'].apply(float)
```


```python
# generate separate dfs for each evolution group
groups = {}
for i in merged['evolution'].unique():
    groups[i] = merged[merged['evolution'] == i].copy()
    
groups2 = {}
for i in groups:
    groups[i].index = groups[i]['pokemon']
    j = groups[i].index[0]
    groups2[j] = groups[i].copy()
    groups2[j] = groups2[j]['total']
    groups2[j] = pd.DataFrame(groups2[j]).T
    if i == 67:
        groups2[j] = groups2[j][groups2[j].columns[:2]]
    groups2[j].index = [j]
    if len(groups2[j].T) < 3:
        while len(groups2[j].T) < 3:
            groups2[j][len(groups2[j].T)+1] = np.nan
    groups2[j].columns = [1,2,3]
```


```python
# a df with first evolution as index and 3 columns for each evolution
df = groups2[sorted(groups2.keys())[0]]
for i in sorted(groups2.keys()):
    if i != sorted(groups2.keys())[0]:
        df = df.append(groups2[i])
```


```python
# create list of pokemon names for plotting
names = []
for i in sorted(groups2.keys()):
    for j in groups.keys():
        for k in groups[j]['pokemon']:
            if i == k:
                if i == 'Eevee':
                    names.append('Eevee')
                    names.append('Flareon/Jolteon/Vaporeon')
                    names.append('N/A')
                else:
                    counter = 0
                    for l in groups[j]['pokemon']:
                        names.append(groups[j]['pokemon'][l])
                        counter += 1
                    while counter < 3:
                        names.append('N/A')
                        counter += 1
```


```python
df.replace(np.nan, 0, inplace=True) # replace NaN's w/ 0 for plotting purposes

percentiles = merged.describe(percentiles = np.arange(1/8, 1, 1/8))['total'] # power percentiles

stages = ['1','2','3'] # evolution stages
pokemons = list(df.index) # evolution 1 pokemons
colors = ["#d9d9d9", "#deebf7", "#c6dbef", "#9ecae1", "#6baed6", "#4292c6", "#2171b5", "#08519c", "#08306b"] # colormap

# obtain data for plot
stage = []
pokemon = []
color = []
power = []
for p in pokemons:
    for s in stages:
        stage.append(s)
        pokemon.append(p)
        value = int(df[int(s)][p])
        if value == 0:
            power.append('N/A')
        else:
            power.append(value)
        if value == 0:
            color.append(colors[0])
        elif value > 0 and value <= percentiles[4]:
            color.append(colors[1])
        elif value > percentiles[4] and value <= percentiles[5]:
            color.append(colors[2])
        elif value > percentiles[5] and value <= percentiles[6]:
            color.append(colors[3])
        elif value > percentiles[6] and value <= percentiles[7]:
            color.append(colors[4])
        elif value > percentiles[7] and value <= percentiles[8]:
            color.append(colors[5])
        elif value > percentiles[8] and value <= percentiles[9]:
            color.append(colors[6])
        elif value > percentiles[9] and value <= percentiles[10]:
            color.append(colors[7])
        elif value > percentiles[10] and value <= percentiles[11]:
            color.append(colors[8])
            
source = ColumnDataSource(
    data=dict(stage=stage, pokemon=pokemon, color=color, power=power, names=names)
)

TOOLS = "hover,save,pan,box_zoom,wheel_zoom"

p = figure(title="Pokémon Total Chart",
           x_range=stages, y_range=list(reversed(pokemons)),
           x_axis_location="above", plot_width=400, plot_height=900,
           tools=TOOLS)

p.grid.grid_line_color = None
p.axis.axis_line_color = None
p.axis.major_tick_line_color = None
p.axis.major_label_text_font_size = "6pt"
p.axis.major_label_standoff = 0
p.xaxis.axis_label = "Evolution"

p.rect("stage", "pokemon", 1, 1, source=source,
       color="color", line_color=None)

p.select_one(HoverTool).tooltips = [
    ('Pokemon', '@names'),
    ('Power', '@power'),
]

show(p)
```



<div class="bk-root">
    <div class="bk-plotdiv" id="c9138e4e-25a0-4442-a49e-c80dfa8d7106"></div>
</div>





```python
source = ColumnDataSource(
    data=dict(ht=list(merged["ht"]), wt=list(merged["wt"]), pokemon=list(merged["pokemon"]))
)

p = figure(title="Pokémon Height vs. Weight", tools="tap,hover,box_zoom,wheel_zoom")
p.circle("wt", "ht", source = source, size=10, name="circle", alpha=.2, color="black", line_color=None)

p.select_one(HoverTool).tooltips = [
    ('Pokemon', '@pokemon'),
]

selected_circle = Circle(fill_alpha=1, fill_color="firebrick", line_color=None)
nonselected_circle = Circle(fill_alpha=0.2, fill_color="black", line_color=None)

renderer = p.select(name="circle")
renderer.selection_glyph = selected_circle
renderer.nonselection_glyph = nonselected_circle

p.xaxis.axis_label = "Wt (kg)"
p.yaxis.axis_label = "Ht (m)"
show(p)
```



<div class="bk-root">
    <div class="bk-plotdiv" id="74e9dbfc-d528-47b1-bfa7-bef508dbc3b1"></div>
</div>





```python

```
