
SELECT * FROM PortfolioCovid..Covid



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioCovid..Covid
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--nuevos casos y casos totales en España
 SELECT location,date,total_cases,new_cases FROM PortfolioCovid..Covid
 WHERE location LIKE '%spain%'
 ORDER BY date

 -- porcentaje de gente vacunada en españa
 SELECT date,(people_vaccinated/population)*100 AS gente_contagiada FROM PortfolioCovid..Covid
 WHERE location LIKE '%spain%'
ORDER BY gente_contagiada DESC

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioCovid..Covid
--Where location like '%af%'
Group by Location, Population
order by PercentPopulationInfected desc

 --paises con mas muertos por covid en europa
 DROP VIEW IF EXISTS dbo.porcentajemuertes 
 CREATE VIEW porcentajemuertes AS
SELECT  location, population,MAX(CAST(total_deaths AS INT)) AS 'muertes',(MAX(CAST(total_deaths AS INT)) / population) * 100 AS porcentaje_muertes
FROM PortfolioCovid..Covid 
WHERE continent is not null
GROUP BY location,population
--ORDER BY muertes  DESC

--sacamos la tabla para Tableau
select * from porcentajemuertes

--comparacion de porcentaje de poblacion mayor de 65 con el % de muertes--
SELECT Covid.location,porcentaje_muertes, aged_65_older,population_density  FROM porcentajemuertes JOIN PortfolioCovid..Covid
ON porcentajemuertes.location= Covid.location
GROUP BY Covid.location,porcentaje_muertes,aged_65_older,population_density 
ORDER BY porcentaje_muertes DESC

-- veamos si la densidad de poblacion es un factor relevante en el porcentaje de muertes
SELECT Covid.location,porcentaje_muertes, population_density FROM porcentajemuertes JOIN PortfolioCovid..Covid
ON porcentajemuertes.location= Covid.location
GROUP BY Covid.location,porcentaje_muertes, population_density
ORDER BY population_density DESC



Select porcentajemuertes.Location, porcentajemuertes.Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/porcentajemuertes.population))*100 as PercentPopulationInfected,
aged_65_older
From porcentajemuertes JOIN Covid
ON porcentajemuertes.location = Covid.location
Group by porcentajemuertes.Location, porcentajemuertes.Population, porcentaje_muertes, aged_65_older
order by PercentPopulationInfected desc


/*esta si que va, no estoy seguro de la razon pero me parece que puede ser por el cast(float) ya que antes me salian valores de 0
puede ser porque los habia casteado como INT y al dividir dos INT no puedes obtener un INT */
SELECT TOP 20
    location,
    MAX(CAST(total_deaths AS INT)) AS cuentamuertes,
    MAX(CAST(total_cases AS INT)) AS casos,
    MAX(CAST(total_deaths AS FLOAT)) / NULLIF(MAX(CAST(total_cases AS FLOAT)), 0) * 100 AS porc_muertescasos
FROM
    Covid
WHERE
    continent LIKE '%eur%'
GROUP BY
    location
ORDER BY
	casos DESC
