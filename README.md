# Campaign Analytics
* Setup a SQLite database
* Generate synthetic data
* Model data
* Check data integrity
* Conduct exploratory data analysis
* Calculate KPIs (Churn, Conversion, Growth, ARPU, CLV/CAC)

## Executive Summary

**Problem:** How to best allocate marketing dollars to maximize the revenue?

**Background:** Our business employs multiple online marketing channels (e.g., Instagram, paid search, Reddit), targets several customer segments (e.g., seniors, couples, families)

**Unique Challenge:** Given high churn rate, acquision metrics may be futile. In other words, a marketing channel may yield plenty of subscribers, yet, these new subscribers may not materialize into sustained revenue. Analysing channel efficiency should incorporate *customer lifetime value (CLV)* and *churn rate*.

**Objectives:** Evaluate the performance of marketing channels, campaigns, and target audiences. Calculate growth KPIs. Identify lagging marketing channels or audience mismatches.

**Result:** Marketing team should conduct cohort studies to understand the churn patterns of customer acquired through different channels or demographics. 

**Recommendations**: Plus membership should be promoted for the sake of increasing CLV.

## Author and Contact
**Author:** Ekin Derdiyok <br>
**Email:** ekin.derdiyok@icloud.com <br>
**GitHub:** https://github.com/ekinderdiyok/meal-kit-delivery <br>
**Date:** October 1, 2024 (Start) <br>

## Folder Structure
```
└── 📁causal-inference
    └── README.md
    └── 📁canvas
        └── business_model_canvas.md
    └── 📁code
        └── causal_inference.ipynb
    └── 📁diagram
        └── causal_diagram.ipynb
        └── causal_diagram.png
        └── causal_diagram.svg
```

## References
* Hünermund, Paul and Kaminski, Jermain and Schmitt, Carla, Causal Machine Learning and Business Decision Making (February 19, 2022). Available at SSRN: https://ssrn.com/abstract=3867326 or http://dx.doi.org/10.2139/ssrn.3867326
* PyWhy contributors. "Estimating the Effect of a Member Rewards Program." DoWhy Documentation. Accessed July 23, 2024. https://www.pywhy.org/dowhy/main/example_notebooks/dowhy_example_effect_of_memberrewards_program.html.
* Amit Sharma, Emre Kiciman. DoWhy: An End-to-End Library for Causal Inference. 2020. https://arxiv.org/abs/2011.04216
* Patrick Blöbaum, Peter Götz, Kailash Budhathoki, Atalanti A. Mastakouri, Dominik Janzing. DoWhy-GCM: An extension of DoWhy for causal inference in graphical causal models. 2022. https://arxiv.org/abs/2206.06821
* CausalWizard. (n.d.). CausalWizard app. Retrieved November 1, 2023, from https://causalwizard.app
