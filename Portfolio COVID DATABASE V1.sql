select *
from Portfolio..CovidDeaths
where continent is not null
order by 3,4


--select *
--from Portfolio..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths

order by 1,2


--Total cases vs total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null
--and location like '%Pakistan%'
order by 1,2

--Total Cases Vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as infectionpercentagepopulation
From Portfolio..CovidDeaths
where location like '%Pakistan%'
order by 1,2


--Countries with highest infection rate compared with population

Select Location, population, MAx(total_cases) as Highestinfectioncount,  max((total_cases/population))*100 as infectionpercentage
From Portfolio..CovidDeaths
group by Location, population

order by infectionpercentage desc


-- countries with highest Death count compare to pupolation

Select Location, MAx(cast(total_deaths as int)) as Deathcount
From Portfolio..CovidDeaths
where continent is not null
group by location
order by Deathcount desc

--Breakdown by continent

Select continent, MAx(cast(total_deaths as int)) as Deathcount
From Portfolio..CovidDeaths
where continent is not null
group by continent
order by Deathcount desc

--to include which are not detucted(like it includes only north america's count not other parts of it)

Select location, MAx(cast(total_deaths as int)) as Deathcount
From Portfolio..CovidDeaths
where continent is  null
group by location
order by Deathcount desc

--Total Deaths accros the Globe
Select date, Sum(cast(new_cases as int)) as Totalcases, Sum(cast(new_deaths as int)) as totalDeaths , 
Sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathpercentage
From Portfolio..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Total case vs total deaths 
Select Sum(cast(new_cases as int)) as Totalcases, Sum(cast(new_deaths as int)) as totalDeaths , 
Sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathpercentage
From Portfolio..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- Vaccination count partioned by location

Select CD.continent, CD.location, CD.date, population, CV.new_vaccinations,
sum(cast(CV.new_vaccinations as int)) over (partition by cd.Location order by CD.location, CD.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100 "we can't use newly created column" to use it we need CTE OR TEMP Functions
from Portfolio..CovidVaccinations$ CV
join Portfolio..Coviddeaths CD
on CD.location = CV.location
and cd.date = CV.date
where CD.continent is not null
order by 2,3





-- using CTE

with Popvsvac (continent, location, Date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select CD.continent, CD.location, CD.date, population, CV.new_vaccinations,
sum(cast(CV.new_vaccinations as int)) over (partition by cd.Location order by CD.location, CD.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100 "we can't use newly created column" to use it we need CTE OR TEMP Functions
from Portfolio..CovidVaccinations$ CV
join Portfolio..Coviddeaths CD
on CD.location = CV.location
and cd.date = CV.date
where CD.continent is not null

--order by 2,3)
)
select *, (rollingpeoplevaccinated/population)*100


--Temp Table
Drop table if exists #vaccinationpopulationpercentage
Create table #vaccinationpopulationpercentage
(continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric)

insert into #vaccinationpopulationpercentage

Select CD.continent, CD.location, CD.date, population, CV.new_vaccinations,
sum(cast(CV.new_vaccinations as int)) over (partition by cd.Location order by CD.location, CD.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100 "we can't use newly created column" to use it we need CTE OR TEMP Functions
from Portfolio..CovidVaccinations$ CV
join Portfolio..Coviddeaths CD
on CD.location = CV.location
and cd.date = CV.date
--where CD.continent is not null

Select *
From #vaccinationpopulationpercentage


-- creating a veiw to store data for latter

create view Percentpopulationvaccination as

Select CD.continent, CD.location, CD.date, population, CV.new_vaccinations,
sum(cast(CV.new_vaccinations as int)) over (partition by cd.Location order by CD.location, CD.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100 "we can't use newly created column" to use it we need CTE OR TEMP Functions
from Portfolio..CovidVaccinations$ CV
join Portfolio..Coviddeaths CD
on CD.location = CV.location
and cd.date = CV.date
--where CD.continent is not null


Select *
From Percentpopulationvaccination