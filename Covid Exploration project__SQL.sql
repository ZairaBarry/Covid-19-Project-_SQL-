--Choose Data we will start with

Select Location,date,total_cases,new_cases,total_deaths,population
FROM Portfolio_Project..CovidDeaths
Where continent is not null
ORDER By 1,2



--Show total cases vs Total Deaths

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPerc
FROM Portfolio_Project..CovidDeaths
WHERE location = 'Canada'
and continent is not null
ORDER By 1,2


--Show total Cases vs Populaion
--% of population infected

Select Location, date, population, tota_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project..CovidDeaths
Order By 1,2


--Choose countries with Highest Infection rate

Select Location,Population,MAX(total_cases) as HighestInfectionRate,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio_Project..CovidDeaths
GROUP BY Location,Population
Order by PercentPopulationInfected DESC


--Choose countries with highest death count 

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY Location
Order by TotalDeathCount DESC



--Choose continent with highest death count 

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order by TotalDeathCount DESC



--Choose global numbers


Select  SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
FROM Portfolio_Project..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER By 1,2



--Show population vs vaccinations


SELECT dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.location Order by dea.location)
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVac vac
         ON dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null
ORDER by 2,3

	

	--Using CTE to perform calculation on Partition in previous query


With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
	  ( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVac vac
         ON dea.location=vac.location
		 and dea.date=vac.date
Where dea.continent is not null
      )
 Select *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- TEMP table


DROP table if exists #percentPopulationVaccinated
	
Create Table #percentPopulationVaccinated
	 (
Continent  nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
	 )

Insert into  #percentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVac vac
        ON dea.location=vac.location
		and dea.date=vac.date
--Where dea.continent is not null


Select *,(RollingPeopleVaccinated/population)*100
FROM #percentPopulationVaccinated;



--Create View


Create View percentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
 From Portfolio_Project..CovidDeaths dea
 JOIN Portfolio_Project..CovidVac vac
        ON dea.location=vac.location
		and dea.date=vac.date
Where dea.continent is not null

	

