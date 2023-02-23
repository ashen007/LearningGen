# unclear things about gen

- deterministic value problem

  problem is you can not write generative models with only deterministic values with use of trace. to understand this
  first look what trace track under the hood.

  things trace contains,
  - arguments to the generative function
  - choice map (random choice map)
  - return value
  - auxiliary state
  - any necessary record of the non-addressable randomness

  what are `@trace` looking for it's two arguments
  - a distribution
  - address

  main purpose of the trace is to keep track of state of the generative function and keep record of the random choices
  made. if only use deterministic values that do not keep track of values because they are not changing. and that give
  an error when execution because trace expect a distribution.

- custom distribution

  customizing distributions are not entirely custom here. there are two ways of doing this,

    - use `@dist`: it's only for create composite distributions which use existing supported distributions and 
                   combining those to form a new distribution. remember you can not write any julia code as body here.
                   there are many [rules](https://www.gen.dev/docs/stable/ref/distributions/#Permitted-constructs-for-the-body-of-a-@dist-1) to follow.
    - use distribution API: to fully custom distribution the only way is use of distribution api. however documentation
                            is not clear or provide any clues about how to do that. this is more involved situtaion and
                            have to write more code than use of `@dist`

  when creating custom distribution from scratch user must implement methods are,
  - random
  - logpdf
  - has_output_grad
  - logpdf_grad
  - has_argument_grads

- custom kernels

custom kernels are mainly two types,

  - compose stationary kernels (`@kern`) : use primitive kernels to compose more complex kernels.
  - primitive kernels (`@pkern`) : to declare a julia function as a primitive stationary kernel.