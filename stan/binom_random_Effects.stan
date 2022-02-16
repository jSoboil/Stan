data {
 // Data
 int <lower = 0> N;          // N studies
 int <lower = 0> n_t[N];     // n_t obs (vaxxed)
 int <lower = 0> r_t[N];     // r_t events (vaxxed)
 int <lower = 0> n_c[N];     // n_c obs (non-vaxx)
 int <lower = 0> r_c[N];     // r_c events (non-vaxx)
 vector[N] lat;              // latitude of each study
}
transformed data {
 // Transformed data
 vector[N] centered_lat;      // centered covariate
 real mean_lat;
 mean_lat = mean(lat);
 centered_lat = lat - mean_lat;
}
parameters {
 // Parameters
 real d;                          // mean treatment effect
 real <lower = 0> sigmasq_delta;  // std of delta
 real beta;                       // coefficient beta_1
 vector[N] mu;                    // ave. LOR of event
 vector[N] delta;                 // random effect
 real delta_new;                  // ppc for random effect
}
transformed parameters {
 // Transformed parameters
 real <lower = 0> sigma_delta; // transformed variance to std
 real OR;
 sigma_delta = sqrt(sigmasq_delta);
 OR = exp(d);                  // transform LOR to OR
}
model {
 // Likelihood
 r_t ~ binomial_logit(n_t, mu + delta + beta * centered_lat); // treatment
 r_c ~ binomial_logit(n_c, mu);                               // control
 // Priors
 delta ~ student_t(4, d, sigma_delta);    // prior on random effect
 mu ~ normal(0, sqrt(1.0E5));             // prior on ave. prob of event
 d ~ normal(0, 1E3);                      // prior on ave. treatment effect
 sigmasq_delta ~ uniform(0, 10);          // std for delta
 // PPC
 delta_new ~ student_t(4, d, sigma_delta); // ppc for delta
 // Coefficients
 beta ~ normal(0, sqrt(1.0E6));            // beta_1 coefficient
}
// End file
