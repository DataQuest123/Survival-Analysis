## Load necessary libraries
library(survminer)
library(survival)
library(flexsurv)
library(tidyverse)

## Load and inspect the dataset
data <- read_csv("C:/Users/ADMIN/Desktop/Data Science/Datasets/survival/cirrhosis.csv")
glimpse(data)
anyNA(data)
data <- drop_na(data)
any(duplicated(data))


## Handle missing data
data$Drug = data$Drug %>% replace_na("unknown")
data$Ascites = data$Ascites %>% replace_na("unknown")
data$Spiders = data$Spiders %>% replace_na("unknown")
data$Hepatomegaly = data$Hepatomegaly %>% replace_na("unknown")
median(data$Copper, na.rm = T)
data$Copper = data$Copper %>% replace_na(73)
median(data$Alk_Phos, na.rm = T)
data$Alk_Phos = data$Alk_Phos %>% replace_na(1259)
median(data$Platelets, na.rm = T)
data$Platelets = data$Platelets %>% replace_na(251)
median(data$SGOT, na.rm = T)
data$SGOT = data$SGOT %>% replace_na(114.7)
median(data$Cholesterol, na.rm = T)
data$Cholesterol = data$Cholesterol %>% replace_na(309.5)
median(data$Prothrombin, na.rm = T)
data$Prothrombin = data$Prothrombin %>% replace_na(10.6)
median(data$Tryglicerides, na.rm = T)
data$Tryglicerides = data$Tryglicerides %>% replace_na(108)
data = drop_na(data)


## Convert character variables to factors
data <- data %>% mutate_if(is.character, as.factor)

## Exploratory Data Analysis
## Histogram of survival time
ggplot(data, aes(x = N_Days)) +
  geom_histogram(bins = 15, fill = "steelblue", color = "white") +
  theme_bw()+
  labs(title = "Distribution of Survival Time", x = "Time", y = "Frequency")

## Bar plot of event status
ggplot(data, aes(x = Status)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Event Status Distribution", x = "Status", y = "Count") +
  theme_bw()

## Distribution of Survival time by status
## Barplot
data %>% group_by(Status) %>% 
  summarize(mean = mean(N_Days)) %>% 
  ggplot(aes(x = Status, y = mean))+
  geom_bar(stat = "identity", fill = "steelblue", color = "white")+
  theme_bw()+
  labs(title = "Distribution of Survival Time by Status", y = "Days")

## Boxplot
ggplot(data, aes(y = N_Days, x = Status)) +
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  labs(title = "Distribution of Survival Time by Status", x = "Status", y = "Days") +
  theme_minimal()

## Define numeric variables
numeric_vars <- c("Age", "Bilirubin", "Albumin", "Cholesterol", 
                  "Copper", "Alk_Phos", "SGOT", "Tryglicerides", 
                  "Platelets", "Prothrombin", "Stage")

## Plot boxplots of each variable by Status
## Use tidy evaluation in ggplot
for (var in numeric_vars) {
  p <- ggplot(data, aes(x = Status, y = .data[[var]], fill = Status)) +
    geom_boxplot(alpha = 0.7, show.legend = F) +
    labs(title = paste("Boxplot of", var, "by Event Status"), x = "Status", y = var) +
    theme_minimal()
  print(p)
}

## What is the probability of survival over time for cirrhosis patients?
## How does survival differ between treatment groups (D-penicillamine vs. placebo)?
## Kaplan-Meier Model
## Create a new event indicator for death: 1 = Death, 0 = Censored or Transplant
data$death_event <- ifelse(data$Status == "D", 1, 0)

## Create survival object
surv_obj <- Surv(time = data$N_Days, event = data$death_event)

## Fit KM model for all patients (no stratification)
km_fit <- survfit(surv_obj ~ 1, data = data)

## View summary
summary(km_fit)


# Or create a data frame of the table
life_table <- data.frame(
  time = km_fit$time,
  n_risk = km_fit$n.risk,
  n_event = km_fit$n.event,
  survival_prob = km_fit$surv
)

print(life_table)

## At day 41, 1 death occurred among 276 people still at risk; survival probability dropped to 99.6%.
## By day 198, 4 deaths have occurred in total, and the probability of surviving beyond this time is 96%.
## About 75.6% of patients are expected to survive beyond day 1444.
## As time progresses, survival probability steadily declines, which is expected in clinical survival data.
## The survival curve is likely smooth and descending, with small drops at each death time.

## Basic KM plot
plot(km_fit, xlab = "Days", ylab = "Survival Probability", 
     main = "Kaplan-Meier Curve - Death Event", col = "darkred", lwd = 2)

## Fit KM curves by sex
km_sex <- survfit(surv_obj ~ Sex, data = data)
summary(km_sex)

## Female Patients (Sex = F)
## Initial n.risk: 242
## Survival probability decreases gradually, from 0.996 at day 41 to ~0.368 at day 3853.
## The standard error grows slowly (starting from 0.00412), indicating increasing uncertainty in the estimates as time progresses and fewer individuals remain.
## The survival curve is long and steady, with many small drops over time, suggesting more censored data and slower death accumulation.
## Key insight: Females show more gradual declines in survival with relatively better long-term survival.

## Male Patients (Sex = M)
## Initial n.risk: 34 (much fewer than females)
## Survival probability drops sharply, from 0.971 at day 140 to 0.163 at day 4191.
## The standard error is larger (starting at 0.0290), and the confidence intervals are wider, reflecting higher uncertainty due to the smaller sample size.
## Survival probability drops more rapidly than in females.
## Key insight: Male patients exhibit poorer survival outcomes, with faster and more pronounced drops in survival probability over time.

## Plot with legend
plot(km_sex, col = c("darkblue", "darkgreen"), lwd = 2,
     xlab = "Days", ylab = "Survival Probability", 
     main = "Kaplan-Meier Curve by Sex")
legend("bottomleft", legend = levels(data$Sex), 
       col = c("darkblue", "darkgreen"), lwd = 2)

## Log-rank test
survdiff(surv_obj ~ Sex, data = data)

## Observed: Actual number of deaths.
## Expected: Number of deaths expected if survival were the same across groups.
## (O−E)^2/E: Measures how different observed deaths are from expected.
## Male patients experienced more deaths than expected, suggesting worse survival.
## Female patients had fewer deaths than expected, suggesting better survival.

##Chi-Square Test
## A p-value < 0.05 indicates statistically significant difference in survival between males and females.

## Conclusion
## There is a significant difference in survival by sex (p = 0.03), with males showing worse survival outcomes than females over time.

## Kaplan Meier Curves by Stage
## Convert Stage to factor 
data$Stage <- factor(data$Stage)

## KM fit by Stage
km_stage <- survfit(surv_obj ~ Stage, data = data)
summary(km_stage)

##Stage 1:
## Patients at Stage 1 had a relatively high survival probability. At the last recorded time (2386 days), survival was 87.5%, with a wide confidence interval due to small sample size (only 8 people at risk). Only 1 event (death) occurred, showing this group has the best prognosis.

## Stage 2:
## Patients show gradual declines in survival over time. Initially, survival is very high (98.3%), but it steadily drops as time progresses. By around 4079 days, survival drops to 39.7%, with increasing uncertainty (standard error and confidence intervals widen). This group starts well but worsens significantly in the long term.
                                                                                                  
## Stage 3:
## Survival in Stage 3 starts very high but declines more steeply than Stage 2. By about 4191 days, survival drops to 31.8%. This suggests worse outcomes than Stage 2, with a sharper decline and consistent loss of patients across time. The decreasing number at risk supports a pattern of ongoing events (deaths).
                                                                                                  
## Stage 4:
## This group shows the worst survival profile. Survival begins near 99% but declines rapidly. By just over 3760 days, survival drops to 14.8%. The drop is consistent and steep, and the confidence intervals tighten initially but widen significantly later, reflecting both high mortality and fewer people remaining.
                                                                                                  
## Overall Interpretation:
## Survival probability decreases with increasing stage of disease. Stage 1 has the best prognosis, followed by Stage 2, then Stage 3. Stage 4 shows the worst survival, with early and steady mortality. The consistent decline in higher stages highlights the clinical importance of early diagnosis and intervention.

## Plot
plot(km_stage, col = rainbow(length(levels(data$Stage))), lwd = 2,
     xlab = "Days", ylab = "Survival Probability", main = "KM Curve by Stage")
legend("bottomleft", legend = levels(data$Stage), col = rainbow(length(levels(data$Stage))), lwd = 2)

## Log-rank test
survdiff(surv_obj ~ Stage, data = data)

## Kaplan Meier Curve for Ascites
data$Ascites <- factor(data$Ascites)

km_ascites <- survfit(surv_obj ~ Ascites, data = data)
summary(km_ascites)

## Patients Without Ascites (Ascites = N):
## These patients started with a large group (n = 257), and their survival probability declined slowly over time. At early time points, the probability remained above 95%, showing a favorable prognosis. The decline is gradual and consistent, and by the final observed time, survival probability is about 33.5%, with reasonable confidence intervals. The standard error remains low to moderate, indicating more reliable estimates due to the large sample size.
## This pattern indicates that patients without ascites live longer and experience fewer deaths over time compared to those with ascites.

## Patients With Ascites (Ascites = Y):
## This group had a smaller sample size (n = 19) and experienced a rapid decline in survival. By the time 400 days pass, survival drops to 31.6%, and it plummets to 0% by 3090 days. The confidence intervals widen quickly, and the standard error is high, indicating more variability and uncertainty in the estimates—partly due to the smaller number at risk.
## This suggests that ascites is strongly associated with a worse survival outcome, as patients with ascites died significantly earlier than those without.

## Overall Interpretation:
## The survival probability for patients without ascites is substantially higher and more stable over time than for those with ascites. Ascites is a poor prognostic factor—patients with it show early and steep declines in survival, while those without it have a better and longer survival trajectory.

plot(km_ascites, col = c("darkblue", "darkorange"), lwd = 2,
     xlab = "Days", ylab = "Survival Probability", main = "KM Curve by Ascites")
legend("bottomleft", legend = levels(data$Ascites), col = c("darkblue", "darkorange"), lwd = 2)

## Log rank test
survdiff(surv_obj ~ Ascites, data = data)

## Life tables
## Group survival times into intervals (every 100 days)
data$interval <- cut(data$N_Days, breaks = seq(0, max(data$N_Days), by = 100), right = FALSE)

## Use tapply or dplyr to summarize events/censored by interval
tbl = table(data$interval, data$death_event)

# Convert to a data frame
df <- as.data.frame.matrix(tbl)

# Add interval as a column
df$Interval <- rownames(df)
rownames(df) <- NULL
df
library(flextable)
flextable(df)
# 4. Create time intervals (e.g., 500 days)
data$interval <- cut(data$N_Days, breaks=seq(0, max(data$N_Days), by=500), right=FALSE)

# 5. Tabulate deaths and censored cases per interval
life_table_data <- data %>%
  group_by(interval) %>%
  summarise(
    n = n(),
    deaths = sum(death_event),
    censored = sum(1 - event)
  )

print(life_table_data)

## Life Table Estimation (actuarial method)
## survfit with type="fleming-harrington" approximates actuarial life table
life_table_fit <- survfit(Surv(N_Days, death_event) ~ 1, type="fleming-harrington", data=data)

## View life table summary
summary(life_table_fit)

# 8. Plot Life Table survival curve
plot(life_table_fit, conf.int=TRUE,
     xlab="Time (days)", ylab="Survival Probability",
     main="Life Table Survival Curve")

## Cox Proportional Hazards Model
## Create survival object
cox_surv_obj <- Surv(time = data$N_Days, event = data$death_event)

## Univariate Cox Model
cox_uni <- coxph(cox_surv_obj ~ Bilirubin, data = data)
summary(cox_uni)

## Coefficient (coef): 0.145 – Positive value means higher bilirubin is associated with increased hazard.
## Hazard Ratio (exp(coef)): 1.156 → For every 1 unit increase in Bilirubin, the hazard (risk of death) increases by ~15.6%.
## Confidence Interval (CI): [1.126, 1.188] → Since the CI does not include 1, the effect is statistically significant.
## p-value < 2e-16: Highly significant — there's strong evidence that Bilirubin is a significant predictor of survival.

## Model Performance
## Concordance = 0.793 → Indicates strong discriminative ability (i.e., the model can distinguish well between those who live longer vs shorter).
## Wald, Likelihood Ratio, and Score tests: All highly significant (p < 2e-16), reinforcing that Bilirubin is an important predictor.

## Clinical Interpretation
## Higher bilirubin levels are significantly associated with a greater risk of death among cirrhosis patients. This suggests Bilirubin could be an important marker for disease severity and prognosis.

## Multivariate Cox Model
cox_model <- coxph(cox_surv_obj ~ Age + Sex + Ascites + Drug + Albumin + 
                     Bilirubin + Prothrombin + Stage, data = data)
summary(cox_model)

## This Cox proportional hazards model shows how various clinical and demographic variables influence the risk of death (hazard) in a group of 276 patients, among whom 111 experienced the event of interest (death).
## Starting with age, its effect is minimal and not statistically significant at the 5% level, although the p-value (0.065) suggests a weak trend where older age might slightly increase the risk of death.
## Sex shows a significant effect. Being male increases the hazard of death by approximately 84% compared to being female, and this result is statistically significant with a p-value of 0.024. This means male patients are at higher risk of mortality.
## Ascites does not significantly affect survival in this model. Patients with ascites have a slightly higher hazard ratio (about 7% increase), but the p-value is very high (0.845), indicating no meaningful difference.
## The effect of drug assignment (placebo versus treatment) is also not significant. Patients on placebo have a slightly lower risk, but this finding is not statistically reliable (p = 0.586).
## Albumin is a strong and statistically significant predictor. Higher albumin levels substantially reduce the risk of death. In fact, each unit increase in albumin reduces the hazard by about 66%, with a p-value well below 0.001. This means albumin is highly protective.
## Bilirubin is another key predictor. Higher bilirubin levels are strongly associated with increased mortality risk. Each unit increase in bilirubin raises the hazard by around 13.5%, and this effect is highly significant (p < 0.001), suggesting bilirubin is a strong marker of disease severity.
## Prothrombin time also plays a significant role. An increase in prothrombin time raises the risk of death by about 27%, with a statistically significant p-value of 0.012. This indicates that impaired blood clotting is associated with poorer survival.
## Finally, disease stage is an important factor. With each increase in stage, the hazard increases by about 55%. This relationship is highly significant, showing that patients with more advanced disease have a higher risk of mortality.
## Overall, the model fits the data well, with a concordance of 0.83, indicating excellent predictive accuracy. All three global tests (likelihood ratio, Wald, and score tests) are significant, meaning the model as a whole is statistically robust.

# Check PH assumption
cox.zph(cox_model)
ggcoxzph(cox.zph(cox_model))

## This output is from the cox.zph() function, which tests the proportional hazards (PH) assumption for each covariate in your Cox model. If the PH assumption holds, the hazard ratio for a variable remains constant over time. Here's how to interpret the results:
## Age has a p-value of 0.084. This is not significant at the 0.05 level, but it's borderline, so the PH assumption may be slightly violated.
## Sex has a very high p-value of 0.972, indicating no violation of the PH assumption. Its hazard ratio can be considered stable over time.
## Ascites has a p-value of 0.062, also borderline. It suggests a possible, but not definitive, time-varying effect.
## Drug has a p-value of 0.463, showing no evidence of PH assumption violation.
## Albumin has a p-value of 0.360, also indicating that its effect on hazard is stable over time.
## Bilirubin has a significant p-value of 0.016. This means bilirubin violates the proportional hazards assumption, and its effect likely changes over time.
## Prothrombin has a p-value of 0.024, so it too violates the PH assumption, suggesting a time-varying hazard ratio.
## Stage has a borderline p-value of 0.059, implying a possible, weak violation.
## Finally, the GLOBAL test checks whether any covariate in the model violates the PH assumption. With a p-value of 0.021, this test is significant. That means at least one variable (likely bilirubin and prothrombin) does not satisfy the proportional hazards assumption, and adjustments (like time-varying covariates or stratification) may be needed.

## Visualize the survival curves.
ggsurvplot(survfit(cox_model), data = data, risk.table = TRUE)

## handle variables that violate the ph assumption
## Stratification
cox_strat <- coxph(cox_surv_obj ~ Age + Sex + Albumin + Bilirubin + Prothrombin + strata(Stage), data = data)

## Include time dependent covariates
cox_td <- coxph(cox_surv_obj ~ Age + Sex + Albumin + Bilirubin + tt(Bilirubin), 
                data = data,
                tt = function(x, t, ...) x * log(t))

## Categorize the variable
data$bilirubin_cat <- cut(data$Bilirubin, breaks = quantile(data$Bilirubin, probs = seq(0, 1, 0.25)), include.lowest = TRUE)
cox_cat <- coxph(cox_surv_obj ~ Age + Sex + bilirubin_cat, data = data)
cox.zph(cox_cat)


## Weibull Model

weibull_model <- survreg(surv_obj ~ Age + Sex + Ascites + Drug + Albumin + 
                           Bilirubin + Prothrombin + Stage, data = data, 
                         dist = "weibull")
summary(weibull_model)

## Log-normal Model
lognormal_model <- survreg(surv_obj ~ Age + Sex + Ascites + Drug + Albumin + 
                             Bilirubin + Prothrombin + Stage, data = data, dist = "lognormal")
summary(lognormal_model)

## Log-logistic Model
loglogistic_model <- survreg(surv_obj ~ Age + Sex + Ascites + Drug + Albumin + 
                               Bilirubin + Prothrombin + Stage, data = data, dist = "loglogistic")
summary(loglogistic_model)

## Fit the Exponential model
exp_model <- survreg(surv_obj ~ Age + Sex + Ascites + Drug + Albumin + 
                       Bilirubin + Prothrombin + Stage, data = data, dist = "exponential")

## View model summary
summary(exp_model)
