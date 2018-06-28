---
layout: post
title: Hidden Markov models
mathjax: true
---

We present here some algortihms on Hidden Markov models.

### Training on state labeled data

Suppose you are presented with sequences of values of $y_i$, along with their associated states $x_i$. Assuming that states are in the form of a categorical, we can, from this training set, learn a state transition probability matrix. We shall add as well a fictitious start state, for predicting the first element of a sequence. At the same time, discretizing the space of possible values if necessary, we infer a distribution for $y_i$ given $x_i$.

The $x_i$s correspond to the hidden states, and the $y_i$s we call observables. This is because our goal is to predict the most likely sequence of given states.

A practical application of this would be part of speech tagging. You have sentences, and each word, depending on the context, has a part of speech (e.g. noun, verb, adjective, etc). The observable is the word, and the part of speech is the hidden state.

The most likely for the first $k$ hidden states being $x_1, x_2, \ldots, x_k$ given observable states $y_1, y_2, \ldots, y_k$ would be computed in the following fashion.

We restrict to a particular hidden state, $x_k$. This gives us

$$\begin{aligned}Pr(x_k, y_1, \ldots, y_k) & = \displaystyle\sum_{x_{k-1}} Pr(x_k, x_{k-1}, y_1, \ldots, y_k) \\
& = \displaystyle\sum_{x_{k-1}} Pr(y_k | x_k, x_{k-1}, y_1, \ldots, y_k) Pr(x_k | x_{k-1}, y_1, \ldots, y_k) Pr(x_{k-1}, y_1, \ldots, y_k) \\
& = \displaystyle\sum_{x_{k-1}} Pr(y_k | x_k) Pr(x_k | x_{k-1}) Pr(x_{k-1}, y_1, \ldots, y_k).
\end{aligned}$$

In this, in addition to employment of the chain rule, we assume that the observable at a given time depends on only the hidden state at the same time, and similarly, that the hidden state depends probabilistically only on the previous hidden state.

This is, of course, a dynamic programming solution for the actual computation. It is called the forward algorithm.

### Estimating parameters only output data alone

Suppose we are presented with only output sequences $y_i$. How would we guess the transition probabilities, as well as the emission probabilities? The trick is to take a crude initial guess, and update that accordingly as more evidence arrives. The parameters are the following.

The time-independent transition matrix

$$A = \{a_{ij}\} = Pr(X_t = j|X_{t-1} = i).$$

The initial state distribution (at $t = 1$) given by

$$\pi_i = Pr(X_1 = i).$$

The observation variables $Y_t$, for which we let $K$ be the number of possible values. The emission probabilities are

$$b_j(y_i) = Pr(Y_t = y_i | X_t = j).$$

For the transition probabilities, we look at

$$\xi_{ij}(t) = Pr(X_t = i, X_{t+1} = j | Y, \theta).$$

Observe that this can be expressed as, by Bayes' theorem

$$\begin{aligned}Pr(X_t = i, X_{t+1} = j | Y, \theta) & = \frac{Pr(X_t = i, X_{t+1} = j, Y | \theta)}{Pr(Y| \theta)} \\
& = \frac{Pr(Y_{1:t}=y_{1:t}, X_t = i | \theta)a_{ij}b_j(y_{t+1})Pr(Y_{(t+2):T}=y_{(t+2):T} | X_{t+1} = j, \theta)}{\displaystyle\sum_{i,j} Pr(Y_{1:t}=y_{1:t}, X_t = i | \theta)a_{ij}b_j(y_{t+1})Pr(Y_{(t+2):T}=y_{(t+2):T} | X_{t+1} = j, \theta)}.\end{aligned}
$$

Let

$$\alpha_{i}(t) = Pr(Y_{1:t} = y_{1:t}, X_t = i | \theta)$$

and

$$\beta_{i}(t) = Pr(Y_{(t+1):T} = y_{(t+1):T}| X_t = i, \theta).$$

They are easily computable using dynamic programming via a forward procedure and backward procedure respectively.

Now with the probability of $i$ at time $t$ and $j$ at time $t+1$, to re-estimate the transition matrix, we ought to divide by the probability of $i$ at time $t$. This is, again by Bayes' theorem,

$$Pr(X_t = i | Y, \theta) = \frac{P(X_t = i, Y | \theta)}{P(Y | \theta)} = \frac{\alpha_i(t)\beta_i(t)}{\sum_j \alpha_j(t)\beta_j(t)}.$$

So our update for the transition probability matrix will be

$$a_{ij}^* = \frac{\sum_{t=1}^{T-1} \xi_{ij}}{\sum_{t=1}^{T-1} \gamma_i(t)}.$$

The update for the initial state distribution is

$$\pi_i^* = \gamma_i(1),$$

the expected frequency spent at state $i$ at start time $1$.

For the emission distribution, we simply for each output value, qualify on it via an indicator function, with

$$b_i^*(v_k) = \frac{\sum_{t=1}^T 1_{y_t = v_k} \gamma_i(t)}{\sum_{t=1}^T \gamma_i(t)}.$$

This algorithm, called the [Baum-Welch algorithm](https://en.wikipedia.org/wiki/Baum%E2%80%93Welch_algorithm), discovered in the 60s at Institute for Defense Analyses, is iterative, and is a special case of the expectation-maximization algorithm.


