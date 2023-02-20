====================================
Problems and How Gen Over Come Those
====================================

-------------
1. Challenges
-------------

1.1. Efficiency
===============

this is two-way,

1.1.1. Inference Algorithm Efficiency
-------------------------------------

inference algorithm efficiency refers to how many iterations or particles (interacting particle method) inference
algorithm needs to produce accurate predictions. to increase inference efficiency need to tune algorithms into
particular problems. tuning into particular problems is not easy task either that will limit the algorithm support by
the language (modeling language). one way to achieve this is use of combination of multiple inference strategies.

1.1.2. Implementation Efficiency
--------------------------------

implementation efficiency is more a performance thing, refers to how long inference algorithm will take to run single
iteration or with single particle. if inference algorithm is efficient in algorithm wise meaning it take small number of
iterations or particles to converge but take long time to run single iteration or with single particle it is
inefficient in implementation wise. efficient implementations depend on,

- data structures used to store algorithm states
- weather the system exports caching
- incremental computation

1.2. What are the Challenges to Create General Purpose Modeling Language
============================================================================

- designing system that flexible, fast and easy to use to create inference algorithms
- finding representations for models that allows the system to export their special structure, traditional choices will
  not make any difference here even turing-complete languages

1.3. Quickly, What is Turing complete Language?
===============================================

simply any language if it can do anything that a turing machine can do call turing complete language. so what turing
machines can do?

- it has conditional branching
- it gets arbitrary amount of memory (more generally a way to read and write some form of storage)

few popular examples will help,

- c++
- `game of life`_
.. _game of life:(https://conwaylife.com/)

--------------------------------------------
2. What Gen Do to Overcome Those Challenges?
--------------------------------------------

- provide high-level abstractions that enable users to specify custom inference algorithms themselves, while automating
  optimization, parameter-tuning, and the calculation of probability ratios used in Monte Carlo and variational
  inference
- a brand-new architecture for probabilistic programming systems, to represents models as black-boxes that expose
  capabilities useful to inference rather than turing complete modeling language
- providing tools to

    - construct models that support efficient implementations

      gen has multiple interoperable modeling languages, each has different flexibility and efficiency trade-off. single
      model can combine multiple modeling languages, compiler will generate implementation of generative function
      interface
      which use model-specific logic for perform it more efficiently

    - tailoring inference to improve inference algorithm efficiency

      these tools are implements building blocks for inference algorithms only interact with model through generative
      function inference

2.2. High Level Overview of Gen
===============================

2.2.1. Key Idea
---------------

it is primitive data types and low-level operations. key idea is to generate code for those primitive data types and
operations from an explicit machine-readable representation of the model user specified.

overall process is,

- user define the model
- after model definition user implement the inference algorithm with use of model generated data types and operations

this process will give us explicit definitive representation for the model, automate low level computations, easy use of
models that possess structure uncertainty

2.2.2. New Data Types
---------------------

There are two of them,

- Generative function: representation of generative probabilistic model.

  generative functions supports,
    - generate traces in different ways
    - unconditional sampling (samples from prior distribution)

- Traces : representation of samples from generative probabilistic model that include assignment to all latent and
  observed variables. traces supports,

  - computation of log density of the model
  - compute gradients of the log density
  - update values of some subset of the random variables

these are abstract data types so users do not need to worry about there internal behaviors and implementations.

key takeaways from abstract data types,

- provide set of primitive operations for implementing inference algorithms. (including generating execution trace,
  querying executions trace and gradients of the values of random variables, updating execution trace)
- typically they will automatically implement, of course unless user need to change it to meet their need
- even through gen has multiple PPL, they all generate the same abstract data types but has different tradeoffs
- gen's design allows to more efficient implementations of abstract data types and analyzing, compiling, optimizing and
  high-level user inference code

2.2.3. How Gen Differ from Other Systems
----------------------------------------

- provide comparable abstract data types for probabilistic models and execution traces
- supports multiple interoperable PPL
- supports lot of efficient inference techniques
- supports custom proposal distributions (a proposal distribution is used to enable sampling from a known distribution)