Select * FROM
PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * FROM PortfolioProject..
--CovidVaccinations
--order by 3,4

--SELECT Data that we are going to be using
--Select Location,date,total_cases,
--new_cases,total_deaths,population FROM
--PortfolioProject..CovidDeaths
--where continent is not null
--order by 1,2

-- Looking at Total Cases Vs Total Deaths
--Select Location,date,total_cases,
--total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--order by 1,2

--Shows the likelihood of dying if you contract in your country
--Select Location,date,total_cases,
--total_deaths,(total_deaths/total_cases)*100 
--as DeathPercentage
--FROM PortfolioProject..CovidDeaths
--where location like'%states%'
--and continent is not null
--order by 1,2


--Looking at the Total Cases vs population
--Shows what percentage of population got covid
--Select Location,date,total_cases,Population
--,(total_cases/population)*100 
--as PercentagePopulationinfected
--FROM PortfolioProject..CovidDeaths
----where location like'%states%'
--order by 1,2

--Looking at the countries with highest infection Rate compared to population
--Select Location,Population,MAX(total_cases) 
--as HighestInfectioncount,
--MAX(total_cases/population)*100 
--as PercentPopulationinfected
--FROM PortfolioProject..CovidDeaths
--GROUP by Location,Population
--order by PercentPopulationinfected desc


--showing Countries with Highest death count per population
--SELECT 
--    Location,
--    MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
--FROM 
--    PortfolioProject..CovidDeaths
--	where continent is not null
--GROUP BY 
--    Location
--ORDER BY 
--    TotalDeathCount DESC;
	
	--Let's BREAK THINGD DOWN BY Continent
	SELECT 
    location,
    MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
	where continent is  null
GROUP BY 
     location
ORDER BY 
    TotalDeathCount DESC;

	--Let's BREAK THINGD DOWN BY Continent
	SELECT 
    continent,
    MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
	where continent is not null
GROUP BY 
     continent
ORDER BY 
    TotalDeathCount DESC;
	--showing continents with the highest death count per population
--SELECT  continent,
--MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
--FROM   PortfolioProject..CovidDeaths
--where continent is not null
--GROUP BY  continent
--ORDER BY TotalDeathCount DESC;


-- Global Numbers
--Select date,total_cases,
--total_deaths,(total_deaths/total_cases)*100 
--as DeathPercentage
--FROM PortfolioProject..CovidDeaths
----where location like'%states%'
--where continent is not null
--Group by date
--order by 1,2



--SELECT  date, SUM(new_cases) AS TotalCases, 
-- SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
--  (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
---- WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date, TotalCases;



--SELECT  SUM(new_cases) AS TotalCases, 
-- SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
-- (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
---- WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL
----GROUP BY date
--ORDER BY 1,2;


--Select * FROM PortfolioProject..CovidVaccinations

--SELECT *
--FROM PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--On dea.location = vac.location
--and dea.date=vac.date

--Looking at Total Population vs Vaccinations



--SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--,SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location)
--FROM PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--On dea.location = vac.location
--where dea.continent is not null
--and dea.date=vac.date
--order by 2,3


--SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
--,SUM(Convert(int,vac.new_vaccinations )) OVER(Partition by dea.Location Order by dea.location,
--dea.Date)
--FROM PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVaccinations vac
--On dea.location = vac.location
--where dea.continent is not null
--and dea.date=vac.date
--order by 2,3

--USE CTE
WITH PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent,dea.location,dea.date,
 dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location 
  ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac
ORDER BY Location, Date;

--Temp Table
DROP TABLE if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,
 dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location 
  ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
 --WHERE dea.continent IS NOT NULL
 --order by 2,3

 SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY Location, Date;

--Creating view to store data for data visualization
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,
 dea.population,vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location 
  ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --order by 2,3

 Select *FROM 
 PercentPopulationVaccinated