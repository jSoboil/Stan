# Load libraries ---------------------------------------------------------
library(rstan)
options(mc.cores = parallel::detectCores())


# Load and process data ---------------------------------------------------
schools <- data.frame(school = c("A", "B", "C", "D", "E", "F", "G", "H"),
                      estimate = c(28,  8,  -3,   7,  -1,   1,  18,  12),
                      sd = c(15,   10,  16,  11,   9,  11,  10,  18)
                      )
schools
# Define groups etc.
J <- nrow(schools)
y <- schools$estimate
sigma <- schools$sd

# Fit model ---------------------------------------------------------------
# Run Stan with 4 chains of 1000 iterations each and display results numerically 
# and graphically:
schools_fit <- stan(file = "stan/schools.stan", 
                    data = c("J", "y", "sigma"))
print(schools_fit)
plot(schools_fit)

# Accessing posterior simulations in R ------------------------------------
schools_sim <- extract(schools_fit)
schools_sim

# This exracts a list with elements corresponding to the quantities assessed in 
# the model. In this case, this is theta, eta, mu, tau, lp__. The vector \theta
# of length 8 becomes a 20000 * 8 matrix of simulations; similarly, \eta; the 
# scalars \mu and \tau each become a vector of 20000 draws, and the 20000 draws of
# the unnormalised log posterior density are saved as the last element of the list.

# As an example, we can display the posterior inference for \tau
hist(schools_sim$tau)
# or compute the posterior probability that the effect is larger in school A than 
# C:
mean(schools_sim$theta[, 1] > schools_sim$theta[, 3])

# Posterior predictive simulations and graphs in R ------------------------
# After convergence, we can work directly with \theta, \mu, \tau. E.g., we can
# simulate posterior predictive replicated data in the original 8 schools as 
# follows:
n_sims <- length(schools_sim$lp__)
y_rep <- array(NA, c(n_sims, J))
for (s in 1:n_sims) {
 y_rep[s, ] <- rnorm(J, schools_sim$theta[s, ], sigma)
}
# We can now create a graphical posterior predictive check:
par(mfrow = c(5, 4), mar = c(2, 2, 2, 2))
hist(y, xlab = "", main = "y")
for (s in 1:19) {
 hist(y_rep[s, ], xlab = "", main = paste("y_rep", s))
}

# We could also compute a numerical test statistic such as a difference in 
# difference, for example the difference between the best and second-best of the
# 8 coaching programmes:
test <- function(y) {
 y_sort <- rev(sort(y))
 return(y_sort[1] - y_sort[2])
}
t_y <- test(y)
t_rep <- rep(NA, n_sims)
for (s in 1:n_sims) {
 t_rep[s] <- test(y_rep[s, ])
}

# We can then summarise the posterior predictive check. The following gives a 
# numerical comparison of the test statistic to its replication distribution, a
# p-value, and a graph:
par(mfrow = c(1, 1))
cat("T(y) =", round(t_y, 1), " and T(y_rep) has mean", 
    round(mean(t_rep), 1), " and sd", round(sd(t_rep), 1), 
    "\nPr (T(y_rep) > T(y) =", round(mean(t_rep > t_y), 2), "\n")
hist_0 <- hist(t_rep, xlim = range(t_y, t_rep), xlab = "T(y_rep)")
lines(rep(t_y, 2), c(0, 1e6))
text(t_y, 0.9 * max(hist_0$count), "T(y)", adj = 0)

# Replicated data in new schools ------------------------------------------
# Another form of replication would be to simulate new parameter values and new 
# data for eight *new* schools. To simulate data y_i ~ N(\theta_j, \sigma^2_j) 
# from new schools, it is necessary to make some assumption or model for the data
# variances \sigma^2_j. Here, we assume that these are repeated from the original
# 8 schools...
theta_rep <- array(NA, c(n_sims, J))
y_rep <- array(NA, c(n_sims, J))
for (s in 1:n_sims) {
 theta_rep[s, ] <- rnorm(J, schools_sim$mu[s], schools_sim$tau[s])
 y_rep[s, ] <- rnorm(J, theta_rep[s, ], sigma)
}
# And then you investigate as same as above.

# End file ----------------------------------------------------------------