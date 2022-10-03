/* 
Data Analysis- Indian Census 2011
*/


------------Lets have look at both the datasets 

SELECT * FROM PortfolioProject..Indian_census_Dataset_1

SELECT * FROM PortfolioProject..Indian_census_Dataset_2


SELECT COUNT(*) FROM PortfolioProject..Indian_census_Dataset_1
SELECT COUNT(*) FROM PortfolioProject..Indian_census_Dataset_2



------------Filtering Data (say) Statewise

SELECT * FROM PortfolioProject..Indian_census_Dataset_1
WHERE state='Andhra Pradesh'

SELECT * FROM PortfolioProject..Indian_census_Dataset_1
WHERE state in ('Andhra Pradesh','Maharashtra')

SELECT * FROM PortfolioProject..Indian_census_Dataset_1
WHERE state LIKE '%pradesh%'


---------- Select states that starts with either D or M
	
SELECT  distinct state FROM PortfolioProject..Indian_census_Dataset_1 
WHERE lower(state) LIKE 'd%' or lower(state) LIKE 'm%' 



------------Calculating the Total Population Of India(as on 2011)

SELECT SUM(CONVERT(int,Population)) AS 'Population Of India'
FROM PortfolioProject..Indian_census_Dataset_2



------------ Average Growth Of Population Of India

SELECT AVG(CAST(growth AS float))*100 AS 'Avg Growth' FROM PortfolioProject..Indian_census_Dataset_1


------------- Average Growth Of Population Of India Statewise

SELECT state,AVG(CAST(growth AS decimal(10,4)))*100 AS 'Avg Growth %'
FROM PortfolioProject..Indian_census_Dataset_1
GROUP BY state


------------- Average Sex Ratio of India

SELECT Round(AVG(Convert(int,Sex_Ratio)),0) AS 'Avg Sex Ratio' FROM PortfolioProject..Indian_census_Dataset_1



-------------- Find the Top 3 States with the highest Sex Ratio

SELECT TOP(3) state,AVG(Cast(Sex_Ratio AS numeric)) AS 'Avg Sex Ratio'
FROM PortfolioProject..Indian_census_Dataset_1
Group BY state
Order by 'Avg Sex Ratio' DESC


------------ Find how many Districts in each state have Sex Ratio Greater than that of India's Avg Sex Ratio

SELECT state,Count(District) AS 'Number Of Districts'
FROM PortfolioProject..Indian_census_Dataset_1
WHERE 
	Sex_Ratio > (SELECT AVG(Convert(numeric,Sex_Ratio)) FROM PortfolioProject..Indian_census_Dataset_1)
Group by State
Order By 'Number Of Districts' DESC



------------ Calculate The Avg Literacy Rate

SELECT state,ROUND(AVG(Convert(float,Literacy )),0) AS 'Avg Literacy' 
FROM PortfolioProject..Indian_census_Dataset_1
Group by state
Order by 2 DESC


------------- Find Out the States Having Avg Literacy Rate Greater Than 90

SELECT state,ROUND(AVG(Convert(float,Literacy )),0) AS 'Avg Literacy' 
FROM PortfolioProject..Indian_census_Dataset_1
Group by state
HAVING ROUND(AVG(Convert(float,Literacy )),0) > 90
Order by 2 DESC


------------ Find the Top 5 States That need to concentrate on Providing Education More

SELECT TOP(5) state,ROUND(AVG(Convert(float,Literacy )),0) AS 'Avg Literacy' 
FROM PortfolioProject..Indian_census_Dataset_1
Group by state
Order by 2



------ Display a message that describes current situation when compared on Growth % Of Population(Well Controlled,Controlled and so on)

SELECT state,Round(avg(convert(float,growth))*100,2) AS GROWTH,
CASE 
	WHEN avg(convert(float,growth))*100  < 5 THEN 'WELL CONTROLLED'
	WHEN avg(convert(float,growth))*100  <10 THEN 'CONTROLLED'
	WHEN avg(convert(float,growth))*100  <20 THEN 'CRITICAL'
	ELSE 'DISTURBING'
END AS 'Population Control'

FROM PortfolioProject..Indian_census_Dataset_1
GROUP BY state



---------- Display the Top and Bottom 3 states' Sex Ratio

--Creating Temp Table for TOP states

DROP TABLE IF EXISTS #topstates
CREATE TABLE #topstates
(	state nvarchar(255),
	topstates float
)

INSERT INTO #topstates

SELECT state,AVG(Cast(Sex_Ratio AS numeric)) AS 'Avg Sex Ratio'
FROM PortfolioProject..Indian_census_Dataset_1
Group BY state


SELECT TOP(3) * FROM #topstates 
ORDER BY topstates DESC


--Creating Temp Table for BOTTOM states

DROP TABLE IF EXISTS #bottomstates
CREATE TABLE #bottomstates
(	state nvarchar(255),
	bottomstates float
)

INSERT INTO #bottomstates

SELECT state,AVG(Cast(Sex_Ratio AS numeric)) AS 'Avg Sex Ratio'
FROM PortfolioProject..Indian_census_Dataset_1
Group BY state


SELECT TOP(3) * FROM #bottomstates 
ORDER BY bottomstates 


---Displaying the Top and Bottom 3 states' Sex Ratio

SELECT * FROM(
SELECT TOP(3) * FROM #topstates 
ORDER BY topstates DESC) A 

UNION

SELECT * FROM(
SELECT TOP(3) * FROM #bottomstates 
ORDER BY bottomstates 
) B



----------- Lets Display top n Districts in terms of Literacy from each state (we use Window)
select * from 
(SELECT District,state,rank() over(partition by state Order by Literacy desc ) As Rnk from PortfolioProject..Indian_census_Dataset_1) a  
where Rnk in (1,2,3)
Order By state

/*
Some Maths/Stats
*/

------------ Joining Tables
SELECT a.District,a.state,a.Sex_ratio,b.population 
FROM PortfolioProject..Indian_census_Dataset_1 a
INNER JOIN PortfolioProject..Indian_census_Dataset_2 b
ON a.District = b.District


------ Lets Calculate Males and Females Count

SELECT c.district,c.state, ROUND(c.population/((c.sex_ratio) +1.0),0) as males ,
ROUND((c.population)*(1-1/(c.sex_ratio+1)),0) as females
from (SELECT a.District,a.state,convert(float,a.Sex_ratio)/1000 Sex_Ratio,b.population 
FROM PortfolioProject..Indian_census_Dataset_1 as a
INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
ON a.District = b.District) as c




--------- Lets Calculate Population Statewise based on Gender

SELECT d.state,SUM(d.males) TotalMales,SUM(d.females) TotalFemales FROM (	SELECT c.district,c.state, ROUND(c.population/((c.sex_ratio) +1.0),0) as males ,
ROUND((c.population)*(1-1/(c.sex_ratio+1)),0) as females
from (SELECT a.District,a.state,convert(float,a.Sex_ratio)/1000 Sex_Ratio,b.population 
FROM PortfolioProject..Indian_census_Dataset_1 as a
INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
ON a.District = b.District) as c ) d 
GROUP BY d.state


----------- Lets calculate Literacy rate
SELECT c.District,c.state,ROUND(convert(float,c.Literacy_Ratio)*c.population,0) AS 'Literate Count',
ROUND((1-convert(float,c.Literacy_ratio))*c.population,0) AS 'Illiterate Count'

FROM (SELECT a.District,a.state,convert(float,a.Literacy)/100 Literacy_Ratio,b.population 
FROM PortfolioProject..Indian_census_Dataset_1 as a
INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
ON a.District = b.District) c




------------- Lets Carry Out Above Query for States

SELECT d.state,SUM(d.Literate_Count) AS 'Literate People',SUM(d.Illiterate_Count) AS 'Illiterate People'
FROM (SELECT c.District,c.state,ROUND(convert(float,c.Literacy_Ratio)*c.population,0) AS Literate_Count,
	  ROUND((1-convert(float,c.Literacy_ratio))*c.population,0) AS Illiterate_Count
	  FROM (SELECT a.District,a.state,convert(float,a.Literacy)/100 Literacy_Ratio,b.population 
	  FROM PortfolioProject..Indian_census_Dataset_1 as a
	  INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
	  ON a.District = b.District) c) d
GROUP BY d.state



----------- Getting Population of the Previous Census

SELECT c.District,c.state,c.population AS 'PRESENT POPULATION (2011)',ROUND(c.population/(1+c.Growth),0) AS 'PREVIOUS POPULATION (2001)'
FROM
	(SELECT a.District,a.state,convert(float,a.Growth) AS Growth,b.population 
	  FROM PortfolioProject..Indian_census_Dataset_1 as a
	  INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
	  ON a.District = b.District) c

------------- Lets Carry Out Above Query for States

select d.state,SUM(CAST(d.PREVIOUS_CENSUS AS NUMERIC)) 'PREVIOUS CENSUS',SUM(CAST(d.PRESENT_CENSUS AS NUMERIC)) 'CURRENT CENSUS'
FROM
(SELECT c.District,c.state,c.population AS PRESENT_CENSUS,ROUND(c.population/(1+c.Growth),0) AS PREVIOUS_CENSUS
FROM
	(SELECT a.District,a.state,convert(float,a.Growth) AS Growth,b.population 
	  FROM PortfolioProject..Indian_census_Dataset_1 as a
	  INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
	  ON a.District = b.District) c) d
GROUP BY d.state



----------Population of India in Current Census and in Previous Census

select SUM(e.PREVIOUS_CENSUS) AS 'Population of India 2001',SUM(e.CURRENT_CENSUS) AS 'Population Of India 2011'
FROM
(select d.state,SUM(CAST(d.PREVIOUS_CENSUS AS NUMERIC)) PREVIOUS_CENSUS,SUM(CAST(d.PRESENT_CENSUS AS NUMERIC)) CURRENT_CENSUS
FROM
(SELECT c.District,c.state,c.population AS PRESENT_CENSUS,ROUND(c.population/(1+c.Growth),0) AS PREVIOUS_CENSUS
FROM
	(SELECT a.District,a.state,convert(float,a.Growth) AS Growth,b.population 
	  FROM PortfolioProject..Indian_census_Dataset_1 as a
	  INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
	  ON a.District = b.District) c) d
GROUP BY d.state) e



---------- Density Of Population (Number of people per sq.km)
---- Density of India 2001 vs 2011

SELECT Round(j.Population_of_India_2001/Area_km2,0) AS 'Poplation Density 2001',Round(j.Population_of_India_2011/Area_km2,0) AS 'Population Density 2011'
From
(SELECT H.*,i.area_km2 from
(select '1' as SlNo,f.Population_of_India_2001,f.Population_of_India_2011 
From
(select SUM(e.PREVIOUS_CENSUS) AS Population_of_India_2001,SUM(e.CURRENT_CENSUS) AS Population_Of_India_2011
FROM
(select d.state,SUM(CAST(d.PREVIOUS_CENSUS AS NUMERIC)) PREVIOUS_CENSUS,SUM(CAST(d.PRESENT_CENSUS AS NUMERIC)) CURRENT_CENSUS
FROM
(SELECT c.District,c.state,c.population AS PRESENT_CENSUS,ROUND(c.population/(1+c.Growth),0) AS PREVIOUS_CENSUS
FROM
	(SELECT a.District,a.state,convert(float,a.Growth) AS Growth,b.population 
	  FROM PortfolioProject..Indian_census_Dataset_1 as a
	  INNER JOIN PortfolioProject..Indian_census_Dataset_2 as b
	  ON a.District = b.District) c) d
GROUP BY d.state) e ) f ) h inner join 

(select '1' as SlNo,g.area_km2 From(
SELECT sum(convert(int,area_km2)) Area_km2 FROM PortfolioProject..Indian_census_Dataset_2) g) i 
ON h.SlNo = i.SlNo) j




----------