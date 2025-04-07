select * from Covid19Project..CovidDeaths
--where iso_code like '%OWID%'
order by 3, 4 ;

select * from Covid19Project..CovidVaccinations
--where iso_code like '%OWID%'
order by 3, 4 ;

--Total Cases vs Total Deaths (Shows likelihood of dying if you contract COVID in your country)
--Total Cases vs Population (Shows what percentage of population infected with Covid)

select location, date, population, new_cases, total_cases, total_deaths,
(total_deaths/total_cases)*100 as death_percentage,
(total_cases/population)*100 as infection_rate
from Covid19Project..CovidDeaths
order by 1, 2 ;

--Countries with Highest Infection Rate Compared to Population
 

 select location, population,max(total_cases)as total_case,
max((total_cases/population)*100) as infection_rate
from Covid19Project..CovidDeaths
group by location,population
order by 4 desc;

 --Countries with Highest Death Count per Population

 select location, population,max(cast(total_deaths as int))as deaths
--max(cast((total_deaths/total_cases)*100 as int) )as death_percentage
from Covid19Project..CovidDeaths
where continent is not null
group by location,population
order by 3 desc;

--Showing continents with the highest death count per population


 select continent, population,max(cast(total_deaths as int))as deaths
--max(cast((total_deaths/total_cases)*100 as int) )as death_percentage
from Covid19Project..CovidDeaths
where continent is not null
group by continent,population
order by 3 desc;

--Global numbers

select sum(new_cases)as total_case,sum(cast(new_deaths as int))as total_deaths
--sum(total_cases/population)*100) as infection_rate
from Covid19Project..CovidDeaths
where continent is not null
--group by location,population
--order by 4 desc;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine







Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Total Number of vaccination by continent
Select continent
, SUM(CONVERT(int,new_vaccinations)) as TotalNumberVaccinationByContinent
From Covid19Project..CovidOriginal
where continent is not null 
Group by continent;

--Total Number of vaccination by country
Select  location
, SUM(CONVERT(int,new_vaccinations)) as TotalNumberVaccinationByCountry
From Covid19Project..CovidOriginal
where continent is not null 
Group by location
Order by 1;








-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac 
as
--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
--as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinatedPeople
From PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query 
--Creating View to store data for later visualizations 

DROP Table if exists #PopvsVaccTempTable
Create  table  #PopvsVaccTempTable
(

continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
RollingPeopleVaccinated int


)

Insert into #PopvsVaccTempTable
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * , (RollingPeopleVaccinated/Population)*100 as PercentageVaccinatedPeople
From #PopvsVaccTempTable;

DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--DROP VIEW IF EXISTS continentView;
GO
--Create View continentView as
--Select continent
--, SUM(CONVERT(int,new_vaccinations)) as TotalNumberVaccinationByContinent
--From Covid19Project..CovidOriginal
--where continent is not null 
--Group by continent;
--GO

--SELECT * FROM continentView
