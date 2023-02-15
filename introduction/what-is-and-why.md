## 1. What is Gen?

Gen is general purpose probabilistic programming language. it's universal meaning that it support any model,
including stochastic structured models, discrete and continues random variable models and simulators. if we consider
some of those types to more details,

### 1.1. stochastic structured models

These types of modeling approach brings probability factor in to calculations. they are consists of random variables
and uncertainty parameters meaning it will consider every possible outcome. these models must cover all points of
uncertainty to draw the correct probability distribution because it's accuracy will depend on that. famous examples
for this type of modeling are monte carlo and cellular automation.

### 1.2. discrete and continues models

Models which involves with either discrete random variables or continues random variables. in contrast, if random
variable only has countable number of distinct values called as discrete random variables, if random variable only has
continues values meaning they are uncountable called as continues random variables.

### 1.3. simulators

Simulators use to study probability characteristics of statistical estimates when theoretical distribution is unknown
but
simulators can help to obtain in a closed form of that theoretical distribution.

## 2. Why Gen?

Gen distinguished from other PPLs because it's flexible enough to customize the inference algorithm to meet users
requirements. meanwhile it provide very easy to use compact interface to build models and if users need more scalable
and efficiency they can customize the algorithms. gen consists of multiple modeling languages that are implemented as
domain specific languages in julia and julia library for inference programming.

other than flexibility gen focused on,

- To provide error less methods to implement inference algorithms
- Existing systems are not really generale purpose
- Even packages had universal model support provide limited set of inference algorithms
- Fast converging

### 2.1. inference algorithms

no matter if $p(\theta \mid X)$ is going to calculate on discrete random variable which will be the summation of in
marginalization or continues random variable where integral of in marginalization it will be impossible except very 
simple model meaning less than four outcomes. so inference algorithms is a way to solve this by avoiding the calculation
of denominator in bayes statistics.

there are a lot of those algorithms,

- Gibbs sampling: Update each coordinates with given all other coordinate. (full probability distribution) what gibbs 
  sampling do is move around probability distribution without any restrictions and update one parameter at a time while
  all others are given at the moment.

- Metropolis: Use gradient to find direction of higher probability density.
  try to cancel out the denominator using acceptance criteria which is,
  
  $${p(\theta^*\mid X)\over p(\theta\mid X)} = {{{p(X\mid\theta^*)p(\theta)}\over p(X)} \over {{p(X\mid\theta)p(\theta)}\over p(X)}}$$

  it is easy to use with symmetrical distributions, what metropolis-hasting dose is generalize this to work with 
  non-symmetrical distributions.

- Hamiltonian / NUTS (no-u turn sampling): Use auxiliary momentum and hamiltonian dynamics instead of random walk. this
  is totally physics simulation you can found more details in [here](https://elevanth.org/blog/2017/11/28/build-a-better-markov-chain/).


### 2.2. How Flexibility Rewards?

some modeling capabilities enables by gen's flexibility are,

- different approaches:
    - symbolic programming which involves manipulating symbolic data such as programmes, equations, rules or natural
      languages.
    - neural networks, by using wrappers to Tenserflow and PyTorch computaional/ execution graph
    - probabilistic programming, which use the bayesian statistics
    - simulation-based approach
- casual programming which construct a model to explain the relationship among concepts related to specific phenomenon
- deep learning
- hierarchical bayesian modeling is where estimate the parameters of the posterior distribution in multiple levels with
  bayesian method
- graphic and physics engines
- planning and reinforcement learning

### 2.3. eco-system

- Gen:
  The main Gen package. Contains the core abstract data types for models and traces.
  Also includes general-purpose modeling languages and a standard inference library.

- GenPyTorch
  Gen modeling language that wraps PyTorch computation graphs.

- GenTF
  Gen modeling language that wraps TensorFlow computation graphs.

- GenFluxOptimizers
  Enables the use of Flux’s optimizers for parameter learning in generative functions from Gen’s static or dynamic
  modeling languages.

- GenParticleFilters
  Building blocks for basic and advanced particle filtering.

  some features,
    - Particle updates that allow discarding of old choices, provided that backward kernels are specified
    - Multiple resampling methods
    - Custom priority weights for resampling
    - Metropolis-Hasting rejuvenation moves which is MCMC method to obtain a sequence of random samples
    - Move-reweight rejuvenation
    - Sequential Monte Carlo over a series of distinct models
    - Utility functions to compute distributional statistics