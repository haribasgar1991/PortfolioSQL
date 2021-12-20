-- Sample

Select * 
From covidDeaths
Where [continent] IS NOT NULL
Order by 3,4

--Select * 
--From covidVaccinations
--Order by 3,4

--Data that we'd need

Select [location],[date],[total_cases],[new_cases],[total_deaths],[population]
From covidDeaths
Order by 1,2

--Total cases vs Total Deaths
--Likelihood of death if you get infected

Select [location],CAST([date] AS Date) AS [date],
		[total_cases],
		[total_deaths],
		Round((total_deaths/total_cases)*100, 2) AS DeathPercentage
From covidDeaths
Where location like '%states%'
Order by 1,2

--Looking at total cases vs Population
--Percentage of population with COVID

Select [location],
		MAX([total_cases]) AS HighestInfectionCount,
		population,
		MAX(Round((total_cases/population)*100, 2)) AS InfectedPercentage
From covidDeaths
--Where location like '%states%'
Group by [location],population
Order by InfectedPercentage DESC

--Countries with highest death count per population

Select [location],
		MAX(CAST([total_deaths] AS INT)) AS HighestDeathCount
		--population,
		--MAX(Round((total_cases/population)*100, 2)) AS InfectedPercentage
From covidDeaths
Where [continent] IS NOT NULL
Group by [location] --,population
Order by HighestDeathCount DESC

--Continent wise data

Select  [continent],
		SUM(CAST([total_deaths] AS INT)) AS HighestDeathCount
		--population,
		--MAX(Round((total_cases/population)*100, 2)) AS InfectedPercentage
From covidDeaths
Where [continent] IS NOT NULL
Group by  [continent]--population
Order by HighestDeathCount DESC

--Global Wise

Select --CAST(date AS DATE) AS Date,
		SUM(CAST(new_cases AS INT)) AS new_cases,
		SUM(CAST(new_deaths AS INT)) AS new_deaths,
		SUM(CAST(new_deaths AS INT))/ SUM(CAST(new_cases AS INT))*100 AS NewDeathPercentage
From covidDeaths
Where [continent] IS NOT NULL
--Group by  Date
Order by 1,2 

--Total population vs Total vaccinations



Select cd.continent, cd.location,CAST(cd.date AS DATE) AS Date, 
	   cd.population, cv.new_vaccinations,
	   SUM( CONVERT(bigint, cv.new_vaccinations)) OVER (Partition By cd.location Order by cd.location, cd.date) AS RollingPplVaccinated 
From covidDeaths cd
Join covidVaccinations cv on cd.location = cv.location
						  and cd.date = cv.date
Where cd.continent iS NOT NULL
Order by 2,3


--Use CTE

WITH PopVsVac (continent, location, Date, population, new_vaccinations, RollingPplVaccinated)AS
(
Select cd.continent, cd.location,CAST(cd.date AS DATE) AS Date, 
	   cd.population, cv.new_vaccinations,
	   SUM( CONVERT(bigint, cv.new_vaccinations)) 
	   OVER (Partition by cd.location Order by cd.location, cd.date) AS RollingPplVaccinated 
From covidDeaths cd
Join covidVaccinations cv on cd.location = cv.location
						  and cd.date = cv.date
Where cd.continent iS NOT NULL
--Order by 2,3
)
Select * , Round((RollingPplVaccinated/population )*100, 2) AS RollingPplVaccinatedpercent
From PopVsVac

--USE Temp table

DROP Table if exists #PopPercentVaccinated
Create Table #PopPercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVaccinated numeric,
)


INSERT INTO #PopPercentVaccinated

Select cd.continent, cd.location,CAST(cd.date AS DATE) AS Date, 
	   cd.population, cv.new_vaccinations,
	   SUM( CONVERT(bigint, cv.new_vaccinations)) 
	   OVER (Partition by cd.location Order by cd.location, cd.date) AS RollingPplVaccinated 
From covidDeaths cd
Join covidVaccinations cv on cd.location = cv.location
						  and cd.date = cv.date
Where cd.continent iS NOT NULL

Select *, ROUND((RollingPplVaccinated/population )*100, 1) AS RollingPplVaccinatedPercent
From #PopPercentVaccinated

--Create View for future use

Create View RollingPplVaccinated AS

Select cd.continent, cd.location,CAST(cd.date AS DATE) AS Date, 
	   cd.population, cv.new_vaccinations,
	   SUM( CONVERT(bigint, cv.new_vaccinations)) 
	   OVER (Partition by cd.location Order by cd.location, cd.date) AS RollingPplVaccinated 
From covidDeaths cd
Join covidVaccinations cv on cd.location = cv.location
						  and cd.date = cv.date
Where cd.continent iS NOT NULL

Select * from RollingPplVaccinated