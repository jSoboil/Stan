# env Options -------------------------------------------------------------
# Set number of processing cores:
options(mc.cores = parallel::detectCores())


# Simple Fixed Effects model ----------------------------------------------
# Example found in Evidence Synthesis for Medical Decision Making, 
# Example 4.1, pages 78-81 rewritten in Stan.


## Load packages -----------------------------------------------------------
library(rstan)
library(bayesplot)
library(ggplot2)


## Data --------------------------------------------------------------------
Y <- c(-.3289, -.3845, -.2196, -.2222, -.2255, .1246, -.1110)
V <- c(.0389, .0412, .0205, .0648, .0352, .0096, .0015)
data <- list(N = length(Y), Y = Y, V = V)

mod_fixed_Effects <- stan(file = "stan/fixed_effects.stan",
                      data = data, seed = 4, chains = 4,
                      refresh = 500)

print(mod_fixed_Effects)
sims_fixedEffects <- extract(mod_fixed_Effects)
hist(sims_fixedEffects$mu)

# Inspection:
mcmc_dens(mod_fixed_Effects)
mcmc_trace(mod_fixed_Effects)
mcmc_trace_highlight(mod_fixed_Effects)

# Simple Random Effects model ---------------------------------------------
# Since variances cannot go negative, a Normal distribution with mean zero and 
# large variance is not a viable option:

# ... tau ~ dunif(0, 10)

# ... a value of 10 for the between study standard deviation is very large on the 
# LOR scale and thus this prior distribution covers all plausible values.
mod_random_Effects <- stan(file = "stan/random_effects.stan",
                           data = data, seed = 4, chains = 4, 
                           refresh = 500, iter = 10000)

print(mod_random_Effects)
sims_randomEffects <- extract(mod_random_Effects)
hist(sims_fixedEffects$mu)

# Inspection:
mcmc_dens(mod_random_Effects)
mcmc_trace(mod_random_Effects)
mcmc_trace_highlight(mod_random_Effects)

# Binomial Random Effects model -------------------------------------------