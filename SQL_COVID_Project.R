install.packages("sqldf")
library(sqldf)
library(readr)


COVID_Deaths <- read.csv("/Users/patriecaking/Documents/DA Portfolio/COVID project/COVID Deaths.csv")
COVID_Vaccinations <- read.csv("/Users/patriecaking/Documents/DA Portfolio/COVID project/COVID Vaccinations.csv")

COVID_Deaths1 <- sqldf("SELECT * FROM COVID_Deaths WHERE continent <> ''")

COVID_Vaccinations1 <- sqldf("SELECT * FROM COVID_Vaccinations WHERE continent <> ''")


StartingData <- sqldf("SELECT Location, date, total_cases, new_cases, total_deaths, population
                      FROM COVID_Deaths1
                      ORDER BY 1,2 ")

# Compare total deaths to total cases

NationalDeathRates <- sqldf("SELECT location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
                      FROM COVID_Deaths1
                      ORDER BY 1,2")

#Compare the above in the US

USDeathRate <- sqldf("SELECT ;ocation, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
                      FROM COVID_Deaths1
                      WHERE Location LIKE '%States'
                      ORDER BY 1,2")

# What percentage of the US population got infected with COVID?

USInfectionRate <- sqldf("SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PopulationPercentage
                      FROM COVID_Deaths1
                      WHERE Location LIKE '%States'
                      ORDER BY 1,2")

# Compare highest infection rates across countries

MaxInfectionRates <- sqldf("SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectionPercent
                           FROM COVID_Deaths1
                           GROUP BY Location, population
                           ORDER BY PopulationInfectionPercent DESC")

# Compare highest infection rates across continents

MaxInfectionRatesbyContinent <- sqldf("SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectionPercent
                           FROM COVID_Deaths1
                           GROUP BY continent
                           ORDER BY continent")

# Compare highest death rates across countries

HighestDeathRates <- sqldf("SELECT Location, population, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PopulationDeathRate
                           FROM COVID_Deaths1
                           GROUP BY Location
                           ORDER BY PopulationDeathRate DESC")

# Compare the above across continents

HighestDeathRatesbyContinent <- sqldf("SELECT continent, population, MAX(total_deaths) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PopulationDeathRate
                           FROM COVID_Deaths1
                           GROUP BY continent
                           ORDER BY PopulationDeathRate DESC")

# Now look at the global numbers

GlobalNumbers <- sqldf("SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS GlobalDeathRate
                       FROM COVID_Deaths1
                       GROUP BY date
                       ORDER BY 1, 2")

# Death Rate of all reported cases

OverallGlobalDeathRate <- sqldf("SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathRate
                                FROM COVID_Deaths1")

# Compare population to number of vaccinations

Vaccinations <- sqldf("SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
                      FROM COVID_Deaths1 AS d
                      JOIN COVID_Vaccinations1 AS v
                      ON d.location = v.location
                      AND d.date = v.date
                      ORDER BY 2, 3")

# Add column showing rolling vaccination count per day

RollingVaccinationCount <- sqldf("SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_vaccinations
                      FROM COVID_Deaths1 AS d
                      JOIN COVID_Vaccinations1 AS v
                      ON d.location = v.location
                      AND d.date = v.date
                      ORDER BY 2, 3")

# Look at vaccination rates

VaccinationRate <- sqldf("WITH VacRate (continent, location, date, population, new_vaccinations, rolling_vaccinations) AS
                         (
                         SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as rolling_vaccinations
                      FROM COVID_Deaths1 AS d
                      JOIN COVID_Vaccinations1 AS v
                      ON d.location = v.location
                      AND d.date = v.date
                      )
                         SELECT *, (rolling_vaccinations/population)*100 AS vaccination_rate
                         FROM VacRate")
