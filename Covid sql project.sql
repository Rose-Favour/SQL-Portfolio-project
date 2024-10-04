SELECT * from projectdatabase ..CovidDeaths
order by 3,4

--SELECT * from projectdatabase ..CovidVaccinations
--order by 3,4

--select data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
from projectdatabase ..CovidDeaths
order by 3,4

--looking at the total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from projectdatabase ..CovidDeaths
where location like '%kenya'
order by 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
Select Location,date,total_cases,population,(total_cases/population)*100 as Populationpercentage
from projectdatabase ..CovidDeaths
where location like '%kenya'
order by 1,2

--looking at countries with highest infection rates compared to population
Select Location,Population,MAX(total_cases) as HighestInfectioncount,max(total_cases/population)*100 as PercentPopulationinfected
from projectdatabase ..CovidDeaths
--where location like '%kenya'
group by Location,Population
order by PercentPopulationinfected desc

--showing the countries with the highest death count 
Select location,sum(cast(total_deaths as int)) as TotalDeathcount
from projectdatabase ..CovidDeaths
where continent is not null 
group by location
order by TotalDeathcount desc

Select continent,max(cast(total_deaths as int)) as TotalDeathcount
from projectdatabase ..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathcount desc

--GLOBAL NUMBERS
Select SUM(NEW_CASES) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(NEW_CASES)*100 as Deathpercentage
from projectdatabase ..CovidDeaths
--where location like '%kenya'
where continent is not null 
--group by  date
order by 1,2

select * 
from projectdatabase..CovidVaccinations vac
join projectdatabase..Coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date

--looking at totalpopulation vs vaccinations
select dea.continent,dea.location,dea.population,dea.date ,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
 from projectdatabase..CovidVaccinations vac
join projectdatabase..Coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

--use CTE
WITH PopvsVac (Continent,Location,Population,date,new_vaccinations,Rollingpeoplevaccinated)
as
(

select dea.continent,dea.location,dea.population,dea.date ,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
 from projectdatabase..CovidVaccinations vac
join projectdatabase..Coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

) 
select * ,(Rollingpeoplevaccinated/Population)*100
 from PopvsVac

 --temptable

 drop table if exists #PercentpopulationVaccinated
 create table #PercentpopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 population float,
 date datetime,
 new_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )


 Insert into #PercentpopulationVaccinated
 select dea.continent,dea.location,dea.population,dea.date ,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
 from projectdatabase..CovidVaccinations vac
join projectdatabase..Coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(Rollingpeoplevaccinated/Population)*100
 from #PercentpopulationVaccinated


 --creating view to store data for later visualizations


 Create view PercentpopulationVaccinated as 
select dea.continent,dea.location,dea.population,dea.date ,vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
 from projectdatabase..CovidVaccinations vac
join projectdatabase..Coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentpopulationVaccinated