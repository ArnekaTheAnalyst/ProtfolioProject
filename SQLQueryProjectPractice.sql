SELECT * 
FROM ProtfolioProjects..CovidDeaths
ORDER by 1,2

Select Location ,date, total_cases, new_cases,total_deaths,population
From ProtfolioProjects..CovidDeaths
--Where continent is not null
order by 1,2

--Loking at total Cases vs total deaths

Select Location ,date,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathsPercentenge
From ProtfolioProjects.dbo.CovidDeaths
Where location like '%Bangladesh%'
order by 1,2

--Loking for total_cases vs population
--Shows what percentage of population got covid 

Select Location ,date,population,total_cases,(cast(total_cases as float)/cast(population as float)*100) as PercentOfPopulationInfected
From ProtfolioProjects.dbo.CovidDeaths
--Where location like '%Bangladesh%'
order by 1,2

--Loking for countries with higest Infaction rate comapared to Population 

Select Location ,population, MAX(total_cases) as HighestInfactionCount , MAX (cast(total_cases as float)/cast(population as float)*100) as PercentPopulationInfected
From ProtfolioProjects.dbo.CovidDeaths
Group By location , population
order by PercentPopulationInfected desc


--Loking for Countries with highest death count per Population

Select Location , MAX(cast(total_deaths as int)) as HighestDeathCount 
From ProtfolioProjects.dbo.CovidDeaths
Where continent is not null
Group By location 
Order by HighestDeathCount  desc

--Let's Break Thing's Down by Continent


Select  Continent, MAX(cast(total_deaths as int)) as TotalDeathsCount 
From ProtfolioProjects.dbo.CovidDeaths
Where continent is not null
Group By continent
Order by TotalDeathsCount  desc


---------------------------

Select  Location, MAX(cast(total_deaths as int)) as TotalDeathsCount 
From ProtfolioProjects.dbo.CovidDeaths
Where continent is  null
Group By location
Order by TotalDeathsCount  desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) ,SUM(cast(new_deaths as Int)) ,SUM(cast(new_deaths as Int))/SUM(new_cases) as DeathsPercentise
From ProtfolioProjects.dbo.CovidDeaths
--Where location like '%Bangladesh%'
where continent is not null
Group By date
order by 1,2

--Warning: Null value is eliminated by an aggregate or other SET operation.
--Waring :future fucking problem ( When I sum the new_deaths and new_cases together for getting the precentise number than I am geting this fucking problem)

Select  SUM(new_cases) as total_cases ,SUM(cast(new_deaths as Int)) as total_deaths
From ProtfolioProjects.dbo.CovidDeaths
--Where location like '%Bangladesh%'
where continent is not null
order by 1,2

---Looking at Total population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations )) OVER( Partition by dea.location ORDER by dea.location,dea.date )  as TotalNewVac   
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccination vac
  On dea.location=vac.location
  and dea.date = vac.date
Where dea.continent is not null
order by 2,3

with PlzVac(continent,Location,Date,Population,New_Vaccinations,TotalNewVac) 
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations )) OVER( Partition by dea.location ORDER by dea.location,dea.date )  as TotalNewVac   
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccination vac
  On dea.location=vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
SELECT * ,(TotalNewVac/Population)*100
FROM PlzVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalNewVac numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations )) OVER( Partition by dea.location ORDER by dea.location,dea.date )  as TotalNewVac   
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccination vac
  On dea.location=vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

SELECT * ,(TotalNewVac/Population)*100
FROM #PercentPopulationVaccinated

--Creating View

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations )) OVER( Partition by dea.location ORDER by dea.location,dea.date )  as TotalNewVac   
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccination vac
  On dea.location=vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated