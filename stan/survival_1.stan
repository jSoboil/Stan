data {
  int <lower = 0> N;
  real event_time[N];
  
}
parameters {
  real <lower = 0> lambda; //implicit uniform prior on lambda
  
}
model {
  lambda ~ normal(0, 1);
  
}
