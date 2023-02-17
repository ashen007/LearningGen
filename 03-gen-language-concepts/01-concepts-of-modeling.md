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

@gen function f(p)
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