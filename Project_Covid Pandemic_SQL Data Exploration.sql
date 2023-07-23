USE ProjectPortfolio;

--Selecting the data to be used
SELECT location,date,total_cases,new_cases,total_deaths,population FROM CovidDeaths ORDER BY 1,2;

--Total Cases vs Total Deaths
--Showing the likelihood of dying by contracting covid 
ALTER TABLE CovidDeaths ALTER COLUMN total_cases Float;
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths FLOAT;
 
SELECT continent,location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM CovidDeaths 
WHERE location='Lebanon'
ORDER BY 1,2

--Total Cases Vs Population
--Showing the percentage of population infected by covid
SELECT location,date,total_cases,population,ROUND((total_cases/population)*100,2) AS InfectionPercentage
FROM CovidDeaths 
WHERE location='Lebanon'
ORDER BY 1,2

--Selection of countries with highest infection rates 
SELECT location,population, Max(total_cases) as HighestInfectionCount,ROUND(MAX((total_cases/population)*100),2) AS MaxInfectionPercent
FROM CovidDeaths 
GROUP BY location,population
ORDER BY MaxInfectionPercent Desc

--Selection based on Highest Death Count per Countries
SELECT location, Max(total_deaths) as TotalDeathCount
FROM CovidDeaths 
Where continent is not null 
GROUP BY location
ORDER BY TotalDeathCount Desc

--Selection based on Highest Death Count per Continents
SELECT location, Max(total_deaths) as TotalDeathCount
FROM CovidDeaths 
Where continent is null and location not in ('High income','Upper middle income','Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount Desc

--SELECT continent, Max(total_deaths) as TotalDeathCount
--FROM CovidDeaths 
--Where continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount Desc

--Global Data per Date
SELECT date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths
FROM CovidDeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1

--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order BY dea.location, dea.date) as RollingVaccination
FROM CovidDeaths dea 
JOIN CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

--USE CTE (Common Table Expression)
With PopVsVacc (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccinations)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order BY dea.location, dea.date) as RollingVaccination
FROM CovidDeaths dea 
JOIN CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 
)
SELECT *, (Rolling_Vaccinations/Population)*100 as VaccPercentage
FROM PopVsVacc;

--SELECT *, (RollingVaccinations/Population)*100 as VaccPercentage
--FROM 
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--		SUM(cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order BY dea.location, dea.date) as RollingVaccinations
--FROM CovidDeaths dea 
--JOIN CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
--WHERE dea.continent is not null 
--) as PopvsVacc

--Temp Table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)

Insert Into #PercentagePopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order BY dea.location, dea.date) as RollingVaccination
FROM CovidDeaths dea 
JOIN CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 

Select *, (Rolling_Vaccinations/Population)*100 as VaccPercentage
FROM #PercentagePopulationVaccinated

--Create View to Store Data for Later Visualization

Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(cast(vac.new_vaccinations as float)) OVER (Partition By dea.location Order BY dea.location, dea.date) as RollingVaccination
FROM CovidDeaths dea 
JOIN CovidVaccinations vac ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 
  
SELECT * FROM PercentagePopulationVaccinated


