Select * 
from PortfolioProject..Coviddeaths$
Where continent is not null
order by 3,4;


Select * 
from PortfolioProject..CovidVaccinations$
Where continent is not null
order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeaths$
Where continent is not null
order by 1,2;

-- Looking at Total Cases vs population
--Shows what percentage of population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 As PercentagePopulationInfected
from PortfolioProject..Coviddeaths$
where location like '%states%'
order by 1,2;
--Looking at countries with Highest Infection rate Compared to Population

Select Location, Population, Max(total_cases) As HighestInfectionCount, MAX(total_cases/population)*100 As PercentagePopulationInfected
from PortfolioProject..Coviddeaths$
--where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc;

--Showing Countries with Highest Death Count Per Population

Select Location, MAX(CAST(Total_deaths AS int)) As HighestDeathCount
from PortfolioProject..Coviddeaths$
--where location like '%states%'
Where continent is not null
Group by Location, Population
order by HighestDeathCount desc;

--Showing continent  with Highest Death Count Per Population
Select continent, MAX(CAST(Total_deaths AS int)) As TotalDeathCount
from PortfolioProject..Coviddeaths$
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * from PercentPopulationVaccinated

