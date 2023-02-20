What and Why
============


1. Probabilistic Modeling
-------------------------

1.1. Generative Models
~~~~~~~~~~~~~~~~~~~~~~

uncertain domain knowledge representation using joint probability distribution on variables which has known values
(observations variables) and variables which has unknown values (latent variables). these are build on combination of
prior knowledge and empirical evidence.

1.2. Inference Task
===================

specially posterior inference, values of latent variables from values of observed variables given an assumed generative
model. this requires conditioning the joint distribution over latent and observed variables on the event that the
observed variables took certain values.

forms of inference about latent variables,

- samples from the conditional probability distribution
- an analytical representation of the conditional distribution
- some sort of summary of the conditional distribution


2. What is Gen?
---------------

Gen is general purpose probabilistic programming language. it's universal meaning that it support any model,
including stochastic structured models, discrete and continues random variable models and simulators. if we consider
some of those types to more details,

2.1. Stochastic Structured Models
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These types of modeling approach brings probability factor in to calculations. they are consists of random variables
and uncertainty parameters meaning it will consider every possible outcome. these models must cover all points of
uncertainty to draw the correct probability distribution because it's accuracy will depend on that. famous examples
for this type of modeling are monte carlo and cellular automation.

2.2. Discrete and Continues Models
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Models which involves with either discrete random variables or continues random variables. in contrast, if random
variable only has countable number of distinct values called as discrete random variables, if random variable only has
continues values meaning they are uncountable called as continues random variables.

2.3. Simulators
~~~~~~~~~~~~~~~

Simulators use to study probability characteristics of statistical estimates when theoretical distribution is unknown
but simulators can help to obtain in a closed form of that theoretical distribution.


3. Why Gen?
-----------

Gen distinguished from other PPLs because it's flexible enough to customize the inference algorithm to meet users
requirements. meanwhile it provide very easy to use compact interface to build models and if users need more scalable
and efficiency they can customize the algorithms. gen consists of multiple modeling languages that are implemented as
domain specific languages in julia and julia library for inference programming.

other than flexibility gen focused on,

- To provide error less methods to implement inference algorithms
- Existing systems are not really generale purpose
- Even packages had universal model support provide limited set of inference algorithms
- Fast converging

3.1. Inference Algorithms
~~~~~~~~~~~~~~~~~~~~~~~~~

no matter if  :math:`{p(\Theta | X)}` is going to calculate on discrete random variable which will be the summation of in
marginalization or continues random variable where integral of in marginalization it will be impossible except very
simple model meaning less than four outcomes. so inference algorithms is a way to solve this by avoiding the calculation
of denominator in bayes statistics.

there are a lot of those algorithms,

- Gibbs sampling: Update each coordinates with given all other coordinate. (full probability distribution) what gibbs
  sampling do is move around probability distribution without any restrictions and update one parameter at a time while
  all others are given at the moment.

- Metropolis: Use gradient to find direction of higher probability density.
  try to cancel out the denominator using acceptance criteria which is,

.. image:: ../../images/CodeCogsEqn.png
    :align: center

it is easy to use with symmetrical distributions, what metropolis-hasting dose is generalize this to work with
non-symmetrical distributions.

- Hamiltonian / NUTS (no-u turn sampling): Use auxiliary momentum and hamiltonian dynamics instead of random walk. this
  is totally physics simulation you can found more details in `here`_.

.. _here: https://elevanth.org/blog/2017/11/28/build-a-better-markov-chain/


3.2. How Flexibility Rewards?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

some modeling capabilities enables by gen's flexibility are,

- different approaches:

    - symbolic programming which involves manipulating symbolic data such as programmes, equations, rules or natural
      languages.
    - neural networks, by using wrappers to TensorFlow and PyTorch computational execution graph
    - probabilistic programming, which use the bayesian statistics
    - simulation-based approach

- casual programming which construct a model to explain the relationship among concepts related to specific phenomenon
- deep learning
- hierarchical bayesian modeling is where estimate the parameters of the posterior distribution in multiple levels with
  bayesian method
- graphic and physics engines
- planning and reinforcement learning

3.3. Eco-system
~~~~~~~~~~~~~~~

Gen
  The main Gen package. Contains the core abstract data types for models and traces.
  Also includes general-purpose modeling languages and a standard inference library.

|

GenPyTorch
  Gen modeling language that wraps PyTorch computation graphs.

|

GenTF
  Gen modeling language that wraps TensorFlow computation graphs.

|

GenFluxOptimizers
  Enables the use of Flux’s optimizers for parameter learning in generative functions from Gen’s static or dynamic
  modeling languages.

|

GenParticleFilters
  Building blocks for basic and advanced particle filtering.

|

some features,
    - Particle updates that allow discarding of old choices, provided that backward kernels are specified
    - Multiple resampling methods
    - Custom priority weights for resampling
    - Metropolis-Hasting rejuvenation moves which is MCMC method to obtain a sequence of random samples
    - Move-reweight rejuvenation
    - Sequential Monte Carlo over a series of distinct models
    - Utility functions to compute distributional statistics

