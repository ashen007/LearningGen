# Gen workflow

<!-- TOC -->
* [Gen workflow](#gen-workflow)
  * [1. typical workflow](#1-typical-workflow)
    * [1.1. define generative model](#11-define-generative-model)
      * [1.1.1. random choice expressions](#111-random-choice-expressions)
      * [1.1.2. rules for define generative function with DML](#112-rules-for-define-generative-function-with-dml)
    * [1.2. define inference program](#12-define-inference-program)
      * [1.2.1. some inference algorithms](#121-some-inference-algorithms)
        * [1.2.1.1 importance sampling](#1211-importance-sampling)
        * [1.2.1.1 markov chain monte carlo](#1211-markov-chain-monte-carlo)
<!-- TOC -->

## 1. typical workflow

### 1.1. define generative model

generative functions can be either deterministic meaning it does not have random choice expression in it or 
non-deterministic generative functions which has random choice expressions in it. either way generative function define
with `@gen` macro. DML version of any generative function supports branching (if-end), loops (for-end, while-end) and 
recursions. can use `@trace` macro in generative functions which will eliminate the need of user defined addresses 
because it will auto generate addresses from variable name.

```julia
@gen function <function_name> (<param_1>, <param_2>, )
    <function body>
    
end
```

deterministic generative functions like this,

```julia
@gen function gen_model(x)
    return x^2 + sqrt(x/2)

end    
```

#### 1.1.1. random choice expressions

random choice expression consists of two parts. one is the _address_ expression part and the other one is the 
probabilistic distribution expression. it uses `~` instead of regular assignment operator. gen authors often use julia 
symbols for address expression, but it's legal to use integers, tuples and strings. these random choice expressions can
be use in expression evaluation like normal.

```julia
@gen function simple_gen_f(x)
    a ~ normal(x)
    p = (a + 1) / (a * 10)
    
    return ({:b} ~ bernoulli(prob))

end
```

also generative functions can invoke another generative function inside it,

```julia
@gen function robbed_model()
    if ({:b} ~ bernoulli(0.01))
        p1 = ({:w} ~ robbed_model())
        p2 = ({:r} ~ robbed_model())
        
        return p1 + p2 + 1
        
    else
        return 1
        
    end
    
end
```

it's possible to invoke other generative functions in DML without address expression by using `*` instead. but authors 
highly discourage this invoking method.

```julia
@gen function robbed_model()
    if ({:b} ~ bernoulli(0.01))
        p1 = ({*} ~ robbed_model())
        p2 = ({*} ~ robbed_model())
        
        return p1 + p2 + 1
        
    else
        return 1
        
    end
    
end
```

#### 1.1.2. rules for define generative function with DML

- halts with probability 1

for all values of generative function arguments it must halt with probability 1. infinite loops and infinite recursions
are not permitted.

- address must be unique

any generative function must never sample a random choice at the same address twice.

- restricted use of randomness outside of random choice expressions

randomness must be associate with either random choice expression or if it is outside of random choice expression it 
must support future random choice expressions if not it must not affect to control flow. other than that every situation
make it un-valid generative function.

- restricted use of mutation

generative functions permitted only to mutate its private variables. it should not mutate its arguments or any variable
outside its lexical scope.

- DML functions cannot be passed to julia higher-order functions

an example from gen,

```julia
@gen function poly_model(x_coordinates)
    degree ~ uniform_discrete(0, 4)
    var ~ inv_gammma(1, 1)
    coefficients = [({(:c, i)} ~ normal(0, 1)) for i in 0:degree]
    
    for i=1:length(x_coordinates)
        x = x_coordinates[i]
        mu = coefficients' * x.^(0:degree)
        
        {(:y, i)} ~ normal(mu, sqrt(var))
        
    end
    
end
```

### 1.2. define inference program

inference program is a peace of julia code which use to manipulate inference model trace. how it does that is depends 
on the inference algorithm choice. because different inference algorithms takes different set of parameters to execute 
it.

how the trace data structure implemented, how probabilities and gradients are calculating and how conditional 
independence is exploited by the modeling language compiler are hidden to make the abstract data type operations more 
efficient.

#### 1.2.1. some inference algorithms

##### 1.2.1.1 importance sampling

with simple MC can get properties from a distribution but with more sophisticated implementations can sample from 
other distributions. this other distributions called _proposal distributions_. the simplest type of MC that uses this 
proposal distribution is _importance sampling_. proposal distributions can represent as model distributions like 
generative functions we discussed earlier.

there are different types of proposal are possible,

- proposal based on prior distribution 
- data driven proposals
- algorithmic proposals
- simulator-based proposals
- neural network based proposals (fully or partially learned)

there are two versions of the importance sampling in gen, returning log weights are normalised in both,

- `Gen.importance_sampling`: returning a vector of traces with associated log weights. `lml_est` are the estimate of the
                             marginal likelihood of the observations

```julia
(traces, log_norm_weights, lml_est) = importance_sampling(model::GenerativeFunction,
                                                          model_args::Tuple, 
                                                          observations::ChoiceMap, 
                                                          num_samples::Int, 
                                                          verbose=false)
```

- `Gen.importance_resampling`: returning a single trace, this sampling will not return log-weights

```julia
(trace, lml_est) = importance_resampling(model::GenerativeFunction,
                                         model_args::Tuple, 
                                         observations::ChoiceMap, 
                                         num_samples::Int,
                                         verbose=false)
```

note: proposal distribution can directly give to these functions with the use of `proposal::GenerativeFunction` and 
`proposal_args::Tuple` parameters.

two very important parameters are `num_samples` or number of samples and proposal distribution. increasing number of 
samples will reduce error, but it comes with higher computational cost. choosing good proposal make inference algorithm 
more efficient.

example,

```julia
# generative function definition for linear regression model

@gen function model(xs)
    """fitting line with data"""
    
    # proposal distribution in other words priors (or belifes)
    slope = ({:slope} ~ normal(0, 1))
    intercept = ({:intercept} ~ normal(0, 2))
    
    for (i, x) in enumerate(xs)
        ({(:y, i)} ~ normal((slope * x + intercept), 0.1))
        
    end
    
end
```

```julia
# inference program for above generative model to make inference

function inf_model(model, model_args, observations, n_samples)
    # create constrains aka condition (discussed in gen concept section)
    # in here our observations (y-coordinates) set as constraints for 
    # the inference algorithm
    obs = Gen.choicemap()
    
    for i in 1:length(observations)
        obs[(:y, i)] = observations[i]
        
    end
    
    (trace, lml_est) = Gen.importance_resampling(model, model_args, observations, n_samples)
    
    return trace
    
end
```

##### 1.2.1.1 markov chain monte carlo

MCMC is enables to algorithms that sample approximately from target probability distributions that are defined by 
un-normalized density function and conditional distributions. generative function with MCMC initialize a state that 
contains the values of latent random variables (unobserved values) and rapidly apply a stochastic kernel to this sate 
and produce new state and keep going. one of important property of those kernels is they are stationary with respect to 
the conditional distribution.

here some of gen's stationary kernels,

- `metropolis_hastings`: gen has three variant of this and the simplest one is user provide set of random choices to be
                         updated without specifying how. second one allows user to use custom proposal or custom proposal
                         based on neural networks that are trained via amortized inference. the last one allows user to 
                         specify any kernel in the reversible jump MCMC framework.

to perform Metropolis-Hastings update that proposes new values for the selected addresses from the internal proposal,
```julia
(new_trace, accepted) = metropolis_hastings(trace, 
                                            selection::Selection;
                                            check=false, 
                                            observations=EmptyChoiceMap())
```

to perform Metropolis-Hastings update that proposes new values for some subset of random choices in the given trace 
using the given proposal generative function, returning the new trace and a Bool indicating whether the move was 
accepted or not.

```julia
(new_trace, accepted) = metropolis_hastings(trace, 
                                            proposal::GenerativeFunction, 
                                            proposal_args::Tuple;
                                            check=false, 
                                            observations=EmptyChoiceMap())
```

perform a generalized Metropolis Hastings update based on an involution on space of choice maps. returning the new trace and a Bool indicating whether the move was 
accepted or not.

```julia
(new_trace, accepted) = metropolis_hastings(trace, 
                                            proposal::GenerativeFunction, 
                                            proposal_args::Tuple,
                                            involution::Union{TraceTransformDSLProgram,Function};
                                            check=false, 
                                            observations=EmptyChoiceMap())
```

- `mala`: performs a Metropolis Adjusted Langevin algorithm update on a set of selected random choices.

```julia
(new_trace, accepted) = mala(trace, 
                             selection::Selection, 
                             tau::Real;
                             check=false, 
                             observations=EmptyChoiceMap())
```

- `hmc`: performs a Hamiltonian Monte Carlo update on a set of selected random choices. this is also a selection based 
         inference operators which user need to provide set of addresses (random choices) that act on traces.

```julia
(new_trace, accepted) = hmc(trace, 
                            selection::Selection; 
                            L=10, eps=0.1,
                            check=false, 
                            observations=EmptyChoiceMap())
```

- `elliptical_slice`:  performs an elliptical slice sampling update on a selected multivariate normal random choice.

```julia
new_trace = elliptical_slice(trace, 
                             addr, mu, cov;
                             check=false, 
                             observations=EmptyChoiceMap())
```

example, 

```julia
# inference program which use metropolis hastings as selection based operator

function inf_model(model, model_args, observations, n_samples)
    obs = Gen.choicemap()
    
    # create constrains aka condition
    for i in 1:length(observations)
        obs[(:y, i)] = observations[i]
        
    end
    
    # to get an initial execution trace
    (trace, accepted) = generate(model, model_args, observations)
    
    # provide selected random choice to mh
    for i in 1:n_samples
        (trace, accepted) = metropolis_hastings(trace, select(:slope))
        (trace, accepted) = metropolis_hastings(trace, select(:intercept))
        
    end
    
    choices = get_choices(trace)
    
    return (choices[:slope], choices[:intercept])
    
end
```