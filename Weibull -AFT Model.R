## A Weibull model is a type of parametric survival analysis model used to study the time until an event occurs (such as death, relapse, machine failure, etc.). It assumes that survival times follow a Weibull distribution, which is very flexible because it can model increasing, decreasing, or constant hazard rates depending on the shape parameter.
## Load required packaeges
library(survival)
library(flexsurv)
library(tidyverse)

## Load the data
dat <- read.csv("C:/Users/ADMIN/Desktop/Data Science/Datasets/survival/weibull_survival_data.csv")

## Quick check
glimpse(dat)
with(dat, table(status))

## Weibull AFT model with survreg 
fit_aft <- survreg(Surv(time, status) ~ treatment + sex + age + biomarker,
                   data = dat, dist = "weibull")
summary(fit_aft)

## Model type
## Distribution: Weibull.
## This is an AFT model, meaning coefficients describe how covariates accelerate or decelerate survival time.
## Positive coefficient → longer survival (protective).
## Negative coefficient → shorter survival (risk factor).

## Coefficients
## Intercept (3.23): baseline log survival time (not directly meaningful).

## Treatment (0.77, p < 0.001)
## → Strong positive effect.
## → exp(0.774) ≈ 2.17 → treatment patients live about 2.2× longer (median survival) than controls.

## Sex (-0.31, p = 0.011)
## → Males have shorter survival.
## → exp(-0.313) ≈ 0.73 → survival time is 27% shorter compared to females.

## Age (-0.004, p = 0.396)
## → Not statistically significant.
## → Each year of age reduces survival time by only ~0.4%.

## Biomarker (-0.51, p < 0.001)
## → Strong negative effect.
## → exp(-0.51) ≈ 0.60 → higher biomarker values reduce survival by 40% per unit.

## Scale Parameter
## Interpretation:
## k > 1 (here 1.4) → hazard increases with time (aging or disease progression risk rises).
## If k = 1, it reduces to the exponential model (constant hazard).
## So your data suggest risk of failure grows over time.

## Model fit
## Log-likelihood = -544.5 vs intercept-only = -587.2
## Likelihood ratio χ² = 85.3, p < 0.0001
## → Covariates significantly improve fit.

## Practical summary
## Treatment greatly prolongs survival (~2.2× longer).
## Males have worse survival (~27% shorter).
## Biomarker is the strongest risk factor (40% shorter survival per unit increase).
## Age shows no significant effect in this model.
## Shape parameter (k ≈ 1.4) tells us hazard increases over time → Weibull fits better than exponential here.

## Weibull PH model with flexsurv 
fit_ph <- flexsurvreg(Surv(time, status) ~ treatment + sex + age + biomarker,
                      data = dat, dist = "weibull")
fit_ph
exp(coef(fit_ph))   # hazard ratios

## Covariate Effects (exp(est) = Hazard Ratio)
## These are interpreted like hazard ratios in Cox regression:
## Treatment
## HR = 2.17 (95% CI: 1.66 – 2.83)
## Patients on treatment have more than twice the hazard (risk of event) compared to the control group.
## Suggests treatment is harmful in this simulated dataset.

## Sex
## HR = 0.73 (95% CI: 0.57 – 0.93)
## Being in the coded sex group (likely female if male=0, female=1) reduces hazard by ~27%.
## That group has better survival.

## Age
## HR = 0.996 (95% CI: 0.986 – 1.006)
## Very close to 1, not statistically significant.
## No strong effect of age on survival in this dataset.

## Biomarker
## HR = 0.60 (95% CI: 0.52 – 0.70)
## Higher biomarker levels are associated with a 40% lower hazard.
## Suggests biomarker is protective.

## Interpretation in Plain Words
## The hazard of dying increases over time (Weibull shape > 1).
## Treatment increases risk, possibly harmful.
## One sex (coded as "1") survives longer than the other.
## Biomarker protects against death.
## Age doesn’t play a big role here (not significant).

## Survival predictions 
newdat <- data.frame(
  treatment = c(0,1),
  sex = 0,
  age = 60,
  biomarker = 0
)
plot(fit_ph, type="survival", newdata=newdat, ci=FALSE,
     xlab="Time", ylab="Survival probability")
legend("topright", legend=c("Control","Treatment"), lty=1:2, bty="n")
