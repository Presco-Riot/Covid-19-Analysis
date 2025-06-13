--                   QUERYING THE DATABASE

--    I) Total_cases vs Total_death
-- 1. Day to day country level percentage of people who died of Covid 19
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS NUMERIC) / CAST(total_cases AS NUMERIC)) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;

-- 2. Countries with the Highest Death Count per Population
SELECT location, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL 
ORDER BY total_death_count DESC;

-- 3. Day to day percentage of people who died of Covid 19 in Cameroon rounding it to 3 decimal places
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS NUMERIC) / CAST(total_cases AS NUMERIC)) * 100 AS death_percentage
FROM coviddeaths
WHERE location = 'Cameroon';

-- 4. Continents with the Highest Death Count per Population
SELECT continent, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL  
GROUP BY continent
ORDER BY total_death_count DESC;


--    II) Total_cases vs Population
-- 5. Day to day percentage of population that got Covid 19
SELECT location, date, population, total_cases, (CAST(total_cases AS NUMERIC)/population) * 100 AS infected_population_percentage
FROM coviddeaths;

-- 6. Day to day percentage of population that got Covid 19 in Cameroon
SELECT location, date, population, total_cases, (CAST(total_cases AS NUMERIC)/population) * 100 AS infected_population_percentage
FROM coviddeaths
WHERE location = 'Cameroon';

-- 7. Countries with the highest Infection Rate compared to the population
SELECT location, population, MAX(CAST(total_cases AS NUMERIC)) AS highest_infection_count, MAX((CAST(total_cases AS NUMERIC) /population)) * 100 AS infected_population_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((CAST(total_cases AS NUMERIC) /population)) * 100 IS NOT NULL 
ORDER BY infected_population_percentage DESC;

-- 8. Continents with the Highest Death Count per Population
SELECT continent, MAX(total_deaths) AS total_death_count
FROM coviddeaths
WHERE continent IS NOT NULL  
GROUP BY continent
ORDER BY total_death_count DESC;



-- . 
SELECT SUM(new_cases) AS total_new_cases, SUM(new_deaths) AS total_new_death, (SUM(CAST(new_deaths AS NUMERIC)) / SUM(CAST(new_cases AS NUMERIC))) * 100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;
--GROUP BY date


--- III) Total Population vs Vaccinations
-- 9. Period where people were vaccinated by country, including the continent field.
SELECT cd.continent, cd.location, cd.date, cd.population, cv.people_vaccinated
FROM coviddeaths AS cd 
JOIN covidvaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY cd.date, cd.location;

-- 10. Day-wise new vaccinations for each country per population, including the continent field
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated -- i.e the total number of new vaccinations
FROM coviddeaths AS cd 
JOIN covidvaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY cd.location, cd.date;

-- 11. Day-wise new vaccination rate for each country per population
SELECT continent, location, date, population, rolling_people_vaccinated, (CAST(rolling_people_vaccinated AS NUMERIC) / population) * 100 AS percentage_rpv
FROM (SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS int)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated -- i.e the total number of new vaccinations
      FROM coviddeaths AS cd 
      JOIN covidvaccinations AS cv ON cd.location = cv.location AND cd.date = cv.date
      WHERE cd.continent IS NOT NULL 
      ORDER BY cd.location, cd.date) AS PopvsVac;


-- 12. Continents with the largest number of tests from 2020 to 2023
WITH tests_2020 AS ( 
     SELECT  continent, MAX(total_tests) AS total_tests_2020
     FROM covidvaccinations
     WHERE EXTRACT(YEAR FROM date) = 2020
     GROUP BY continent
),
tests_2021 AS (
     SELECT continent, MAX(total_tests) AS total_tests_2021
     FROM covidvaccinations
     WHERE EXTRACT(YEAR FROM date) = 2021
     GROUP BY continent
),
tests_2022 AS (
     SELECT continent, MAX(total_tests) AS total_tests_2022
     FROM covidvaccinations
     WHERE EXTRACT(YEAR FROM date) = 2022
     GROUP BY continent
),
tests_2023 AS (
     SELECT continent, MAX(total_tests) AS total_tests_2023
     FROM covidvaccinations
     WHERE EXTRACT(YEAR FROM date) = 2023
     GROUP BY continent
)
SELECT t0.continent, t0.total_tests_2020, t1.total_tests_2021, t2.total_tests_2022, t3.total_tests_2023
FROM tests_2020 AS t0
JOIN tests_2021 AS t1 ON t0.continent = t1.continent
JOIN tests_2022 AS t2 ON t0.continent = t2.continent
JOIN tests_2023 AS t3 ON t0.continent = t3.continent

