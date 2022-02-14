data {
 int <lower = 0> N;         // define number of schools as int, with lower bound 0
 real <lower = 0> V[N];     // variance of effect estimates
 
 real Y[N];                 // linear response, estimated treatment effects
 
}
parameters {
  real theta[N];            // per-trial treatment effect
  real mu;                  // mean treatment effect
  real <lower = 0> tau;     // deviation of treatment effects
 
}
transformed parameters {
 real OR = exp(mu);         // transform LOR to OR
 
}
model {
 // Likelihood
 for (i in 1:N) {
  Y[i] ~ normal(theta[i], V[i]); 
  
  theta[i] ~ normal(mu, tau); // random effect on mu
 }
 // Priors
 mu ~ normal(0, 10);        // prior on mu
 tau ~ cauchy(0, 5);        // prior on tau
 
}
