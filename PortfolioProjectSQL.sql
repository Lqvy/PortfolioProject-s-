--Life Expectancy in United States (average number of years a newborn would live to if mortality rates maintain)
--e.g. if born in 2021 life expectancy is 77.2, but if you are 80 as of 2021 you'll live till 89.5
Select *
From PortfolioProject..LifeExpectancy$
Where "Country name" like 'United States'
order by 1,2;

--Population growth rate % by year in the United States
Select *
From PortfolioProject..PopulationGrowthRate$
Where "Country name" like 'United States'
order by 1,2;

--Breaking things down by 2021 %'s

--Highest Growth % by country in 2021
Select "Country name", [Year] , MAX("Population growth rate") as GrowthRatePercent
	From PortfolioProject..PopulationGrowthRate$
Where [Year] like '2021'
	and "Country name" not like '%region%' 
	and "Country name" not like '%countries%'
	and "Country name" not like '%develop%' 
	and "Country name" not like '%(UN)%'
	and "Country name" != 'World'
group by "Country name", [Year]
order by GrowthRatePercent desc;

--Highest Growth % by region development in 2021
Select "Country name", [Year] , MAX("Population growth rate") as GrowthRatePercent
	From PortfolioProject..PopulationGrowthRate$
Where [Year] like '2021' and 
	("Country name" like '%developed%' or
	"Country name" like '%developing%')
group by "Country name", [Year]
order by GrowthRatePercent desc;

--Highest Growth % by countries income in 2021
Select "Country name", [Year] , MAX("Population growth rate") as GrowthRatePercent
	From PortfolioProject..PopulationGrowthRate$
Where [Year] like '2021'
	and "Country name" like '%income%'
group by "Country name" , [Year]
order by GrowthRatePercent desc;

--Global Numbers

--Global growth rate by year
Select [Year], convert(decimal(4,2),avg("Population growth rate")) as "Population growth rate"
	From PortfolioProject..PopulationGrowthRate$
		where "Country name" not like '%region% %countries%'
		and "Country name" not like '%countries%'
		and "Country name" not like '%develop%'
		and "Country name" not like '%(UN)%'
		and "Country name" != 'World'
	group by [Year]
	order by 1;

--In theory should be same numbers as above, unaware of their 'world' source data
Select [Year], "Population growth rate"
From PortfolioProject..PopulationGrowthRate$
Where "Country name" like 'World'
order by 1,2;

-- Population Growth Rate Difference Country by Country, Year by Year
select "Country name", [year], "Population growth rate",
round("Population growth rate" - lag("Population growth rate", 1) over (partition by "Country name" order by [year]),2) as PopGrowthRateDiff
from PortfolioProject..PopulationGrowthRate$;
