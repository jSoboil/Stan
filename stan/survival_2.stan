data {
  int <lower = 0> N;
  real event_time[N];
  
}
parameters {
  real <lower = 0> lambda;
  
}
model {
  lambda ~ normal(0, 1);
  for (n in 1:N) {
    target += -lambda * event_time[n] + log(lambda);
  }
  
}
