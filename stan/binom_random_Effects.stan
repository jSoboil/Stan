data {
  int <lower = 0> N;
  int <lower = 0> n_t[N];  // num cases, treatment
  int <lower = 0> r_t[N];  // num successes, treatment
}
parameters {
 vector[N] alpha_star;
 vector[N] delta;
 real tau;
 real nu;
 
}
transformed parameters {
 real OR;
 vector[N] mu;
 real p_t;
 OR = exp(nu);
 p_t = 1 / (1 + OR);
 mu = alpha_star + delta;
 
}
model {
 nu ~ normal(0, 1.0E6);
 tau ~ cauchy(0, 5);
 alpha_star ~ normal(0.0, 1.0E4);
 delta ~ normal(nu, tau);
 r_t ~ binomial_logit(n_t, mu);
}
