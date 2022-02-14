data {
 int <lower = 0> N;         // define number of schools as int, with lower bound 0
 real <lower = 0> V[N];     // variance of effect estimates (between schools),
 real Y[N];                 // linear response, estimated treatment effects
 
}
parameters {
 real mu;                   // population mean, with implicit uniform prior
 
}
model {
// Likelihood
 for (j in 1:N) {
  Y[j] ~ normal(mu, V[j]); 
 }
 // Priors
 mu ~ normal(0, 100);      // prior on mu
 
}
