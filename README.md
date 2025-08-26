# ⏳ Survival Analysis — Predicting *When* Events Happen  
**Dataquest Solutions** — practical guide, models, code snippets & business playbook

---

## TL;DR
Survival Analysis answers **“when”** an event occurs (churn, failure, default) while properly handling **censoring**. This README covers core concepts, non-/semi-/parametric models (Kaplan–Meier, Cox PH, Exponential, Weibull, Log-Normal, Log-Logistic), **AFT** (Accelerated Failure Time) models, diagnostics, model selection, practical tips, and ready-to-copy code (Python & R). :contentReference[oaicite:1]{index=1}

---

## Table of contents
1. [Why survival analysis?](#why-survival-analysis)  
2. [Core concepts & notation](#core-concepts--notation)  
3. [Types of censoring & truncation](#types-of-censoring--truncation)  
4. [Methods & models (what to try)](#methods--models-what-to-try)  
   - Kaplan–Meier (non-parametric)  
   - Cox Proportional Hazards (semi-parametric)  
   - Parametric models (Exponential, Weibull, Log-Normal, Log-Logistic)  
   - AFT (Accelerated Failure Time) models  
5. [Model selection, diagnostics & evaluation](#model-selection-diagnostics--evaluation)  
6. [Practical modeling pipeline](#practical-modeling-pipeline)  
7. [Pitfalls & best practices](#pitfalls--best-practices)  
8. [Mini case study (how to present results)](#mini-case-study-how-to-present-results)  
9. [Code snippets — Python (lifelines) & R (survival)](#code-snippets)  
10. [Further reading & references](#further-reading--references)  

---

## Why survival analysis?
Many business questions are **time-sensitive**: when will a customer churn, when will a machine fail, when will a loan default? Standard regression/classification ignores censoring (customers still active) and time-to-event structure. Survival analysis is built for **time-to-event** data and handles censoring correctly. :contentReference[oaicite:2]{index=2}

---

## Core concepts & notation
- **T** — random time to event.  
- **Event indicator** `E` (1 if event observed, 0 if censored).  
- **Survival function:**  
  \[
  S(t) = P(T > t)
  \]
- **Probability density & hazard:**  
  \[
  f(t) = \frac{d}{dt}(1 - S(t)),\qquad h(t) = \frac{f(t)}{S(t)}
  \]
  Hazard is the instantaneous risk at time *t* given survival up to *t*.

Understanding and visualizing \(S(t)\) and \(h(t)\) are central to interpretation.

---

## Types of censoring & truncation
- **Right censoring (most common):** subject still event-free at study end.  
- **Left censoring:** event occurred before observation window.  
- **Interval censoring:** event occurred between two observation times.  
- **Left truncation (delayed entry):** subject enters risk set after time 0.  

Correct handling of these is essential for unbiased estimates. :contentReference[oaicite:3]{index=3}

---

## Methods & models (what to try)

### 1) Kaplan–Meier (non-parametric)
- Estimate empirical survival curve without distributional assumptions.  
- Great first step for EDA and comparing groups (log-rank tests).  
- Plot KM curves for key cohorts to visualize differences. :contentReference[oaicite:4]{index=4}

### 2) Cox Proportional Hazards (semi-parametric)
- Model: hazard is product of baseline hazard and covariate effect:
  \[
  h(t|X) = h_0(t)\exp(\beta^T X)
  \]
- **Output:** hazard ratios (HR = \(e^\beta\)).  
- **Assumption:** proportional hazards (effect of covariates constant over time).  
- If PH holds → interpretable hazard ratios; if not, consider stratification, time-dependent covariates, or AFT/parametric models.

### 3) Parametric models (Exponential, Weibull, Log-Normal, Log-Logistic)  
Parametric models assume a specific distribution for survival times — useful for extrapolation and AFT parameterizations. Consider these families: :contentReference[oaicite:5]{index=5}

- **Exponential** — constant hazard \(h(t)=\lambda\). (rarely realistic but simple)  
- **Weibull** — flexible: hazard can increase, decrease or be constant depending on shape parameter (includes exponential as special case). Widely used in reliability engineering. :contentReference[oaicite:6]{index=6}  
- **Log-Normal** — log(T) ~ Normal; hazard often rises then falls (non-monotonic).  
- **Log-Logistic** — similar to log-normal but heavier tails; convenient closed-form survival function; useful when hazard peaks then declines.  
> Use parametric fits to extrapolate beyond observed time and to estimate median/percentiles when KM tails are thin.

### 4) Accelerated Failure Time (AFT) models
- AFT models directly model survival time:
  \[
  \log(T) = \mu + \beta^T X + \sigma\epsilon
  \]
- **Interpretation:** coefficients act multiplicatively on time (time ratios).  
  - \(e^\beta > 1\): covariate **extends** expected survival (slower to event).  
  - \(e^\beta < 1\): covariate **shortens** expected survival (accelerates event).  
- AFT is a natural alternative when PH assumption fails or when time-scale interpretation is preferred. :contentReference[oaicite:7]{index=7}

---

## Model selection, diagnostics & evaluation

### Model selection
- Compare models via **AIC / BIC / log-likelihood**.  
- Visual fit: overlay parametric survival curves on Kaplan–Meier.  
- Use **likelihood ratio tests** for nested models.

### Diagnostics
- **Proportional hazards test:** Schoenfeld residuals, `cox.zph()` in R, `check_assumptions()` in lifelines.  
- **Residuals:** Cox deviance or martingale residuals for functional form checks.  
- **Goodness-of-fit:** compare predicted vs observed survival (calibration), use time-dependent ROC or Brier score.  
- **Concordance (C-index):** discrimination metric for ranking risk/times.

### When to prefer which model
- Use **KM** for EDA and group comparisons.  
- Use **Cox** when PH holds and you want hazard ratios.  
- Use **AFT / parametric** when PH fails or you need direct time interpretation / extrapolation. :contentReference[oaicite:8]{index=8}

---

## Practical modeling pipeline (recommended)
1. **Data prep:** compute `duration` and `event` columns, encode covariates, handle missingness.  
2. **EDA:** KM curves by groups, summary tables, censoring patterns.  
3. **Non-parametric tests:** log-rank test for group differences.  
4. **Fit Cox PH:** check PH assumption → if satisfied, interpret HRs.  
5. **Fit parametric / AFT** models (Weibull, Log-Normal, Log-Logistic) and compare fits using AIC + visual overlays.  
6. **Validate:** time-split cross-validation, concordance, calibration plots, Brier score.  
7. **Deploy:** survival curves, predicted median survival/time-to-event percentiles, risk groups, monitoring.

---

## Pitfalls & best practices
- **Don’t ignore censoring.** Treat censored observations correctly.  
- **Check PH before trusting Cox HRs.** Violations change interpretation.  
- **Look at raw KM curves** before modeling — they reveal shape and heterogeneity.  
- **Beware overfitting** with many covariates and low event counts; use penalization or variable selection.  
- **Use competing risks models** if multiple event types preclude each other (e.g., death vs dropout).  
- **Document assumptions** and report uncertainty (CI for survival/median estimates).

---
