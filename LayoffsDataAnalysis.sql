-- Exploratory Data Analysis

-- Overview
Select *
from layoffs_staging2;

-- Checking highest laid off total and percentage of people
Select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- Companies that went completely under
Select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc;

-- Company profits - High to low.
Select distinct company, funds_raised_millions
from layoffs_staging2
order by funds_raised_millions desc;

-- Company layoffs - High to low.
Select company, SUM(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc;

-- Industry wide layoffs - High to low.
Select industry, SUM(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- Country wide layoffs - High to low.
Select country, SUM(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- Layoffs by date
Select YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 1 desc;

-- Layoffs company stage
Select stage, SUM(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- Date range for data. Hint: 3 years.
select min(`date`), max(`date`)
from layoffs_staging2;

select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

-- Rolling total of layoffs through the months across 3 years.
with Rolling_Total as 
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`, total_off,
sum(total_off) over(order by `month`) as rolling_total
from Rolling_Total;

-- Highest laid off, which year it happened, and which company it was
Select company as Company, year(`date`) as `Year`, SUM(total_laid_off) as Total_Laid_Off
from layoffs_staging2
group by company, year(`date`)
order by 3 desc;

-- Highest laid off per year, top 3 for each year 
with Company_Year (company, years, total_laid_off) as 
(
Select company, year(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
)
, Company_Year_Rank as 
(
select company, years, total_laid_off,
Dense_rank() over (partition by years order by total_laid_off desc) as Ranking 
from Company_Year 
where Years is not null
order by Ranking asc
)
select company, years, total_laid_off, ranking 
from Company_Year_Rank
where Ranking <= 3
and years is not null
order by years asc, total_laid_off desc;