# ⏳ Survival Analysis: Predicting “When” Events Happen  

At **Dataquest Solutions**, we apply **Survival Analysis** to help organizations predict **time-to-event outcomes** — from customer churn to machine failures and patient outcomes. This methodology goes beyond predicting *what* will happen, and instead answers the critical question:  

👉 **“When will it happen?”**  

---

## 🔹 Core Concepts of Survival Analysis  

1. **Time-to-Event Data**  
   - Observes the duration until a defined event occurs (e.g., time until a customer cancels).  

2. **Censoring**  
   - Not every subject experiences the event during observation (e.g., customers still active). Survival Analysis handles this missingness.  

3. **Survival Function (S(t))**  
   - Probability of “surviving” (not experiencing the event) beyond time *t*.  

4. **Hazard Function (h(t))**  
   - The instantaneous risk of the event happening at time *t*.  

5. **Kaplan-Meier Estimator**  
   - A non-parametric estimator to plot survival curves without assuming a distribution.  

6. **Cox Proportional Hazards Model**  
   - Semi-parametric model estimating the effect of covariates (e.g., discounts, demographics) on hazard rates.  

---

## 🔹 Parametric Survival Models  

Unlike Kaplan-Meier or Cox models, **parametric models** assume a probability distribution of survival times.  

### 1. Exponential Model  
- Assumes a **constant hazard rate**.  
- Useful for processes with stable event likelihood over time.  
- Example: Electronic component failure.  

### 2. Weibull Model  
- Hazard can **increase, decrease, or stay constant**.  
- Widely used in engineering and reliability.  
- Example: Predicting wear-and-tear failure in machines.  

### 3. Log-Normal Model  
- Assumes log(survival times) follows a normal distribution.  
- Hazard rises initially, then decreases.  
- Example: Adoption time for new technologies.  

### 4. Log-Logistic Model  
- Similar to Log-Normal but with heavier tails.  
- Hazard increases to a peak, then decreases.  
- Example: Customer churn risk stabilizing after a certain period.  

---

## 🔹 Accelerated Failure Time (AFT) Models  

- Unlike Cox models, AFT directly models **time-to-event**.  
- Estimates how covariates **accelerate or decelerate survival time**.  
- Example: Discounts may shorten subscription duration by half.  

---

## 🔹 Real-World Applications  

✅ **Healthcare** → Estimating patient survival after treatment.  
✅ **Customer Analytics** → Predicting subscription cancellations or time-to-purchase.  
✅ **Manufacturing** → Forecasting machine breakdowns.  
✅ **Finance** → Modeling loan defaults.  
✅ **Marketing** → Estimating Customer Lifetime Value (CLV).  

---

## 🔹 Business Value  

By applying Survival Analysis, organizations can:  
- Identify **high-risk groups** (customers likely to churn soon, machines near failure).  
- Optimize **interventions** (targeted offers, preventive maintenance, patient care).  
- Forecast **asset and customer lifecycles** with greater accuracy.  
- Improve **ROI** by allocating resources at the right time.  

---

## 🔹 Key Takeaway  

While traditional analytics answer **“what”** and **“why”**, Survival Analysis answers **“when.”**  

By leveraging models such as **Exponential, Weibull, Log-Normal, Log-Logistic, and AFT**, businesses can anticipate and act before events occur.  

At **Dataquest Solutions**, we help organizations harness Survival Analysis to turn uncertainty into foresight.  

---
