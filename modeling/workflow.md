# Gen workflow

## 1. typical workflow

### 1.1. define generative model

generative functions can be either deterministic meaning it does not has random choice expression in it or 
non-deterministic generative functions which has random choice expressions in it. either way generative function define
with `@gen` macro.

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
be use in expression evaluation like normal. DML version of any generative function supports branching (if-end), loops 
(for-end, while-end) and recursions.

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



### 1.3. execution of the inference program