---
layout: post
title: On Large Language Models and Understanding
date: 2023-08-12
category: AI
tags: machine-learning, python, neural-networks, deep-learning
---

Recently, [Andrew Ng said that he believes large language models (LLMs) understand the world](https://www.deeplearning.ai/the-batch/issue-209/), at least to some extent. This belief stands in stark contrast to the [stochastic parrot](https://en.wikipedia.org/wiki/Stochastic_parrot) interpretation of LLMs--namely, that such models are good at generating convincing language without any internal understanding of the language being produced.
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Do Large Language Models really &quot;understand&quot; the world, or just give the appearance of understanding? Evidence (e.g., Othello-GPT) shows LLMs build models of how the world works, which makes me comfortable saying they do understand. More in The Batch: <a href="https://t.co/e0JGU2wUbf">https://t.co/e0JGU2wUbf</a></p>&mdash; Andrew Ng (@AndrewYNg) <a href="https://twitter.com/AndrewYNg/status/1689693276234989569?ref_src=twsrc%5Etfw">August 10, 2023</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

The [original study](https://arxiv.org/abs/2210.13382?utm_campaign=The%20Batch&utm_source=hs_email&utm_medium=email&_hsenc=p2ANqtz-8Nb-a1BUHkAvW21WlcuyZuAvv0TS4IQoGggo5bTi1WwYUuEFH4RunaPClPpQPx7iBhn-BH)  on which Ng bases his argument investigates internal language model representations by using a controlled synthetic setting involving the game of Othello. Inspired by language models learning valid chess moves from game transcripts, the study examines what a GPT variant learns solely by observing Othello game transcripts. The researchers suggest Othello, played on an 8x8 board with alternating white and black disc placements, serves as a suitable testbed due to its large game tree yet simpler rules compared to chess. The aim is to uncover any emergent world representations learned without prior knowledge of game rules or board structure. 

While the authors explicitly state that training the Othello-GPT "system itself is not our end goal; instead, it serves as our object of study", I do think the training is indeed critical, with regard to Ng's subsequent interpretation. Two training datasets were leveraged to train the system: "championship" and "synthetic." The championship dataset contained 7,605 and 132,921 Othello championship games from two online sources. The synthetic dataset was even more extensive, comprising 20 million games for training and 3,796,010 games for validation. 

So, while the system had no a priori knowledge of the game, it digested hundreds of thousands of games in order to achieve an error rate of 5.17% and tens of millions of games in order to achieve an error rate of 0.01%, where the error rate corresponds to making a legal move given a partial game up to the move.

Given the study, I have five mostly anthropocentric questions regarding Ng's strong stance, though it is worth reiterating his caveat regarding the philosophical definition of "understanding", which I also think is important. 

> there’s no widely agreed-upon, scientific test for whether a system really understands — as opposed to appearing to understand — just as no such tests exist for consciousness or sentience...This makes the question of understanding a matter of philosophy rather than science.

1\. If it takes that much--on the scale of hundreds of thousands to tens of millions of games--to understand, is it really that different from memorizing? Presumably, a child could take a minute or two to read the rule book or watch a single game and get a good grasp of legal play (i.e., [one-shot learning](https://en.wikipedia.org/wiki/One-shot_learning_(computer_vision))). Human understanding comes without an abundance of supervised learning. On the contrary, perhaps this system just learns and reaches understanding in a different manner.

2\. Why was a partial game sequence necessary to predict the next move? An agent with a true sense of the game should be able to come in, "see" a board (without any prior knowledge of that game's action), and make a valid move.

3\. Does an understanding of Othello, quite a specific environment, generalize to an understanding of the world (especially the physical world)? The authors of the study allude this in their conclusion, so I think Ng needs to be careful in extending this study's results to much larger environments, let alone the world as we know it.

4\. Does making a "legal" move reflect understanding? The intent of the model is to make "legal" move, not necessarily a smart move. Should understanding instead be measured by making rational, strategic moves? This is in line with Pedro Domingos' reply.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">You&#39;re confusing generalization with understanding. LLMs don&#39;t just parrot things, but that doesn&#39;t mean they reason. There&#39;s a large literature showing this, that board games are not a serious testbed of it, and that translation does not imply understanding either.</p>&mdash; Pedro Domingos (@pmddomingos) <a href="https://twitter.com/pmddomingos/status/1689804801968873472?ref_src=twsrc%5Etfw">August 11, 2023</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

5\. Do humans, who serve as the baseline for and arbiter of understanding in this context, even understand the world? The most philosophical take of them all, who or what is to say we even understand the world?

I really appreciated this study and hope to see more like it that probe models in search of internal representations of processes or environments. Hopefully, over time, we can get closer to an understanding of understanding.