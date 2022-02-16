data {
 int <lower = 0> N;
 int <lower = 0> n_t[N];
 int <lower = 0> r_t[N];
 int <lower = 0> n_c[N];
 int <lower = 0> r_c[N]; 
}
parameters {
 real d;
 real <lower = 0> sigmasq_delta;
 vector[N] mu;
 vector[N] delta;
 real delta_new;
}
transformed parameters {
 real <lower = 0> sigma_delta;
 real OR;
 sigma_delta = sqrt(sigmasq_delta);
 OR = exp(d);
 
}
model {
 // Likelihood
 r_t ~ binomial_logit(n_t, mu + delta);
 r_c ~ binomial_logit(n_c, mu);
 
 // Priors
 delta ~ student_t(4, d, sigma_delta);
 mu ~ normal(0, sqrt(1.0E5));
 d ~ normal(0, 1E3);
 sigmasq_delta ~ uniform(0, 10);
 
 // PPC
 delta_new ~ student_t(4, d, sigma_delta);
}
