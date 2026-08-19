# World Layoffs: Data Cleaning & Exploratory Data Analysis (EDA)

## Project Overview
An end-to-end SQL project analyzing global company layoffs across various industries, countries, and funding stages. <br>
This project demonstrates data pipeline best practices in MySQL—from raw data ingestion and deep cleaning to exploratory analysis and multi-year trend forecasting. <br>
Full SQL script can be found [here](https://github.com/amelia-chow/World-Layoffs-/blob/main/amelia%20sql%20project.sql)

## Project Objectives
- **Data Integrity & Standardization:** Clean unstructured raw data, remove duplicates, normalize values, and populate missing attributes.
- **Identify Macro Layoff Trends:** Uncover patterns in layoffs across different macroeconomic cycles, funding stages, and global regions.


## Dataset
- **Global Layoffs Dataset:** Historical records of company layoffs detailing location, industry, total laid off, percentage laid off, date, company stage, country, and funds raised (in millions).
Dataset can be found [here](-)

## 🛠️ Tools & Technologies Used
- **SQL / MySQL** (Data cleaning, transformation, and analytical querying)
- **MySQL Workbench / DBeaver** (Database management environment)

## 📁 Project Workflow

### 1. 🧹 Data Cleaning and Preparation
- **Staging Pipeline:** Cloned raw data into `layoffs_staging` and `layoffs_staging2` to preserve raw data integrity throughout transformations.
- **Deduplication:** Applied `ROW_NUMBER()` over partition windows (`company`, `location`, `industry`, `total_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`) to identify and remove redundant records.
- **Standardization & Normalization:**
  - Removed whitespace using `TRIM()`.
  - Normalized industry discrepancies (e.g., standardizing `Crypto%` variants into `Crypto`).
  - Corrected trailing punctuation and naming inconsistencies across countries (e.g., `United States.` to `United States`).
- **Data Type Alignment:** Converted string dates into proper MySQL `DATE` format using `STR_TO_DATE()` and updated schema types with `ALTER TABLE`.
- **Missing Value Imputation:**
  - Populated missing `industry` records using self-joins based on matching `company` and `location`.
  - Stripped unrecoverable rows where both `total_laid_off` and `percentage_laid_off` were null.

### 2. 📈 Exploratory Data Analysis (EDA)
- **High-Impact Outliers:** Identified single-day layoff peaks and isolated companies that laid off 100% of their workforce relative to their funding size.
- **Categorical Breakdowns:** Aggregated total workforce reductions grouped by company, industry sector, country, and funding stage.
- **Rolling Time Series:** Built Common Table Expressions (CTEs) combined with window aggregations (`SUM() OVER(ORDER BY month)`) to calculate month-over-month cumulative layoffs.
- **Yearly Company Rankings:** Implemented multi-level CTEs with `DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC)` to extract the top 5 companies by total layoffs for each year.

---

## 🔑 Key SQL Techniques Demonstrated

* **Window Functions:** `ROW_NUMBER()`, `DENSE_RANK()`, `SUM() OVER(PARTITION BY ... ORDER BY ...)`
* **Common Table Expressions (CTEs):** Multi-tiered CTE architectures for complex rankings and rolling timeline calculations.
* **DDL & DML Operations:** `CREATE TABLE LIKE`, `ALTER TABLE`, `UPDATE ... JOIN`, `DELETE`
* **Data Transformation Functions:** `STR_TO_DATE()`, `TRIM()`, `SUBSTRING()`, `YEAR()`, / `IFNULL()`
