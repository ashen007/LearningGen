## 1. challenges 

### 1.1. efficiency

this is two-way,

### 1.1.1. inference algorithm efficiency

inference algorithm efficiency refers to how many iterations or particles (interacting particle method) inference 
algorith needs to produce accurate predictions. to increase inference efficiency need to tune algorithms into 
particular problems. tuning into particular problems is not easy task either that will limit the algorithm support by 
the language (modeling language). one way to achieve this is use of combination of multiple inference strategies.

### 1.1.2. implementation efficiency

implementation efficiency is more a performance thing, refers to how long inference algorithm will take to run single 
iteration or with single particle. if inference algorithm is efficient in algorithm wise meaning it take small number of 
iterations or particles to converge but take long time to run single iteration or with single particle it is 
inefficient in implementation wise. efficient implementations depend on, 

- data structures used to store algorithm states 
- weather the system exports caching 
- incremental computation.

### 1.2. what are the challenges to create general purpose modeling language

- designing system that flexible, fast and easy to use to create inference algorithms
- finding representations for models that allows the system to exports their special structure