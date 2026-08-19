SELECT * 
FROM layoffs;

-- CREATING A SEPARATE TABLE TO KEEP RAW DATA SAFE-- 

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_staging;

-- REMOVE DUPLICATES --

SELECT *, 
ROW_NUMBER() OVER(PARTITION BY COMPANY, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`) AS row_num 
FROM layoffs_staging;

WITH duplicated_cte as 
(SELECT *, 
ROW_NUMBER() OVER(PARTITION BY COMPANY, LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`, STAGE, COUNTRY, FUNDS_RAISED_MILLIONS) AS row_num 
FROM layoffs_staging)
SELECT * 
FROM duplicated_cte 
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY COMPANY, LOCATION, INDUSTRY, TOTAL_LAID_OFF, PERCENTAGE_LAID_OFF, `DATE`, STAGE, COUNTRY, FUNDS_RAISED_MILLIONS) AS row_num 
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2
WHERE ROW_NUM > 1;

-- DELETING OF DUPLICATES -- 
DELETE 
FROM layoffs_staging2
WHERE ROW_NUM > 1;

SELECT * 
FROM layoffs_staging2
WHERE ROW_NUM > 1;

-- STANDARDIZING DATA --

SELECT COMPANY, TRIM(COMPANY)
FROM layoffs_staging2;

UPDATE layoff_staging2
SET COMPANY = TRIM(COMPANY);

SELECT COMPANY, TRIM(COMPANY)
FROM layoffs_staging2;

SELECT DISTINCT INDUSTRY 
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'crypto%';

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'crypto%';

SELECT DISTINCT COUNTRY 
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE country = 'United States.';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

SELECT country, TRIM(country)
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2;

SELECT `date`,
str_to_date(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- NULL VALUES -- 

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb'; # There is another data that contains Airbnb and is listed under TRAVEL industry 

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

SELECT * 
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company 
    AND t1.location = t2.location 
WHERE (t1.industry is NULL OR t1.industry = '')
AND t2.industry is NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry is NULL OR t1.industry = '')
AND t2.industry is NOT NULL;

SELECT * 
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off is null 
AND percentage_laid_off is null;

-- REMOVING NULL ROWS --

DELETE 
FROM layoffs_staging2
WHERE total_laid_off is null 
AND percentage_laid_off is null;

-- DROP COLUMN -- (unwanted) 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;

-- EXPLORATORY DATA ANALYSIS -- 

SELECT *
FROM layoffs_staging2;

SELECT MAX(TOTAL_LAID_OFF), MAX(percentage_laid_off)
FROM layoffs_staging2;

# COMPANIES THAT LAID OFF ALL THEIR EMPLOYEES, ORDERED BY THEIR FUNDS RAISED
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC ;

# SUM OF LAY OFFS BY COMPANIES 
SELECT COMPANY, SUM(TOTAL_LAID_OFF)
FROM layoffs_staging2
GROUP BY COMPANY 
ORDER BY 2 DESC;

# TIME PERIOD WE ARE LOOKING AT
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

# INDUSTRY THAT HIT THE HARDEST
SELECT INDUSTRY, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY INDUSTRY 
ORDER BY 2 DESC;

# COUNTRY THAT HIT THE HARDEST
SELECT COUNTRY, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY COUNTRY 
ORDER BY 2 DESC;

# LAID OFF AMOUNT BY YEAR
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

# SUM OF DIFFERENT STAGE AT THE TIME THE COMPANIES HAD LAY OFF
SELECT STAGE, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY STAGE
ORDER BY 1 DESC; 

# ROLLING SUM OF LAYOFFS
SELECT substring(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1;

WITH ROLLING_TOTAL AS 
(SELECT substring(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL 
GROUP BY `MONTH`
ORDER BY 1
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM ROLLING_TOTAL ;

# NOTICING A HUGE INFLUX OF LAYOFFS STARTING 2022 FROM ABOVE QUERY

SELECT COMPANY, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY COMPANY, YEAR(`date`)
ORDER BY 3 DESC;


# TOP 5 COMPANIES WITH THE HIGHEST LAYOFFS PER YEAR
WITH COMPANY_YEAR (COMPANY, YEARS, TOTAL_LAID_OFF) AS 
(
SELECT COMPANY, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY COMPANY, YEAR(`date`)
ORDER BY 3 DESC
), 
COMPANY_YEAR_RANK AS 
(
SELECT *, DENSE_RANK() OVER (PARTITION BY YEARS ORDER BY TOTAL_LAID_OFF DESC) AS RANKING
FROM COMPANY_YEAR
WHERE YEARS IS NOT NULL
) 
SELECT * 
FROM COMPANY_YEAR_RANK
WHERE RANKING <= 5;







