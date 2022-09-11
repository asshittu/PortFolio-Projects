/*
Covid 19 Data Exploration

Skills Used: Temporary Tables, Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views

Data Gotten from "Our World in Data" from January 2020 to April 2021 --> https://ourworldindata.org/covid-deaths

Platform: Google BigQuery

*/

SELECT  
 *
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Selecting Data to start with

SELECT
  location,
  date,
  total_cases,
  new_cases, 
  total_deaths,
  population
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Viewing Total Cases vs Total Deaths
-- Shows likehood of dying if you contract covid in your country

SELECT  
  location,
  date,
  total_cases, 
  total_deaths,
  ROUND((total_deaths/total_cases)*100, 2) AS death_percentage
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE location like '%Nigeria%' AND continent IS NOT NULL
ORDER BY location, date;


-- Viewing Total Cases vs Population
-- Shows what percentage of population got infected with Covid

SELECT  
  location,
  date,
  population
  total_cases,
  ROUND((total_cases/population)*100, 2) AS percent_of_population_infected
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE location like '%Nigeria%' AND continent IS NOT NULL
ORDER BY location, date;


-- Countries with Highest Infection Rate compared to Population

SELECT  
  location,
  population,
  MAX(total_cases)AS highest_infection_count,
  MAX((total_cases/population))*100 AS percent_of_population_infected
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_of_population_infected DESC;


-- Countries with Highest Death Count per Population

SELECT  
  location,
  MAX(total_deaths) AS total_death_count
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- BREAKDOWN BY CONTINENT

-- Showing Continents with the highest death count per population

SELECT  
  continent,
  MAX(total_deaths) AS total_death_count
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- Global Numbers

SELECT
  SUM(new_cases) AS total_cases,
  SUM(new_deaths) AS total_deaths,
  SUM(new_deaths) / SUM(new_cases)*100 AS death_percentage
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- Total Population vs Vaccinations
-- Shows Percentage of population that has received at least one Covid Vaccine

SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM `portfolio-project-362200.CovidDeaths.Deaths` dea
JOIN `portfolio-project-362200.CovidDeaths.Vaccines` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Using CTE to perform calculation on Partition by

WITH PopvsVac (continent, location, date, population, new_vaccinations, counting_people_vaccinated AS 
(SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM `portfolio-project-362200.CovidDeaths.Deaths` dea
JOIN `portfolio-project-362200.CovidDeaths.Vaccines` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)

SELECT *, (counting_people_vaccinated)*100
FROM PopvsVac;

-- Using Temp Table to perform calculations on partition by

DROP TABLE IF EXISTS Percent_Population_Vaccinated
CREATE TEMPORARY TABLE Percent_Population_Vaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime, 
  population numeric,
  new_vaccinations numeric,
  counting_people_vaccinated numeric
)


INSERT INTO Percent_Population_Vaccinated
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM `portfolio-project-362200.CovidDeaths.Deaths` dea
JOIN `portfolio-project-362200.CovidDeaths.Vaccines` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (counting_people_vaccinated)*100
FROM Percent_Population_Vaccinated;


-- Creating view to store data for visualization in Tableau

CREATE VIEW Percent_Population_Vaccinated AS
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS counting_people_vaccinated
FROM `portfolio-project-362200.CovidDeaths.Deaths` dea
JOIN `portfolio-project-362200.CovidDeaths.Vaccines` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
