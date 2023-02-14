select *
from PortfolioProject..CovidDeaths
order by 3,4


--Select *
--from PortfolioProject..CovidDeaths$
--order by 3,4

-- Select the data thats going to be used

select location, date,total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- comparing total cases to total deaths and the chance of death
select location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%mexico%'
order by 1,2


-- now total cases to populations. Percentage of population that contacyed covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopInfected
from PortfolioProject..CovidDeaths
where location like '%mexico%'
order by 1,2

-- countries with highest infection rates comparared to population

select location, population, MAX(total_cases ) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopInfected
FROM PortfolioProject..CovidDeaths
group by location, population -- aggretate error
order by PercentagePopInfected Desc

--Countries with highest death count per population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
group by location
order by TotalDeathCount DESC

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC

-- by continent 

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC

-- main script

select location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC


--Continents with highest death count

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount DESC


-- Global numbers

Select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases )*100  as DeathPercentage
from PortfolioProject..CovidDeaths
--where location 
where continent is not null
group by date
order by 1,2

--

Select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, sum(cast(new_deaths as int))/sum(new_cases )*100  as DeathPercentage
from PortfolioProject..CovidDeaths
--where location 
where continent is not null
group by date
order by 1,2


-- Vac
Select *
from PortfolioProject..CovidVaccinations

-- join Death table with Vax Table -- total population and vaccinations ----Cheged the variables 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by  dea.location, dea.date) as RollingPplVax
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2, 3

-- use a CTE --- RollingPplVax/population * 100

with PopVsVax (continent, location, date, population, new_vaccinations, RollingPplVax)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPplVax
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2, 3
)

SELECT *, (RollingPplVax/population)*100 as percentage
FROM PopVsVax

-- temp table
Drop Table if exists #PercentPopVax
Create Table #PercentPopVax
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVax numeric
)

insert into #PercentPopVax

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPplVax
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null  added drop table on top to able to change stuff so can be easy to mantain
--order by 2, 3

SELECT *, (RollingPplVax/population)*100 

from #PercentPopVax

--- view for viz 
Create view PercentPeopleVaxed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPplVax
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  
