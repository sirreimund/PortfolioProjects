SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

--Select the Data we are going to be using

SELECT Location, date,total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


--Total Cases Vs. Total Deaths

SELECT Location, date,total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location ='Nigeria'
ORDER BY 1,2


--Total Cases Vs. Population

SELECT Location, date,population,total_cases, ROUND((total_cases/population)*100,3) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
ORDER BY 1,2


--Countries With the Highest Infection Rate Compared To Population

SELECT Location,population,MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100,3) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
WHERE continent IS NOT NULL
GROUP BY Location,population
ORDER BY 4 DESC


--Countries with the Highest Death Count 

SELECT Location,MAX(cast (total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY 2 DESC


--let's break things down by continent
--World sums up everything except EU

SELECT location,MAX(cast (total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC



--for proper drill down effect on Tableau

SELECT continent,MAX(cast (total_deaths as int)) as TotalDeaths
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
WHERE continent IS not NULL
GROUP BY continent
ORDER BY 2 DESC


--GLOBAL NUMBERS
--New Cases worldwide on a daily basis

SELECT date,SUM(new_cases) TotalCasesWorld, SUM(cast(new_deaths as int)) TotalDeathsWorld, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,3) as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



--Across the World

SELECT SUM(new_cases) TotalCasesWorld, SUM(cast(new_deaths as int)) TotalDeathsWorld, 
ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,3) as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location ='Nigeria'
WHERE continent IS NOT NULL
ORDER BY 1,2



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations))OVER(Partition BY dea.location Order BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTEs
--To know percentage of the population in each country is vaccinated on a daily basis

With PopVsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations))OVER(Partition BY dea.location Order BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopVsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations))OVER(Partition BY dea.location Order BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location=vac.location AND dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Create View To Use Later

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations))OVER(Partition BY dea.location Order BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
  ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3





