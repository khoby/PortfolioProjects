
-- SQL Project for the Covid Vacinations as well as deaths across the world
-- Data aquired from the official covid database site

SELECT *
FROM coviddeaths
ORDER BY 3,4;

-- SELECT *
-- FROM covidvacinations
-- ORDER BY 3,4

-- Data being used for the project
SELECT location,Total_Cases,new_cases,total_deaths,MyUnknownColumn
FROM coviddeaths
ORDER BY 3,4;

-- Total_Deaths vs Total Cases
SELECT location,date,total_deaths,total_cases,(total_deaths/total_cases) *100 as PercentagePopulationInfected
FROM coviddeaths
WHERE location like '%ghana%'
ORDER BY 1,2;

-- Total cases vs population(myunkowncolumn)
SELECT location,date,total_cases,MyUnknownColumn,(total_cases/MyUnknownColumn) *100 as CasePerPopulation
FROM coviddeaths
WHERE location like '%ghana%' AND total_cases !=0
ORDER BY 1,2;

-- Highest Infected Countries
SELECT location,MyUnknownColumn,MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/total_cases)) *100 as PercentagePopulationInfected
FROM coviddeaths
WHERE location like '%ghana%'
GROUP BY location, MyUnknownColumn
ORDER BY PercentagePopulationInfected DESC;

-- Showing highest death counts by population
SELECT location,MyUnknownColumn,MAX(total_deaths) as HighestDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- Showing by continent
SELECT continent, MAX(total_deaths ) as HighestDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;


-- GLObal numbers
SELECT date, SUM(new_cases) as totalNewCases, SUM(new_deaths) as TotalNewDeaths, 
SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Exploring Covid Vacinations Data
SELECT * 
FROM covidvacinations;

SELECT cd.continent,cd.location,cd.date,cd.MyUnknownColumn,cv.new_vaccinations
FROM coviddeaths cd
JOIN covidvacinations cv
	ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL AND new_vaccinations >1;

-- Total populations vs vacinations
SELECT cd.continent,cd.location,cd.date,cd.MyUnknownColumn,cv.new_vaccinations, SUM(cv.new_vaccinations) 
OVER (partition by cd.location ORDER BY cd.location, cd.date) as RollingCountOfVacinations
FROM coviddeaths cd
JOIN covidvacinations cv
	ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE
with PopulationVsVacinations(continent,location,date,myunknowncolumn,new_vacinations,RollingCountOfVacinations)
AS (
SELECT cd.continent,cd.location,cd.date,cd.MyUnknownColumn,cv.new_vaccinations, SUM(cv.new_vaccinations) 
OVER (partition by cd.location ORDER BY cd.location, cd.date) as RollingCountOfVacinations
FROM coviddeaths cd
JOIN covidvacinations cv
	ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
)
SELECT *, ( RollingCountOfVacinations/myunknowncolumn) *100
FROM PopulationVsVacinations


CREATE VIEW totalpercentvaccinated AS
SELECT cd.continent,cd.location,cd.date,cd.MyUnknownColumn,cv.new_vaccinations, SUM(cv.new_vaccinations) 
OVER (partition by cd.location ORDER BY cd.location, cd.date) as RollingCountOfVacinations
FROM coviddeaths cd
JOIN covidvacinations cv
	ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
