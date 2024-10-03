# Campaign Analytics (meal kit delivery)
* Setup a SQLite database
* Generate synthetic data
* Model data
* Check data integrity
* Conduct exploratory data analysis
* Calculate KPIs (Churn, Conversion, Growth, ARPU, CLV/CAC)

## Executive Summary

**Problem:** How to best allocate marketing dollars to maximize the revenue?

**Background:** Our business employs multiple online marketing channels (e.g., Instagram, paid search, Reddit), targets several customer segments (e.g., seniors, couples, families). Marketing is key for growth because the general public's awareness of meal kit delivery is still scarce. It is unlikely for customers to search for such a service by themselves, not knowing that it existed in the first place. Yet, the marketing budget is limited.

**Unique Challenge:** Given high churn rate, acquision metrics may not be the whole story. In other words, a marketing channel may yield plenty of subscribers, yet, these new subscribers may not materialize into sustained revenue. **It is important to take customer lifetime value into consideration (CLV)**  Second, acquiring new customers from a channel over a decade may cause the channel to saturate, increasing the **incremental customer acquision cost (iCAC)** (iCAC is not covered in this project).

**Objectives:** Evaluate the performance of marketing channels, campaigns, and target audiences. Calculate growth KPIs. Identify lagging marketing channels or audience mismatches.

**Recommendations:** Marketing analytics team should conduct cohort studies to understand the churn patterns and customer lifetime value of customer acquired through different channels or demographics. This should lead to more cost effective and efficient marketing campaigns.

## Folder Structure
```
└── 📁mealkit-delivery
    └── 📁code
        └── 01_generate_data.ipynb
        └── 02_eda_kpi.sql
    └── 📁data
        └── campaigns.csv
        └── events.csv
        └── mealkit_delivery.db
        └── subscriptions.csv
    └── 📁tableau
        └── mealkit-delivery.twbx
    └── README.md
```

## Author and Contact
**Author:** Ekin Derdiyok <br>
**Email:** ekin.derdiyok@icloud.com <br>
**GitHub:** https://github.com/ekinderdiyok/mealkit-delivery <br>
**Date:** October 1, 2024 (Start) <br>

## References
* [Unlocking Marketing Success: Claire James on Data-Driven Strategies at HelloFresh](https://engineering.hellofresh.com/unlocking-marketing-success-claire-james-on-data-driven-strategies-at-hellofresh-0507ba16423e)
* [How predicting customer lifetime value enables HelloFresh to optimize its marketing spend](https://engineering.hellofresh.com/how-predicting-customer-lifetime-value-enables-hellofresh-to-optimize-its-marketing-spend-014d03a9227f)
* [“Meal kit brands should move away from discount marketing” - Insights from Patrick Stal, SVP Marketing](https://www.hellofreshgroup.com/en/newsroom/stories/meal-kit-brands-should-move-away-from-discount-marketing-insights-from/)
* [Meal-Kit world dominance vs. high customer churn](https://hashtagpaid.com/banknotes/meal-kit-world-dominance-vs-high-customer-churn)