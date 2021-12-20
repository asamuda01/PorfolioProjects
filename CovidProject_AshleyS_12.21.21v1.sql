select * 
from PortfolioProject.dbo.CovidDeaths
order by 3,4

--select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--Select Data we will be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2


-- Total Cases VS Total Deaths
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Total Cases VS Total Deaths in United States (Dec,2021)
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Total Cases VS Population Total in United States
--% of population infected in the United States
select Location, date, population, total_cases,(total_cases/population)*100 as PopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Countries with Highest Infection Rate Compared to Pouplation
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfected
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location, Population
order by PopulationInfected Desc

-- Highest Death Rate by Country (Dec 2021)
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount Desc


--Exploring Death Rate by Continent (Dec, 21)
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount Desc

---for discrepancies in dataset (NULL Continents)
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount Desc


--Continents with Highest Death Rate
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount Desc

-- Global Numbers
--Daily sum of new cases & deaths globally
select date, sum(new_cases) as sum_of_new_cases, sum(cast(new_deaths as int)) as sum_of_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2

--global death percentage
select sum(new_cases) as sum_of_new_cases, sum(cast(new_deaths as bigint)) as sum_of_new_deaths, sum(cast(new_deaths as bigint))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2


---Vaccinations

select * 
from PortfolioProject.dbo.CovidVaccinations
order by 3,4

--Joining Deaths (dea) Table and Vaccinations (vac) Table

Select * 
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Total Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3
--Rolling count of vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 2,3

---Using Common Table Expression

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
Over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select * 
from PopvsVac

--Rolling Vaccine Percentage using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
Over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
from PopvsVac


---TEMP Table
DROP Table if exists #PercentPopulationVaccinated --when making updates
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric , 
New_Vaccinations numeric , 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
Over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Select * , (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
from #PercentPopulationVaccinated


--Creating View To store Data for later

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations))
Over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from  PortfolioProject.dbo.CovidDeaths dea
Join  PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated