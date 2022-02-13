data {
  int <lower = 0> N;                       // declare N
  real event_time[N];                      // set dim
  int <lower = 0, upper = 1> treatment[N]; // set dim
  
}
parameters {
  real <lower = 0> lambda; // define lambda
  real beta;               // define beta
  
}
model {
  for (n in 1:N) {
   real lambda_n = lambda * exp(treatment[n] * beta); // transform lambda
  // Likelihood
   target += -lambda_n * event_time[n] + log(lambda_n);
  }
  // Priors
  beta ~ normal(0, 1);    // normal prior on beta
  lambda ~ normal(0, 1);  // normal prior on lambda
  
}
