# concepts of modeling in Gen

<!-- TOC -->
* [concepts of modeling in Gen](#concepts-of-modeling-in-gen)
  * [1. language concepts in julia](#1-language-concepts-in-julia)
    * [1.1. dynamic modeling language](#11-dynamic-modeling-language)
    * [1.2. trace and generative functions](#12-trace-and-generative-functions)
    * [1.3. operations supported by abstract data types](#13-operations-supported-by-abstract-data-types)
    * [1.4. DML and SML](#14-dml-and-sml)
<!-- TOC -->

## 1. language concepts in julia

### 1.1. dynamic modeling language

this extends the syntax of the julia language it's called as _labeled random choice expression_, the left side of the
expression encodes a dynamically computed address for randomly chosen values. right side of the expression encodes a
probability distribution from which the value should be sampled. it is an error to use this syntax with the same
address twice. addresses can be arbitrary Julia values.

```julia
{address} ~ bernoulli(0.5)
```

a ~ bernoulli(0.5) is equivalent to a = ({:a} ~ bernoulli(0.5)), `:a` is a julia symbol

users of gen can use these random choice expressions, julia expressions and julia control flow to construct a
probabilistic models.

some examples,

```julia
using Gen: uniform_discrete, bernoulli, categorical, @gen

@gen function f()
    """simple generative function"""
    
    n = {:init_n} ~ uniform_discrete(1, 10)
    
    return {:result} ~ categorical([i == n ? 0.5 : 0.5/19 for (i=1:20)])
```

```julia
using Gen: uniform_discrete, bernoulli, categorical, @gen

@gen function burglary_model()
    """generative function with conditional flow control"""
    
    # get random values for buglury from bernoulli distribution
    # which returns true/ false (success or not)
    burglary ~ bernoulli(0.01)
    
    if burglary
        # if this is buglary get random values to
        # alarm state which disabled or not (true/ false)
        disabled ~ bernoulli(0.1)
        
    else
        # if this is not a buglary set alarm state to disabled
        disabled = false
        
    end
    
    # reverse logic, if alarm disabled (true) alarm can not ring
    # other hand it is not disabled get values to weather alarm
    # ringed or not (true/ false)
    if !disabled
        alarm ~ bernoulli(if burglary 0.94 else 0.01 end)
        
    else
        alarm = false
        
    end
    
    calls ~ bernoulli(if alarm 0.7 else 0.05 end)
    
    return nothing
    
end
```

### 1.2. trace and generative functions

semantics in gen is consists of two sections.

- dictionaries (trace): intercept program execution (random choice expressions) and record the randomly sampled value
  for each random choice in a dictionary, which maps addresses of random choices to their values (there can not be use
  same address twice in an execution, also program needs to ends with probability of 1)

- function to map dictionaries (generative function): function that maps dictionary (trace) to return values of the
  program.

note: most notable difference between gen and other PPL which use trace-based semantics is gen's user defined addresses
for random choices because gen allows users to write inference code that refers specific random choices by their
addresses.

### 1.3. operations supported by abstract data types

- simulation operation

it is an operation of a generative function. it takes generative function as argument and values for parameters of the
generative function, samples a dictionary of random choices according to the distribution and returns trace.

```julia
using Gen: uniform_discrete, bernoulli, categorical, @gen, simulate

@gen function f()
    """simple generative function"""
    
    n = {:init_n} ~ uniform_discrete(1, 10)
    
    return {:result} ~ categorical([i == n ? 0.5 : 0.5/19 for (i=1:20)])
    
end

trace = simulate(f, ())
```

- generate operation

generate also an operation supported by generative functions. it will return an execution trace, but it did not sample
like simulation operation, it takes samples as input and returned trace and weights. generates use for generate trace
that satisfy set of constraints on the values of random choices. its ability is extended to take a partial dictionary
that only contains some of the choices and fill the rest stochastically.

```julia
using Gen: uniform_discrete, bernoulli, categorical, @gen, choicemap, generate

@gen function f(p_a)
    """simple generative function"""
    
    val = true
    
    if ({:a} ~ bernoulli(p_a))
        val = ({:b} ~ bernoulli(0.6)) && val
        
    end
    
    prob_c = val ? 0.9 : 0.2
    val = ({:c} ~ bernoulli(prob_c)) && val
    
    return val
    
end

constraints = choicemap((:a, true), (:c, false))
(trace, weight) = generate(f, (0.4,), constraints)
```

- logpdf operation

it is an operation supported by trace. which returns the log probability that the random choices in the trace would have
been sampled. this typically the sum of log-probabilities for each random choice.

- choices operation

this is also an operation supported by traces. which simply return choices of a given trace meaning this take trace as
input. choice map, maps from the addresses of random choices to their values. it stored in associative tree structure
data structure (simply a dictionary).

```julia
using Gen: uniform_discrete, bernoulli, categorical, @gen, simulate, get_choices

@gen function f()
    """simple generative function"""
    
    n = {:init_n} ~ uniform_discrete(1, 10)
    
    return {:result} ~ categorical([i == n ? 0.5 : 0.5/19 for (i=1:20)])
    
end

trace = simulate(f, ())
get_choices(trace)
```

- update operation

this operation is also supported by traces. it is more complex operation than above operations supported by traces. this
will take few arguments in order to execute the operation. this operation will return new execution traces. first
argument is new arguments to the generative function which may be different from the arguments were stored in the
initial execution trace.

second argument is enables an optimization trick to the update operation. it is a change hint that provides optional
information about the difference between initial state and new state of the generative function arguments. this will
help to do this operation more efficiently.

third argument is a dictionary that consists of addresses that include in initial trace and whose values should be
change and also addresses are not include in the initial execution traces but need to add to new execution traces.

```julia
using Gen: uniform_discrete, bernoulli, categorical, @gen, simulate, update, NoChange, choicemap

@gen function f(p_a)
    """simple generative function"""
    
    val = true
    
    if ({:a} ~ bernoulli(p_a))
        val = ({:b} ~ bernoulli(0.6)) && val
        
    end
    
    prob_c = val ? 0.9 : 0.2
    val = ({:c} ~ bernoulli(prob_c)) && val
    
    return val
    
end

# get initial trace
trace = simulate(f, (0.4,))

# update initial trace
constraints = choicemap((:c, false))
(new_trace, weight, discard, diff) = update(trace, (0.4,), (NoChange(),), constraints)
```

### 1.4. DML and SML

There are two modeling languages in gen,

- Dynamic Modeling Language (DML), all we so far is DML models
- Static Modeling Language (SML)

DML is used all julia syntax including recursions. Because of that it is less efficient than SML. because DML's high 
expressiveness makes it difficult to generate more efficient generative functions and traces. but in SML it restrict the
set of control flow constructs and have excellent static analysis to statically specialize implementation of generative 
functions and traces to better performance. even though SML is more efficient than DML it's complex nature make it less
user-friendly.

```julia
# DML version of hidden markov model wich has 1000 time steps and
# A denotes the hidden state and B denote the observed state
# this model will make 2000 random choices (1000 for :z and 1000 for :y)

@gen function dynamic_f()
  """hidden markov model describe the evaluation of observable events that depend
  on unobservable internal factors"""

  z = 1
  
  for i in 1:1000
    z = ({:steps=>i=>:z}) ~ categorical(A[z, :])
    {:steps=>i=>:y} ~ categorical(B[z,:])
    
  end
  
end
```

```julia
# SML vervsion of hidden markov model
# SML not supported loops insted has differnt machnism Unfold

@gen (static) function static_f()
  # has 1000 time steps as DML version
  # this outer function use to call step function sequentially
  steps ~ Unfold(step)(1000, 1)
  
end

@gen (static) function step(i, prev)
  # use same random choices as DML version
  z ~ categorical(A[prev, :])
  y ~ categorical(B[z,:])
  
  return z
  
end
```