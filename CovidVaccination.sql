use Project1;
select Location,date,total_Cases,new_cases,total_deaths,population from project1.coviddeaths;
select Location,date,total_Cases,total_deaths,(total_deaths/total_Cases)*100 death_percentage 
from project1.coviddeaths
where location like "%India%";
select Location,date,total_Cases,Population,(total_Cases/Population)*100 percent_population_infection 
from project1.coviddeaths
where location like "%India%";
select Location,max(total_Cases) as Max_cases,Population,max((total_Cases/Population)*100) percent_population_infection 
from project1.coviddeaths
group by Location,Population
order by percent_population_infection desc;
select Location,max(total_deaths) as Max_deaths
from project1.coviddeaths
where continent is not null
group by Location
order by Max_deaths desc;
select continent,max(total_deaths) as Max_deaths
from project1.coviddeaths
where continent is not null
group by continent
order by Max_deaths desc;
select date, sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
from project1.coviddeaths
where continent is not null
group by date;
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
from project1.coviddeaths
where continent is not null;

desc coviddeaths;
desc covidvaccinations;  

select date_format(curdate(),'%d-%m-%y');
select date_format(date,'%d-%m-%y') from covidvaccinations;
select date from covidvaccinations;
ALTER TABLE covidvaccinations 
MODIFY date Date,
MODIFY iso_code VARCHAR(100),
MODIFY continent VARCHAR(100),
MODIFY location VARCHAR(100);

-- Disable safe updates
SET SQL_SAFE_UPDATES = 0;

-- Perform the update
UPDATE covidvaccinations
SET date = DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%d-%m-%Y')
WHERE date IS NOT NULL;

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;

select *
from project1.coviddeaths dea 
join project1.covidvaccinations vac
on dea.location = vac.location 
and dea.date=vac.date;

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from project1.coviddeaths dea 
join project1.covidvaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null;

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,date) as rolling_people_vaccinated
from project1.coviddeaths dea 
join project1.covidvaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null;

with populationVSvacc (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
( select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,date) as rolling_people_vaccinated
from project1.coviddeaths dea 
join project1.covidvaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null
)
select *,(rolling_people_vaccinated/Population)*100
from populationVSvacc;


#Temprory table
drop table if exists PercentagePopulationVaccinated;
create table PercentagePopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date varchar(255),
population numeric,
new_vaccination text,
rolling_people_vaccinated numeric);

insert into PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,date) as rolling_people_vaccinated
from project1.coviddeaths dea 
join project1.covidvaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null;

select *, (rolling_people_vaccinated/population)*100
from PercentagePopulationVaccinated;

# create view for visualization
create view viewPercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,date) as rolling_people_vaccinated
from project1.coviddeaths dea 
join project1.covidvaccinations vac
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null;





