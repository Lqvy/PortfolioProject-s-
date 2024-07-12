-- Data Cleaning
SET SQL_SAFE_UPDATES = 0;

-- Viewing
Select *
from layoffs;
Select *
from layoffs_staging;
Select *
from layoffs_staging2;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns

-- Good practice not to work on raw data, making a copy to work on.
Create table layoffs_staging
Like layoffs;

insert layoffs_staging
select *
from layoffs;

-- Look for duplicates
Select *, 
row_number() over(
partition by company, location,industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- Look at duplicates
with duplicate_cte as 
(
Select *, 
row_number() over(
partition by company, location,industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1;

-- Confirm duplicates, looking at row_num comparing columns.
select *
from layoffs_staging
where company = 'Casper';

-- Another table before clearing duplicates
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert information
insert into layoffs_staging2
Select *, 
row_number() over(
partition by company, location,industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- Delete duplicate information
delete
from layoffs_staging2
where row_num > 1;

-- Standardizing Data
-- Making data consistent; standard-based format

-- Check each column for issues
select distinct "Input_Column_Name"
from layoffs_staging2
order by 1;


	-- Company
-- Viewing a trim
select company, trim(company)
from layoffs_staging2;

-- Removing empty space
update layoffs_staging2
set company = trim(company);


	-- Industry
-- Viewing inconsistent industry names
select distinct industry
from layoffs_staging2
order by 1;

-- Viewing Crypto companies name issue
select *
from layoffs_staging2
where industry like 'Crypto%';

-- Updating every crypto industry to 'Crypto'
update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';


	-- Country
-- Viewing inconsistent country names
select distinct country
from layoffs_staging2
order by 1;

-- Updating inconsistent country names
update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';


	-- Date
-- Viewing date with a format
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

-- Updating date format
update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- Changing data type from text to date
Alter table layoffs_staging2
modify column `date` date;

-- Changing blanks to nulls for population later
update layoffs_staging2
set industry = null
where industry = '';

-- Searching for empty's and nulls
select *
from layoffs_staging2
where industry is null
or industry = '';

-- Double check if any values are populatables
Select *
from layoffs_staging2
where company = 'Airbnb';

-- View what is going to be populated
select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
    and t1.location = t2.location
where t1.industry is null
and t2.industry is not null;

-- Population of table using the table cut into 2 halves to populate nulls that are similar
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

-- Case where null couldn't populate due to being alone
Select *
from layoffs_staging2
where company like 'bally%';

-- Layoff sheet with no laid off? Decision would be to delete or let be, potentially error..?
select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- Deleting redundant data. 
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- another overview: row_num exists, all values = 1; redundant.
select * 
from layoffs_staging2;

-- Removal of row_num
alter table layoffs_staging2
drop column row_num;