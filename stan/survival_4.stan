data {
  int <lower = 0> N;                       // declare vector N and set dim
  real event_time[N];                      // declare array event_time and set dim
  int <lower = 0, upper = 1> treatment[N]; // declare array treatment and set dim
  int <lower = 0, upper = 1> censored[N]; // declare array censored and set dim

}
parameters {
  real <lower = 0> lambda; // declare parameter lambda
  real beta;               // declare parameter beta
  
}
model {
  for (n in 1:N) {
   real lambda_n = lambda * exp(treatment[n] * beta); // transform lambda
  // Conditional logic for censoring
  if (censored[n] == 0) {
  // Likelihood for censored
   target += -lambda_n * event_time[n] + log(lambda_n);   
  } else {
  // Likelihood for uncensored
   target += -lambda_n * event_time[n];
   }
  }
  // Priors
  beta ~ normal(0, 1);    // normal prior on beta
  lambda ~ normal(0, 1);  // normal prior on lambda
  
}
