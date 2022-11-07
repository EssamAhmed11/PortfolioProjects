select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccination
--order by 3,4

select location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%egypt%'
order by 1,2

--looking at Total cases vs population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
where continent is not null
and  location like '%egypt%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%egypt%'
Group by location, population
order by PercentPopulationInfected desc

--showing countries with Highest Death count per population

select location, Max(cast(total_deaths as int)) as HighestDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- Let's break things down by continent

select location, Max(cast(total_deaths as int)) as HighestDeathCount 
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc






-- showing the continent with the highest death count population

select continent, Max(cast(total_deaths as int)) as HighestDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

-- Golbal numbers

select date,sum(new_cases) as GlobalCaseCount, sum(cast(new_deaths as int)) as GlobalDeathCount, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%egypt%'
where  continent is not null
group by date
order by 1,2

-- total cases and deats around the world till now

select sum(new_cases) as GlobalCaseCount, sum(cast(new_deaths as int)) as GlobalDeathCount, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%egypt%'
where  continent is not null
--group by date
order by 1,2

-----------------------------vaccination---------------

--Total population vs vaccincation

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on	dea.location = vac.location
	and	dea.date = vac.date
where  dea.continent is not null
order by 2,3


--Using CTE--temp table--


With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on	dea.location = vac.location
	and	dea.date = vac.date
where  dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

---------------------to get max vaccinated people----------


Drop Table if exists #PercentPopluationVaccinated
Create Table #PercentPopluationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Popluation numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopluationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on	dea.location = vac.location
	and	dea.date = vac.date
where  dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Popluation)*100
From #PercentPopluationVaccinated

-- create View to store data for later visualizations


create View PercentPopluationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on	dea.location = vac.location
	and	dea.date = vac.date
where  dea.continent is not null
--order by 2,3


Select *
From PercentPopluationVaccinated