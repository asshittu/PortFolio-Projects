/*

These are queries used for Covid 19 Portfolio Project on Tableau

Platform: BigQuery

Data Gotten from "Our World in Data" from January 2020 to April 2021 --> https://ourworldindata.org/covid-deaths

*/

-- Total cases from January 2020 to April 2021

SELECT 
  SUM(new_cases) AS total_cases, 
  SUM(new_deaths) AS total_deaths, 
  SUM(new_deaths) / SUM(New_Cases)*100 AS Death_Percentage
FROM `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent IS NOT NULL 
ORDER BY 1,2;

-- Death Count Per Continent

SELECT 
  location, 
  SUM(new_deaths) AS Total_Death_Count
From `portfolio-project-362200.CovidDeaths.Deaths`
WHERE continent is null 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Percent Population Infected Per Country

SELECT 
  Location, 
  Population, 
  MAX(total_cases) AS Highest_Infection_Count,  
  Max((total_cases/population))*100 AS Percent_Population_Infected
FROM `portfolio-project-362200.CovidDeaths.Deaths`
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- Percentage of Population Infected and Future Forecast

SELECT 
  Location, 
  Population,date, 
  MAX(total_cases) AS HighestInfectionCount,  
  Max((total_cases/population))*100 AS Percent_Population_Infected
FROM `portfolio-project-362200.CovidDeaths.Deaths`
GROUP BY Location, Population, date
ORDER BY Percent_Population_Infected DESC;
