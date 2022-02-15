data {
  int <lower = 0> J;
  int <lower = 0> n_t[J];  // num cases, treatment
  int <lower = 0> r_t[J];  // num successes, treatment
  int <lower = 0> n_c[J];  // num cases, control
  int <lower = 0> r_c[J];  // num successes, control
}
parameters {
  real mu[J];            // mean treatment effect
  real <lower=0> tau;  // deviation of treatment effects
  real eta[J];
}
transformed parameters {
 real theta[J];      // per-trial treatment effect
 for (j in 1:J) {
  theta[j] = logit(mu[j] + eta[j]);
 }
}
model {
 for (j in 1:J) {
 // Likelihood
 
 
 
 
 // Random intercept/effect
  mu[j] ~ normal(0, 10);
 }
}