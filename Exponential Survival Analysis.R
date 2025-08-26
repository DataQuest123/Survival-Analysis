## Load required modules
library(survival)
library(flexsurv)
library(tidyverse)

## Load the data
dat <- read.csv("C:/Users/ADMIN/Desktop/Data Science/Datasets/survival/exponential_survival_data.csv")

## Quick check
glimpse(dat)
with(dat, table(status))

## Accelerates Failure Time
## It’s a type of survival model where the covariates are assumed to act by accelerating or decelerating the survival time directly, rather than modifying the hazard ratio (like in Cox PH models).

## Exponential model via survival::survreg (AFT form) 
## Note: survreg() with dist="exponential" fits an AFT model.
## Coefficients are on log(time) scale (time ratios). Negative coef -> shorter survival (higher hazard).
fit_aft <- survreg(Surv(time, status) ~ treatment + sex + age + biomarker,
                   data = dat, dist = "exponential")
summary(fit_aft)

## Model type
## You fit an Accelerated Failure Time (AFT) model with exponential distribution.
## Coefficients are on the log(time) scale.
## Positive coefficients → longer survival (slower hazard).
## Negative coefficients → shorter survival (faster hazard).

## Intercept (3.53): baseline log(survival time) when all covariates = 0. (Not usually of direct interest.)
## Treatment (0.31, p=0.065): Positive effect. Suggests treatment extends survival times by a factor of
## exp(0.314) ≈ 1.37.
## → Patients on treatment survive ~37% longer (median) than controls, but borderline significant.
## Sex (-0.20, p=0.231): Negative but not significant. Males (coded 1) tend to have ~18% shorter survival (exp(-0.202) ≈ 0.82), but evidence is weak.
## Age (-0.016, p=0.057): Each extra year of age decreases survival time by about exp(-0.016) ≈ 0.98 (~2% reduction per year). Marginal significance.
## Biomarker (-0.395, p < 0.001): Strongly negative. Each +1 SD increase in biomarker reduces survival time by exp(-0.395) ≈ 0.67.
## → That means about 33% shorter survival, highly significant.


## Model fit statistics
## Loglik(model) = -499.4 vs intercept-only = -513.3
## Likelihood ratio test: Chi² = 27.8, df=4, p < 0.0001
## → The covariates together significantly improve the model fit.
## Scale fixed at 1 → because exponential distribution has only one parameter (constant hazard).


## Summary of practical meaning
## Treatment appears beneficial (≈37% longer survival), though borderline significant (p=0.065).
## Older age trends toward worse survival (≈2% shorter per year, borderline p=0.057).
## Male sex shows worse survival (≈18% shorter), but not significant (p=0.231).
## High biomarker levels strongly predict worse survival (≈33% shorter per unit increase, p<0.001).
## So the biomarker is the strongest predictor, with treatment showing promising (but borderline) benefit.


## Convert AFT coef to approximate hazard ratios (HR ≈ exp(-beta_AFT))
## (Exact mapping differs because AFT vs PH, but this gives a handy interpretation.)
hr_aft <- exp(-coef(fit_aft))
cbind(HR_approx = hr_aft)

## Treatment (HR ≈ 0.73)
## → Hazard of death is about 27% lower for patients on treatment compared to control.
## → Protective effect, consistent with longer survival. Borderline significant from earlier p=0.065.

## Sex (HR ≈ 1.22)
## → Males have ~22% higher hazard compared to females.
## → Matches the negative coefficient in AFT (shorter survival for males), though not statistically significant (p=0.231).

## Age (HR ≈ 1.02)
## → Each additional year of age increases hazard by ~2%.
## → Over 10 years, hazard is ~22% higher (1.02^10 ≈ 1.22). Borderline significant (p=0.057).

## Biomarker (HR ≈ 1.49)
## → Each 1-unit increase in biomarker raises hazard by ~49%.
## → Strong, statistically significant predictor of poorer survival (p < 0.001).

## Intercept (0.029)
## → Not directly interpretable as a hazard ratio (it sets the baseline rate), so usually ignored.

## Take-home interpretation
## Treatment is protective (HR < 1).
## Sex (male), age, and especially biomarker are risk factors (HR > 1).
## Biomarker has the strongest impact: nearly 1.5× increase in hazard per unit.

## Exponential model via flexsurvreg (rate/PH form)
## Coefficients here are on the log-rate (log-hazard) scale; exp(coef) gives hazard ratios directly.
fit_ph <- flexsurvreg(Surv(time, status) ~ treatment + sex + age + biomarker,
                      data = dat, dist = "exponential")
fit_ph
exp(coef(fit_ph))  # hazard ratios

## Baseline
## rate = 0.029 (95% CI: 0.011 – 0.077)
## → This is the baseline hazard rate per unit time for a “reference” patient (when covariates = 0).
## It sets the overall time scale but is usually less interpretable than HRs.

## Treatment (HR 0.73)
## Patients on treatment have about a 27% lower hazard of death compared to controls. Borderline significant.
## Sex (male, HR 1.22)
## Males have ~22% higher hazard compared to females, but this is not statistically significant.

## Age (HR 1.02 per year)
## Each additional year increases hazard by about 2%. Over 10 years, hazard increases by ~22% (1.02^10 ≈ 1.22). Borderline significant.

## Biomarker (HR 1.49)
## Each +1 unit of the biomarker increases hazard by 49%. This is the strongest and most significant predictor in your model.

## Model fit
## Events = 141, Censored = 159 (about half censored, which is fine).
## Log-likelihood = -499.4, AIC = 1008.8 → this quantifies model fit; useful mainly for comparing models (e.g., exponential vs Weibull).

## Summary (practical interpretation)
## The treatment is protective (HR < 1), though borderline significant.
## Biomarker is the key risk factor, significantly raising hazard (HR ~1.5).
## Older age is linked to higher hazard (borderline).
## Sex (male) shows a higher hazard but is not statistically significant.
## In short: Treatment helps, but biomarker strongly drives risk, with age also playing a modest role.

## Predicted survival curves by group (flexsurv)
## Example: treatment=0 vs 1 at median covariate values
newdat <- data.frame(
  treatment = c(0,1),
  sex = median(dat$sex),
  age = median(dat$age),
  biomarker = median(dat$biomarker)
)

## Survival at specific times
predict(fit_ph, newdata = newdat, type = "survival", times = c(2,5,10))

## simple plot of model-based survival curves
## (Base R quickplot)
plot(fit_ph, type = "survival", newdata = newdat, ci = FALSE,
     xlab = "Time", ylab = "Survival probability")
legend("topright", legend = c("Control","Treatment"), lty = 1:2, bty = "n")
