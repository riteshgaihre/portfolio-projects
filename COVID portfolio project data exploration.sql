-- Covid 19 Data Exploration
-- skills used: joins, cte, aggregiate function, windows function, temp table, view

--First view the data 
 select * from covidDeaths
 
 -- selecting the data that are necessary 
 select location, date, population, total_cases, total_deaths from covidDeaths
 
 -- lets findout the deathpercentage
 select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage FROM
 covidDeaths
 where location = 'Australia'
 
 --lets findout the percentage of covidInfected
 select location, date, total_cases, population, (total_cases/population)*100 as covidInfectedPercent from covidDeaths
 where location = 'China'
 
 --lets findout the highest death countries from covid
 select location, max(total_deaths)as highestDeath from covidDeaths
where continent is not null
group by location
order by 2 desc -- we can see highest death from covid is united states

--countries with a highest covid infection
select location, max(total_cases)as highCovidInfected from covidDeaths
where continent is not null 
group by 1
order by 2 desc -- from the data US is first of highly infected from covid and second one is india)

-- Breaking things down by continent
select continent, max(total_deaths)as deathFromCovid, max(total_cases)as HighlyInfected from covidDeaths
where continent is not null
group by 1
order by 2 desc

--lets join the both table - covidDeath and covidVaccinations 
-- to findout the how many people vaccinated with new vaccination

select death.location, death.continent, death.date, death.population,
vacc.new_vaccinations, sum(vacc.new_vaccinations)over(partition by death.location
order by death.date)as countingVaccination
from covidDeaths as death
inner join covidVaccination as vacc
on death.location = vacc.location and
death.date = vacc.date
where death.continent is not null and vacc.new_vaccinations is not null

--Using cte 
with cte as (
	select death.location, death.continent, death.date, death.population,
vacc.new_vaccinations, sum(vacc.new_vaccinations)over(partition by death.location
order by death.date)as countingVaccination
from covidDeaths as death
inner join covidVaccination as vacc
on death.location = vacc.location and
death.date = vacc.date
where death.continent is not null and vacc.new_vaccinations is not null
)
select *, (countingVaccination/population)*100 as percentageOfpeopleVaccinated from cte

--use temp table 
create temp table vaccinatedDetail
(continent varchar(50),
location varchar(50),
date date,
 population numeric,
 new_vaccinations numeric,
 countingVaccination numeric
);
insert into vaccinatedDetail
select death.location, death.continent, death.date, death.population,
vacc.new_vaccinations, sum(vacc.new_vaccinations)over(partition by death.location
order by death.date)as countingVaccination
from covidDeaths as death
inner join covidVaccination as vacc
on death.location = vacc.location and
death.date = vacc.date
where death.continent is not null and vacc.new_vaccinations is not null

select *, (countingVaccination/population)*100 as peopleVaccinatedPercent from vaccinatedDetail

-- creating view to store data for later visualization
create view vaccinationDetail as 
select death.location, death.continent, death.date, death.population,
vacc.new_vaccinations, sum(vacc.new_vaccinations)over(partition by death.location
order by death.date)as countingVaccination
from covidDeaths as death
inner join covidVaccination as vacc
on death.location = vacc.location and
death.date = vacc.date
where death.continent is not null and vacc.new_vaccinations is not null



