#=
gen_intro:
- Julia version: 
- Author: ashen
- Date: 2023-03-19
=#

using Gen
using AlgebraOfGraphics
using CairoMakie

@gen function model(p)
    n = @trace(uniform_discrete(1, 10), :initial_n)

    if (@trace(bernoulli(p), :do_branch))
        n *= 2

    end

    return @trace(categorical([i == n ? 0.5 : 0.5 / 19 for i = 1:20]), :result)

end

trace = simulate(model, (0.3,))

# check traces generated
get_choices(trace)