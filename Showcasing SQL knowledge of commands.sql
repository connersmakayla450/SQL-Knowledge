--commented out commands were first used to view tables as they had been moved over from excel and to alter tables 
--to ensure they had only the needed columns and no empty columns due to transferring over

--SELECT * FROM CovidRelated.dbo.CovidVaccinations ORDER BY 3,4
--SELECT * FROM CovidRelated.dbo.CovidDeaths ORDER BY 3,4

--ALTER TABLE CovidRelated.dbo.CovidVaccinations DROP COLUMN F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,F23,F24,F25,F26

--SELECT location,date,total_cases,new_cases,total_deaths,population FROM CovidRelated.dbo.CovidDeaths ORDER BY 1,2

--SELECT * FROM CovidRelated.dbo.CovidDeaths WHERE continent is not null ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population FROM CovidRelated.dbo.CovidDeaths 
WHERE continent is not null ORDER BY 1,2

--likelihood of dying percenatage by country
SELECT location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as percentage_of_death
FROM CovidRelated.dbo.CovidDeaths 
where location like '%United States%' and continent is not null
ORDER BY 1,2

--Percentage that has been infected
SELECT location,date,population, total_cases, (total_cases/population)*100 as pecentage_of_infected_population
FROM CovidRelated.dbo.CovidDeaths 
--where location like '%United States%' and continent is not null
ORDER BY 1,2

--High infection rate by location
SELECT location,population,MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 as highest_percentage_infected
FROM CovidRelated.dbo.CovidDeaths 
GROUP BY location,population
ORDER BY highest_percentage_infected


--High death rate by country 
SELECT location,MAX(cast(total_deaths AS bigint)) AS death_total_count
FROM CovidRelated.dbo.CovidDeaths 
where continent is not null
GROUP BY location
order by death_total_count desc

--High death rate by continent
SELECT continent,MAX(cast(total_deaths AS bigint)) AS death_total_count
FROM CovidRelated.dbo.CovidDeaths 
where continent is not null
GROUP BY continent
order by death_total_count desc

--New Queries
--Global rate of cases, death totals and percentages
SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS bigint)) AS total_deaths, SUM(cast(new_deaths AS bigint))/SUM(new_cases)*100 AS percentage_of_death
FROM CovidRelated.dbo.CovidDeaths 
where continent is not null
order by 1,2

--Population that has recived 1st covid dosage/ atleast 1 covid vaccinne dosage

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as population_vaccinated
From CovidRelated.DBO.CovidDeaths death
Join CovidRelated.dbo.CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3

--CTE to perform calculation on data
WITH populationVaccinated (continent,location,date,population,new_vaccinations,population_vaccinated) AS

(Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as population_vaccinated
From CovidRelated.DBO.CovidDeaths death
Join CovidRelated.dbo.CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
)
SELECT *, (population_vaccinated/population)*100 AS percentage_vaccinated_per_population 
FROM populationVaccinated

