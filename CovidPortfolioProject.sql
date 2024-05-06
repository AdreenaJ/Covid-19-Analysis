
/*covid 19 data exploration*/

SELECT *
FROM PortfolioProject1..CovidDeaths
where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE 'I__ia'
and continent is not null
ORDER BY 1,2

--total cases vs popultion
-- Shows what percentage of population infected with Covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as Casespercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE 'I__ia'
ORDER BY 1,2

--countries with highest infection rate compared to population

SELECT location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as InfectionPercentage
FROM PortfolioProject1..CovidDeaths
Group by location,population
ORDER BY InfectionPercentage desc

--countries with highest deathcount per population

SELECT location,max(cast(total_deaths as int)) as HighestDeathCount 
FROM PortfolioProject1..CovidDeaths
where continent is not null
Group by location
ORDER BY HighestDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT continent,max(cast(total_deaths as int)) as HighestDeathCount 
FROM PortfolioProject1..CovidDeaths
where continent is not null
Group by continent
ORDER BY HighestDeathCount desc


--global numbers

SELECT date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject1..CovidVaccinations

SELECT *
FROM PortfolioProject1..CovidVaccinations
WHERE continent is not null

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
WHERE dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated1
create table #PercentPopulationVaccinated1
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated1
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
WHERE dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 as percentage
from #PercentPopulationVaccinated1


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
   ON dea.location=vac.location
   AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated


