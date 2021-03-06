---------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                                 DATA EXPLORATION USING SQL                                                                -- 
---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- This project explores Global COVID data with focus on COVID related deaths, infection rate and vaccinations.
-- I used global COVID Deaths dataset from https://ourworldindata.org/covid-deaths.
-- I used Microsodt SQL Server Management Studio 18 for the project.
-- I created two datasets "Coviddeath" dataset and "Covidvaccinations" dataset. 
-- In the project, we are going to explore the data in the two datasets. 

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 1- Getting the feel of the data.
Select	*
from [Portfolio project]..['Coviddeaths$']
order by location,date

Select*
from [Portfolio project]..['Covidvaccinations$']
where new_vaccinations is not null
order by location,date

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Step 2- Exploring the Data
---------------------------------------------------------------------------------------------------------------------------------------------------------------

--(A) Calculate death rate of COVID-19 among infected people for all countries, and filter death rate for Nepal specifically. 
Select	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathrate
from [Portfolio project]..['Coviddeaths$']
where location = 'nepal'
order by date,total_deaths desc

--RESULT:As of 29th Jan 2022, death rate is around 1.24% from COVID-19.

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--(B) Calculate COVID-19 infection rate for all countries and filter infection rate for Nepal specifically. 
Select	Location, date, total_cases, population, (total_cases/population)*100 as Infectionrate
from [Portfolio project]..['Coviddeaths$']
where location = 'nepal'
order by 1,2

--RESULT:As of 29th Jan 2022, infection rate is around 3.19% from COVID-19.

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--(C) Identify top 3 countries with highest COVID-19 infection rate.
Select	Location, population, MAX(total_cases) as Highestinfectioncount, MAX(cast(total_cases as int))/population*100 as highestinfectionrate  -- total_cases was set as string data type, so had to converted to integer before analysis
from [Portfolio project]..['Coviddeaths$']
Group by location, population
order by highestinfectionrate desc

--RESULT: 1. Andorra (46%), 2. Faeroe Islands (38%) 3.Gibraltar (39%)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--(D) Identify top 3 countries with highest death rate in total population
Select	Location, population, MAX(cast(total_deaths as int)) as Highestdeathcount, MAX(cast(total_deaths as int))/population*100 as Highestdeathrate
from [Portfolio project]..['Coviddeaths$']
where continent is not null     -- we filter out continents or other grouping of countries in the query, continent field is only filled for individual countries, so we use that logic to filter
Group by location, population
Order by Highestdeathrate desc

--RESULTS: 1. Peru (0.61%), 2. Bulgaria (0.48%) 3. Bosnia and Herzegovina (0.44%)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--(E) Identify top 3 continents with highest death rate in total population
Select	continent, max(population) as population, MAX(cast(total_deaths as int)) as Highestdeathcount, MAX(cast(total_deaths as int))/max(population)*100 as Highestdeathrate
from [Portfolio project]..['Coviddeaths$']
where continent is not null     -- we filter out continents or other grouping of countries in the query, continent field is only filled for individual countries, so we use that logic to filter
Group by continent
Order by Highestdeathrate desc

--RESULT: 1. South America (0.29%), 2. North America (0.27%) 3. Europe (0.22%)

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--(F) Identitfy Global death rate of COVID-19 among infected people
select sum(new_cases) as newcases, SUM(cast(new_deaths as int)) as newdeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from [Portfolio project]..['Coviddeaths$']
where continent is not null	-- we filter out continents or other grouping of countries in the query, continent field is only filled for individual countries, so we use that logic to filter
--group by date
order by 1,2

--RESULT: We find that 1.51% of COVID cases has resulted in deaths.

---------------------------------------------------------------------------------------------------------------------------------------------------------------
--(G) Calculate proportion of vaccinated population  in Nepal. 
-- Note: Vaccination information is not in the Coviddeath dataset. So we first need to join "Coviddeath" dataset and "Covidvaccinations" dataset

with PopvsVac (continent,Location, Date,Population,New_vaccinations,rolligvaccinatednum)
as
(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations, SUM(convert(bigint,vaccine.new_vaccinations)) over (partition by death.location order by death.location, vaccine.date) as rolligvaccinatednum
from [Portfolio project]..['Coviddeaths$'] death
Join [Portfolio project]..['Covidvaccinations$'] vaccine
	on death.location = vaccine.location
	and death.date=vaccine.date
where death.continent is not null and death.location ='nepal' -- we filter out continents or other grouping of countries in the query, continent field is only filled for individual countries, so we use that logic to filter
--order by location,vaccine.date

)
select*, (rolligvaccinatednum/Population) *100	as vaccinatedpercent
from PopvsVac

--RESULT: As of 29th Jan 2022 30.2% of the population is vaccinated in Nepal (Non smoothed estimate, based on raw data)
