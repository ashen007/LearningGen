using Gen
using CSV
using DataFrames
using Plots
using StatsPlots
using Distributions: Normal

@gen function height_model(n)
    # latent variables
    mu = @trace(normal(178, 20), :mu)
    sigma = @trace(uniform(0, 50), :sigma)

    for i in 1:n
        @trace(normal(mu, sigma), "h-$i")

    end
    
end

function do_inference(model, args, obs, iters)
    observations = choicemap()

    for (i, x) in enumerate(obs)
        observations["h-$i"] = x
    
    end

    (trace, ) = generate(model, args, observations)
    
    for iter=1:iters
        (trace, ) = metropolis_hastings(trace, Gen.select(:mu))
        (trace, ) = metropolis_hastings(trace, Gen.select(:sigma))

    end

    choices = get_choices(trace)

    return (choices[:mu], choices[:sigma])

end

kung = CSV.read("data/Howell1.csv", DataFrame)
adult = kung[kung.age .>= 18, :]

observations = choicemap()

for (i, x) in enumerate(adult.height)
    observations["h-$i"] = x

end


(trace, ) = generate(height_model, (10,), observations)
get_choices(trace)

trace_mcmc = do_inference(height_model, (10,), adult.height, 1000)

g = density(adult.height)

for _=1:20
    mu, sigma = do_inference(height_model, (10,), adult.height, 1000)
    g = density!(rand(Normal(mu, sigma), 300)) 
    
end

plot(g)