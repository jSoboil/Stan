data {
 int <lower = 0> J;         // define number of schools as int, with lower bound 0
 real <lower = 0> sigma[J]; // s.e.'s of effect estimates (between schools),
                            // lower bound 0
 real y[J];                 // linear response, estimated treatment effects
 
}

parameters {
 real mu;                   // population mean, with implicit uniform prior
 vector[J] eta;             // school-level errors (in schools)
 real <lower = 0> tau;      // population sd, lower bound 0

}

transformed parameters {
 vector[J] theta;           // school effects
 theta = mu + tau * eta;    // theta is a linear combination of...
 
}

model {
// Likelihood
 for (j in 1:J) {
  y[j] ~ normal(theta[j], sigma[j]); 
 }
// Priors
 eta ~ normal(0, 1);
 tau ~ cauchy(0, 25);
 
}

