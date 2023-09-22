Select *
from PortfolioProject..CovidDeaths
where continent is null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in * country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what % of population contracted Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfection
from PortfolioProject..CovidDeaths
where location like '%kingdom%'
order by 1,2


-- Looking at countries with Highest Infection rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Looking at countries with Highest Death count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount desc 

---- Breaking things down by Continent
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
----where location like '%kingdom%'
--Where continent is null
--Group by location
--order by TotalDeathCount desc 

--Showing the continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc 


-- Global Numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Looking at total Population vs Vaccinations

Select dea.continent, dea.location, dea.date,  dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) OVER
(Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations
, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinationsb vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumulativeVaccinations)
as
(
Select d.continent, d.location, d.date,  d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations)) OVER
(Partition by d.location order by d.location, d.date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinationsB V
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)

Select *, (CumulativeVaccinations/Population)*100
From PopVsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeVaccinations numeric
)

Insert into  #PercentPopulationVaccinated
Select d.continent, d.location, d.date,  d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations)) OVER
(Partition by d.location order by d.location, d.date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinationsB V
	on d.location = v.location
	and d.date = v.date
--where d.continent is not null

Select *, (CumulativeVaccinations/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
Select d.continent, d.location, d.date,  d.population, v.new_vaccinations, sum(convert(int, v.new_vaccinations)) OVER
(Partition by d.location order by d.location, d.date) as CumulativeVaccinations
--, (CumulativeVaccinations/population)*100
From PortfolioProject..CovidDeaths D
Join PortfolioProject..CovidVaccinationsB V
	on d.location = v.location
	and d.date = v.date
where d.continent is not null


Select *
From PercentPopulationVaccinated