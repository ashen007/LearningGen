using Gen
using Distributions: Binomial

@gen function glob_toss(n)
    # a latent variable, variables can not directly observe
    p = @trace(beta(1, 1), :p)

    # variable that will be observed
    @trace(binom(n, p), :w)

end

function do_inference(model, args, obs, iters)
    observations = choicemap((:w, obs))

    (trace, ) = generate(model, args, observations)

    for iter=1:iters
        (trace, ) = metropolis_hastings(trace, Gen.select(:p))

    end

    choices = get_choices(trace)
    return (choices[:p])
    
end

observations = choicemap((:w, 6))
trace, = generate(glob_toss, (9,), observations)

get_choices(trace)

trace = do_inference(glob_toss, (36,), 24, 1000)
