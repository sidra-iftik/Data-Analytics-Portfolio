-- Queries for Tableau

-- 1. Global Death percentage
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, ROUND(SUM(new_deaths)/SUM(new_cases)*100, 3) as DeathPercentage
FROM covidproject.coviddeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--2. Total deaths by continent
SELECT location, SUM(new_deaths) as TotalDeaths
FROM covidproject.coviddeaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeaths desc

--3. Highest infection count per country, and percentage of population infected rounded to 2 decimal places
SELECT location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population)*100), 2) as PercentPopulationInfected
FROM covidproject.coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--4. highest infection count and percent pop infected by country and day
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population)*100), 2) as PercentPopulationInfected
FROM covidproject.coviddeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc


-- total deaths = total until that day
SELECT *
FROM covidproject.coviddeaths
WHERE continent is not null
ORDER BY 3,4

-- Select data I want to work with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolioproject-448416.CovidDeaths.CovidDeaths`
Order by 1,2

-- Looking at total cases vs total deaths & percentage of cases

SELECT location, date, total_cases, total_deaths, population, ROUND((total_deaths/total_cases)*100, 2) as DeathPercentage, ROUND((total_cases/population)*100, 2) as CasesPercentage
FROM covidproject.coviddeaths
WHERE location='Canada'
Order by 1,2

--Looking at countries with highest infection rate per population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, ROUND((MAX((total_cases/population))*100), 2) as CasesPercentage
FROM covidproject.coviddeaths
GROUP BY location, population
ORDER BY CasesPercentage DESC

--Looking at countries with highest death rate per population
SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(total_cases) as HighestInfectionCount
FROM covidproject.coviddeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount DESC

-- highest deaths by continent
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX(total_cases) as HighestInfectionCount
FROM covidproject.coviddeaths
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- total cases across the globe (remove date to see total cases throughout the entire period)
SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM covidproject.coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT *
FROM covidproject.coviddeaths dea
JOIN covidproject.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date

--1:00 hour mark
--looking at total population that was vaccinated (using new vaccinations which is per day)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covidproject.coviddeaths dea
JOIN covidproject.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date

--calculating rolling count of new vaccinations per day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM covidproject.coviddeaths dea
JOIN covidproject.covidvaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
AND dea.location='Canada'
ORDER BY dea.location, dea.date

-- Use common table expression (CTE) create temp table to calculate percentage of rolling vaccination count in population

WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinationCount) --number of columns has to match number of columns in 'as' query below
AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) as RollingVaccinationCount
  FROM covidproject.coviddeaths dea
  JOIN covidproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent is not null
  AND dea.location='Canada'
ORDER BY dea.location, dea.date
)
SELECT *
FROM PopVsVac

WITH PopVsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccinationCount
  FROM covidproject.coviddeaths dea
  JOIN covidproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
  --AND dea.location = 'Canada'
)
SELECT *, ROUND((RollingVaccinationCount/population)*100,2) AS PercentPopulationVaccinated
FROM PopVsVac;
