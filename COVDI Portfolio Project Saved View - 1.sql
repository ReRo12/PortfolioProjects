--Select location, MAX(total_cases) as HighestInfectionCount
--FROM PortfolioProject..CovidDeaths$
--GROUP BY location
--ORDER BY HighestInfectionCount

Select *
FROM PortfolioProject..CovidDeaths$
Order by 3,4


Select *
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by location, date




Select location, date, new_vaccinations, sum(cast(new_vaccinations as int)) over (partition by location order by location, date)
FROM PortfolioProject..CovidVacc$
where location like '%tobago%'
Group By location, date, new_vaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (new_total_deaths/new_total_cases)*100 as DeathPct
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--ALTER TABLE CovidDeaths$ ADD new_total_deaths float;

--UPDATE CovidDeaths$ SET new_total_deaths = CAST(total_deaths AS float);

--ALTER TABLE CovidDeaths$ ADD new_total_cases float;

--UPDATE CovidDeaths$ SET new_total_cases = CAST(total_cases AS float);

--ALTER TABLE CovidDeaths$ 
--DROP COLUMN total_cases2, total_deaths2;

-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid

Select location, date, total_cases, Population, (total_cases/population)*100 as DeathPct
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states'
ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population

Select location, Population, MAX(new_total_cases) as HighestInfectionCount, 
MAX((new_total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%tobago%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Let's break things down by continent

-- Showing continents with the highest death count

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
max(new_total_deaths)/Max(new_total_cases) * 100 as DeathPct
FROM PortfolioProject..CovidDeaths$
where continent is not null
--group by date 
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacc$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, 
Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacc$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacc$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVacc$ vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated