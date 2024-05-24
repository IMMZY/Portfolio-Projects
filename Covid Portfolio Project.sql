-- SELECT *
-- from covidDeaths
-- WHERE continent is not NULL
-- ORDER BY 3,4

-- SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS INT) / CAST(total_cases AS INT))*100 AS DeathPercentage
-- FROM CovidDeaths
-- ORDER BY 1,2 
 
--  SELECT *
--  FROM CovidDeaths

-- TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELYHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
-- METHOD 1
-- SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 AS DeathPercentage
-- FROM CovidDeaths
-- ORDER BY 1,2 

-- METHOD 2
-- SELECT LOCATION, DATE, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
-- FROM CovidDeaths
-- WHERE LOCATION = 'United States'
-- ORDER BY 1,2

--LOOKING AT THE TOTAL CASES/ POPULATION

--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

-- SELECT Location, date,Population, total_cases, (CAST(total_cases AS FLOAT) / CAST(Population AS FLOAT))*100 AS PercentPopulationInfected
-- FROM CovidDeaths
-- /* WHERE LOCATION = 'United States'*/
-- ORDER BY 1,2 

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION.
/*SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((CAST(total_cases AS FLOAT) / CAST(Population AS FLOAT)))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC*/




--LET'S BREAK THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH HIGHST DEATH COUNT PER POPULATION
/*SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Projects..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC*/

--SHOWING COUNTRIES WITH HIGHST DEATH COUNT PER POPULATION
/*SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC*/

--TOTAL POPULATION VS VACCIANTIONS
-- HOW MANY PEOPLE HAVE BEEN VACCINATED?
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Projects..CovidDeaths AS dea
JOIN Projects..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM Projects..CovidDeaths AS dea
    JOIN Projects..CovidVaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac 


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM Projects..CovidDeaths AS dea
    JOIN Projects..CovidVaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR FUTURE VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM Projects..CovidDeaths AS dea
    JOIN Projects..CovidVaccinations AS vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not null


SELECT *
FROM PercentagePopulationVaccinated