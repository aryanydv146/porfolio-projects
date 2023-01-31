select *
from [portfolio projects]..CovidDeaths$
where continent is not null
order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
from [portfolio projects]..CovidDeaths$

--looking at total_cases vs total_deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentages
from [portfolio projects]..CovidDeaths$
where location= 'India'
and continent is not null
order by 1,2

--looking for total_cases vs population
--shows what percentages of populations got covid
select location, date, population, total_cases, (total_cases/population) * 100 as death_percentages
from [portfolio projects]..CovidDeaths$
--where location= 'India'
where continent is not null
order by 1,2

--looking at companies with highest infection rate compared to the population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population)) * 100 as percentpopulationinfected
from [portfolio projects]..CovidDeaths$
--where location= 'India'
where continent is not null
group by location, population
order by percentpopulationinfected desc

-- looking for the countries who have highest death rate
select location, max(cast(total_deaths as int)) as totaldeathscount
from [portfolio projects]..CovidDeaths$
--where location= 'India'
where  continent is not null
group by location
order by totaldeathscount desc
 
  --	LET'S BREAK THINGS BY CONTINENT
 select continent, max(cast(total_deaths as int)) as totaldeathscount
from [portfolio projects]..CovidDeaths$
--where location= 'India'
where  continent is not null
group by continent
order by totaldeathscount desc

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast (new_deaths as int)) / sum(new_cases)*100
as deathspercentages
from [portfolio projects]..CovidDeaths$
--where location= 'India'
where  continent is not null
order by 1,2 


-- Looking at total population vs total vaccination
select dea.continent, dea.location, dea.date, dea.population, vea.new_vaccinations
from [portfolio projects]..CovidDeaths$ dea
join [portfolio projects]..CovidVaccinations$ vea
  on dea.location = vea.location
 and dea.date    = vea.date
where dea.continent is not null
 order by 2,3

 with popvsvac ( continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated )
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vea.new_vaccinations
 ,sum(convert (int,vea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from [portfolio projects]..CovidDeaths$ dea
join [portfolio projects]..CovidVaccinations$ vea
  on dea.location = vea.location
 and dea.date    = vea.date
where dea.continent is not null
-- order by 2,3
 )
 select *, (Rollingpeoplevaccinated/population)*100
 from popvsvac
 
 -- TEMP TABLE
 drop table if exists #percentpeoplevaccinated
 create table #percentpeoplevaccinated
 (
 continent nvarchar(255),
 location  nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinated numeric,
 Rollingpeoplevaccinated numeric
 )

insert into #percentpeoplevaccinated
 select dea.continent, dea.location, dea.date, dea.population, vea.new_vaccinations
 ,sum(convert (int,vea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from [portfolio projects]..CovidDeaths$ dea
join [portfolio projects]..CovidVaccinations$ vea
  on dea.location = vea.location
 and dea.date    = vea.date
where dea.continent is not null
-- order by 2,3

-- creating view to store data for later visualization
create view percentpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vea.new_vaccinations
 ,sum(convert (int,vea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from [portfolio projects]..CovidDeaths$ dea
join [portfolio projects]..CovidVaccinations$ vea
  on dea.location = vea.location
 and dea.date    = vea.date
where dea.continent is not null
-- order by 2,3

select *
from #percentpeoplevaccinated




