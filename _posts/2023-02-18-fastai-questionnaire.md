---
layout: post
title: Questionnaire Responses for Deep Learning for Coders with fastai & PyTorch
date: 2023-02-18
category: AI
tags: machine-learning, ai
---

*This page is a work in progress* 

## Chapter 1

1. Do you need these for deep learning?

   - Lots of math T / **F**
   - Lots of data T / **F**
   - Lots of expensive computers T / **F**
   - A PhD T / **F**
   
1. Name five areas where deep learning is now the best in the world.
    - Natutural Language Processing (NLP) (e.g., ChatGPT)
    - Computer Vision (e.g., Face Recognition)
    - Image generation (e.g., Stable Diffusion)
    - Recommendation Systems (e.g., Product recommendations)
    - Playing games (e.g., Chess, Go, etc.)

1. What was the name of the first device that was based on the principle of the artificial neuron?

    The Mark I Perceptron, developed by Frank Rosenblatt

1. Based on the book of the same name, what are the requirements for parallel distributed processing (PDP)?

    - A set of *processing units*
    - A *state of activation*
    - An *output function* for each unit
    - A *pattern of connectivity* among units
    - A *propagation rule* for propagating patterns of activities through the network of connectivities
    - An *activation rule* for combining the inputs impinging on a unit with the current state of that unit to produce an output for the unit
    - A *learning rule* whereby patterns of connectivity are modified by experience
    - An *environment* within which the system must operate

1. What were the two theoretical misunderstandings that held back the field of neural networks?

    - Although a single layer of perceptrons was unable to learn some important matrhmatical functions such as $XOR$, people overlooked the fact that *layering* multiple perceptrons addressed this
    - Even after incorporating multiple layers, practitioners found networks to be too big and slow to be useful

1. What is a GPU?

    A GPU is a Graphis Processing Unit. GPUs are specialized processors designed to handle complex graphical computations. They are optimized for parallel processing and are designed to quickly perform a large number of simple calculations at the same time. This makes them particularly well-suited for tasks like video rendering, machine learning, and scientific simulations.

1. Open a notebook and execute a cell containing: `1+1`. What happens?

    The cell will act as a calculator, producing an output of 2 below.

1. Follow through each cell of the stripped version of the notebook for this chapter. Before executing each cell, guess what will happen.


1. Complete the Jupyter Notebook online appendix.


1. Why is it hard to use a traditional computer program to recognize images in a photo?

    A traditional computer program uses meticulous, predefined instructions to translate inputs into outputs. For example, a program to cube a number would take a number as input, provide instructions for how to raise that number to the power of 3, and display the number raised to the power of 3. For someting such as image recognition, providing such clear, procedural instructions is difficult. It is difficult to describe in words and symbols how your brain recognizes and image.

1. What did Samuel mean by "weight assignment"?

    "Weight assignment" is one of the major things that differentiates a typical computer program from a machine learning model. Instead of just taking inputs, a machine learning model takes inputs and weights, where the weight assignments are additional values that define how a program will operate, a kind of meta-instruction.

1. What term do we normally use in deep learning for what Samuel called "weights"?

    Parameters

1. Draw a picture that summarizes Samuel's view of a machine learning model.
1. Why is it hard to understand why a deep learning model makes a particular prediction?
1. What is the name of the theorem that shows that a neural network can solve any mathematical problem to any level of accuracy?
1. What do you need in order to train a model?
1. How could a feedback loop impact the rollout of a predictive policing model?
1. Do we always have to use 224×224-pixel images with the cat recognition model?
1. What is the difference between classification and regression?
1. What is a validation set? What is a test set? Why do we need them?
1. What will fastai do if you don't provide a validation set?
1. Can we always use a random sample for a validation set? Why or why not?
1. What is overfitting? Provide an example.
1. What is a metric? How does it differ from "loss"?
1. How can pretrained models help?
1. What is the "head" of a model?
1. What kinds of features do the early layers of a CNN find? How about the later layers?
1. Are image models only useful for photos?

    No. Since image models work so well, sometimes it makes sense to translate some other input into an image to leverage the image model architecture. For instance, one could create a spectogram to map sound data into an image and then use an image model to classify sounds.

1. What is an "architecture"?

    The functional form of a model. In other words, a general template for how a model works internally. 
1. What is segmentation?

    Segmentation describes the task of characterizing every individual pixel of an image. ![](https://www.anolytics.ai/wp-content/uploads/2022/07/segment_sgment.jpg)
1. What is `y_range` used for? When do we need it?

    This is a `fastai` parameter to set the appropriate range for a continuous outcome. For instance, a Rotten Tomatoes score prediction should be between 0 and 100.
  
1. What are "hyperparameters"?

    Modeling choices regarding network architecture, learning rates, data augmentation strategies, and other factors.

1. What's the best way to avoid failures when using AI in an organization?

    Always keep a separate test (holdout) set of data. You check the model on a test set using a metric of your choice and you decide if the level of performance is sufficient.