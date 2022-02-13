# Constant hazards --------------------------------------------------------
library(survival)
library(ggplot2)
library(gridExtra)

library(rstan)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")
options(mc.cores = parallel::detectCores())


t <- 0:100
lambda <- 0.1

surv <- data.frame(t = t, h = lambda, Lambda = lambda * t, S = exp(-lambda * t))

p_1 <- ggplot(surv, aes(x = t, y = surv$h)) + 
 geom_line() + ggtitle('hazard function')

p_2 <- ggplot(surv, aes(x = t, y = surv$Lambda)) + 
 geom_line() + 
 ggtitle('cumulative hazard function')

p_3 <- ggplot(surv, aes(x = t, y = surv$S)) + 
 geom_line() + 
 ggtitle('survival function')


grid.arrange(arrangeGrob(p_1, p_2, ncol = 2), p_3)

# Model 1 -----------------------------------------------------------------
# This model has no likelihood...
N <- 100
p <- runif(N)
lambda <- 0.1
event_time <- -log(1 - p) / lambda

data_list <- list(
 N = length(event_time), event_time = event_time)

surv_mod <- stan(file = "stan/survival_1.stan", 
                 data = c("N", "event_time"), 
                 seed = 123, chains = 4, 
                 refresh = 500)

print(surv_mod)
surv_sim <- extract(surv_mod)
hist(surv_sim$lambda)

# Model 2 -----------------------------------------------------------------
lambda <- 0.1
beta <- log(0.5)

N <- 100
treatment <- sample(c(0, 1), size = N, replace = TRUE)
p <- runif(N)
event_time <- -log(1 - p) / (lambda * exp(treatment * beta))

# Plot KM
Y <- Surv(event_time)
plot(survfit(Y ~ treatment))
# Without coefficient
curve(exp(-x * lambda), add = TRUE, col = "blue")
# With coefficient
curve(exp(-x * lambda * exp(beta)), add = TRUE, col = "green")

# But we need the likelihood for each observation. So, what's the likelihood of an 
# event at time t?

# The survival time, T, is greater than or equal to t (t = event_time), which
# notationally is Pr(T >= t) = S(t)

# The instantaneous rate is h(t).

# Hence, the constant hazard model likelihood is exp(-\lambda * t) * \lambda and
# the log-likelihood is -\lambda * t + log(\lambda). So, we must increment the 
# log likelihood using target +=, which uses C++ notation for incrementation.

surv_mod <- stan(file = "stan/survival_2.stan", 
                 data = c("N", "event_time"), 
                 seed = 123, chains = 4, 
                 refresh = 500)

print(surv_mod)
surv_sim <- extract(surv_mod)
hist(surv_sim$lambda)

# Cox Proportional Hazards ------------------------------------------------
# A survival model that accounts for covariates. 

# Modeling assumptions:
#  - Covariates matter
#  - Covariates effect hazard rate multiplicatively

# Hazard function is defined as h(t) = h_0(t) exp(X * \beta)

# Two components:
#  - Baseline hazard function...
# which is defined as h_0(t) (or \lambda_0(t))

#  - Effect of covariates...
# which is defined as exp(X * \beta)
#  X are the matrix covariates (for an individual), \beta are parameters. 
# If X is 0, the effect is 1. Note: no time-varying effect of covariates.

# Simulate data with treatment:
lambda <- 0.1
beta <- log(0.5)

N <- 100
treatment <- sample(c(0, 1), N, replace = TRUE)
p <- runif(N)
event_time = -log(1 - p) / (lambda * exp(treatment * beta))

# KM curve...
Y <- Surv(event_time)
plot(survfit(Y ~ treatment))
curve(exp(-x * lambda), add = TRUE, col = "blue")
curve(exp(-x * lambda * exp(beta)), add = TRUE, col = "green")

# Run model
surv_mod <- stan(file = "stan/survival_3.stan", 
                 data = c("N", "event_time", "treatment"), 
                 seed = 123, chains = 4, 
                 refresh = 500)

print(surv_mod)
surv_sim <- extract(surv_mod)
hist(surv_sim$lambda)

# Right Censoring ---------------------------------------------------------
# Simulate right censored data. Event occurs after some known time.
lambda <- 0.1
beta <- log(0.5)
censor_time <- 40

N <- 100
treatment <- sample(c(0, 1), N, replace = TRUE)
p <- runif(N)
true_event_time = -log(1 - p) / (lambda * exp(treatment * beta))
censored <- ifelse(true_event_time > censor_time, 1, 0)
event_time <- pmin(true_event_time, censor_time)

## KM Curves:
Y <- Surv(event_time, censored == 0)
plot(survfit(Y ~ treatment))
curve(exp(-x * lambda), add = TRUE, col = "blue")
curve(exp(-x * lambda * exp(beta)), add = TRUE, col = "green")

# Stan model:
surv_mod <- stan(file = "stan/survival_4.stan", 
                 data = c("N", "event_time", "treatment", "censored"), 
                 seed = 123, chains = 4, 
                 refresh = 500)

print(surv_mod)
surv_sim <- extract(surv_mod)
hist(surv_sim$lambda)

# End file ----------------------------------------------------------------