# env Options -------------------------------------------------------------
# Set number of processing cores:
options(mc.cores = parallel::detectCores())


# Simple Fixed Effects model ----------------------------------------------
# Example found in Evidence Synthesis for Medical Decision Making, 
# Example 4.1, pages 78-81 rewritten in Stan.


## Load packages -----------------------------------------------------------
pkgs <- c("rstan", "bayesplot", "ggplot2")
sapply(pkgs, require, character.only = TRUE)

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
# Generally, random effects meta-regression models are preferred since, 
# theoretically, the residual heterogeneity, not explained by the included 
# covariates, is allowed for via the random effect term.

# Using a Binomial likelihood model for ORs is often preferable, since logistic
# regression is a special of the binomial model. The model is given by:

# r[Ai] ~ Binomial(p[Ai], n[Ai])         r[Bi] ~ Binomial(p[Bi], n[Bi])
# logit(p[Ai]) = µ[i]                    logit(p[Bi]) = µ[i] + ∂[i] + ßx[i]
# ∆[i] ~ Normal(d, tau^2)                i = 1, ..., k

# ß * x[i] (the regression coefficient multiplied by the covariate value for the 
# i'th study) has been added to the linear predictor for the effect in the 
# treatment group.

## Load data ---------------------------------------------------------------
# Treatment non-vaccinated = A
r_c <- c(11, 29, 11, 248, 47, 372, 10, 499, 45, 65, 141, 3, 29)
n_c <- c(139, 303, 220, 12867, 5808, 1451, 629, 88391, 7277, 1665, 
        27338, 2342, 17854)
# Treatment vaccinated = B
r_t <- c(4, 6, 3, 62, 33, 180, 8, 505, 29, 17, 186, 5, 27)
n_t <- c(123, 306, 231, 13598, 5069, 1541, 2545, 88391, 7499, 1716, 
        50634, 2498, 16913)
# Latitude of studies:

# Data list for Stan input:
data_list <- list(J = length(r_c), 
                  r_c = r_c, r_t = r_t, 
                  n_c = n_c, n_t = n_t)
# Run model:
bin_random_Effects <- stan(file = "stan/binom_random_Effects.stan",
                           data = data_list, chains = 4, 
                           refresh = 500)
print(bin_random_Effects)















