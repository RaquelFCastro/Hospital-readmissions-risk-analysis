# Hospital-readmissions-risk-analysis
## Business Problem:
Under the Hospital Readmissions Reduction Programm (HRPP), hospitals in the U.S. are faced with financial penalties when a patient that was under their care gets readmitted within 30 days of leaving the hospital. This can correspond to a 1-3% reduction in the Medicare payments. This project looks at 10 years of data from 130 U.S. hospitals to find which patients, diagnoses, and care patterns are linked to a higher risk of readmission. The ultimate goal is to identify patients at a higher risk and prevent avoidable readmissions.


## Data & Tools
**Dataset** : Diabetes 130-US Hospitals for Years 1999-2008 (UCI Machine Learning Repository, CC BY 4.0). More than 100,000 patient encounters across 130 hospitals, 1999-2008

**Database**: MySQL

**Techniques Used**: CTEs, Window Function (RANK, NTILE), CASE-based risk tiering, correlated subqueries, and multi-table joints.


## Methodology
**Cleaning**: Replace the placeholder missing values with Nulls, removed column with about 90% missing data, kept only one encounter per patient to avoid duplicate bias, and removed patients who were inactive or were discharged to hospice.

**Exploratory analysis**: Established baseline readmission rates by age, admission type, and diagnoses category.

**Advanced Analysis**: Built reusable high-risk patient group with CTE, applied window function to rank patients by risk, grouped them by medication use and number of diagnoses, and found diagnoses categories with above average readmission rates.

**Findings**: Summarized the results into four key findings that connect back to the main business problem.


## Key SQL Techniques Used
- CTEs to stage, reusable risk cohort across multiple queries.
- Window functions: RANK() OVER (PARTITION BY) to rank medication burden within age groups, NTILE(4) to build risk quartiles.
- CASE-based tiering to convert continuous variables into business-readable risk categories.
- Correlated subqueries with HAVING to isolate diagnoses categories performing above the population-wide average.
- Multi-table joins against multiple ID-mapping reference tables to convert numeric codes into readable labels.


## Findings
- Circulatory and diabetes diagnoses had the highest readmission rates among all diagnosis categories, and both exceeded the average readmission rate.
- Patients with more prior inpatient visits in the prior year showed a substantially elevated readmission risk, supporting prior utilization as a strong predictive signal.
- Discharge disposition mattered significantly. Patients discharged to certain facility types showed measurably different readmission rates than those discharged home.
- Findings around medication changes at discharge and A1C testing during the stay align with the original clinical research question this dataset was collected to investigate.


## Recommendations
**1** Focus discharge planning and follow-up on patients with the highest risk based on past hospital visits.

**2** Give extra care coordination to patients with heart/circulatory conditions and diabetes, given they have higher readmission rates.

**3** Review discharge processes at facilities with high readmission rates to find areas that could be improved.



