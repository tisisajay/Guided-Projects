SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4 

-- Select data that we're going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, Date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Highest Infection rate compared to its Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Population, Location
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL 
--GROUP BY Date
ORDER BY 1,2


--LOOKING AT TOTAL POPULATION vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, 
	dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE



WITH Popvsvac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, 
	dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM Popvsvac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, 
	dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data fro later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, 
	dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated