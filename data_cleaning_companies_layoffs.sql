SELECT * if exists
FROM layoffs;

-- Avoid working with the raw data by creating another exact table  we can work with
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;
INSERT layoffs_staging 
SELECT *
FROM layoffs;

-- Remove duplicates

SELECT * ,
row_number() over(
partition by company , industry, total_laid_off , percentage_laid_off, `date`) AS ROW_NUM
FROM layoffs_staging;
WITH DUPLICATE_CTE AS
(SELECT * ,
row_number() over(
partition by company , location, industry, total_laid_off , percentage_laid_off, `date`, stage, country, funds_raised_millions) AS ROW_NUM
FROM layoffs_staging
)
SELECT * 
FROM DUPLICATE_CTE
WHERE ROW_NUM > 1; 

CREATE TABLE  `layoffs_staging2` (
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
FROM layoffs_staging2
where row_num > 1;
INSERT INTO layoffs_staging2 
SELECT * ,
row_number() over(
partition by company , location, industry, total_laid_off , percentage_laid_off, `date`, stage, country, funds_raised_millions) AS ROW_NUM
FROM layoffs_staging;


SET SQL_SAFE_UPDATES = 0;

delete 
from layoffs_staging2 
where  row_num > 1;

select *
from layoffs_staging2 ;

-- STANDARDIZING DATA

select company, TRIM(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);
------------ 
select distinct industry
from layoffs_staging2 
order by 1; 
-------
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';



UPDATE layoffs_staging2
SET country = trim(trailing '.'from country)
WHERE country LIKE 'United States%';

select distinct country
from layoffs_staging2
order by 1; 
---------
select `date`,
str_to_date(`date` , '%m/%d/%Y') as standard_date_format
from layoffs_staging2; 
------
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

----
alter table layoffs_staging2
modify column `date` date;

select * 
from layoffs_staging2;

-- REMOVE BLANKS /NULLS

select * 
from layoffs_staging2
where total_laid_off is null;

SELECT *
FROM
    layoffs_staging2
where
	industry is null
or industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select t1.industry , t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
    and t1.location = t2.location
where ( t1.industry is null or t1.industry = '')
and t2.industry is not null;

SET SQL_SAFE_UPDATES = 0;

update layoffs_staging2
set industry = null
where industry = '' ;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
set t1.industry = t2.industry
where  t1.industry is null 
and t2.industry is not null;

SELECT *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- REMOVE UNNECESARY COLUMNS/ROWS
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
select * 
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;


