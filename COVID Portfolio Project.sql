SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1, 2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentAge
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%aze%'
and continent is NOT NULL
ORDER BY 1, 2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%aze%'
ORDER BY 1, 2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentAge
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated
as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated