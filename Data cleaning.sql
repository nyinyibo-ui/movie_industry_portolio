SELECT * FROM movies$
ORDER BY score,name;

-- DATA Cleaning and Preparation
--SPLIT RELEASED INTO RELEASED DATE AND PLACE and drop released column
SELECT *,SUBSTRING(released,1,CHARINDEX('(',released)-1) released_date ,
SUBSTRING(released,CHARINDEX('(',released),len(released)) released_country
FROM movies$;

ALTER TABLE movies$
ADD released_date NVARCHAR(550);

UPDATE movies$
set released_date=
SUBSTRING(released,1,CHARINDEX('(',released)-1) 
FROM movies$

ALTER TABLE movies$
ADD released_country NVARCHAR(550);

UPDATE movies$
set released_country=
SUBSTRING(released,CHARINDEX('(',released),len(released)-2)
FROM movies$;

UPDATE movies$
set released_country=
SUBSTRING(released_country,2,len(released_country)-2)
FROM movies$;

ALTER TABLE movies$
DROP COLUMN released;


--CHECK wether the released_country values and country values are different 
SELECT year,released,country,released_country FROM movies$
where released_country<>country;

UPDATE movies$
SET released_country=country
FROM movies$
WHERE released_country<>country;

--SELECT ROWS WITH UNMATCHED RELEASED_DATE AND YEAR and update the column
SELECT name,year,released_date FROM movies$
WHERE CONVERT(FLOAT,YEAR(released_date))<>year;

SELECT name,year,released_date,year-CONVERT(FLOAT,YEAR(released_date)),DATEADD(YEAR,year-CONVERT(FLOAT,YEAR(released_date)),released_date)
FROM movies$
WHERE CONVERT(FLOAT,YEAR(released_date))<>year;

UPDATE movies$
SET released_date=
DATEADD(YEAR,year-CONVERT(FLOAT,YEAR(released_date)),released_date)
FROM movies$
WHERE CONVERT(FLOAT,YEAR(released_date))<>year;

--DROP UNNESSARY COLUMNS
ALTER TABLE  movies$
DROp COLUMN year;

ALTER TABLE  movies$
DROp COLUMN country;

--CHECK any duplicates
WITH duplicate_CTE AS
(select *,ROW_NUMBER() OVER(
		Partition by name,
					rating,
					genre,
					score,
					director,
					star,
					company
			ORDER BY name
) times FROM movies$
) SELECT * FROM duplicate_CTE WHERE times>1;
-----------no duplicates

--HANDLING MISSING VALUES in budget AND gross COLUMN
---ACCORDING TO GENRE
SELECT genre,AVG(budget),AVG(gross) from movies$
GROUP BY genre
ORDER BY 1;

-----THIS THREE GENRES HAVE BUDGE AS NULL SO THEY BETTER SHOULD BE DELETED
SELECT * FROM movies$
WHERE genre in ('Music','Musical','Sport');

DELETE FROM movies$
WHERE genre in ('Music','Musical','Sport');

--ACCORDING TO IMBs SCORE
SELECT score,AVG(budget),AVG(gross) from movies$
GROUP BY score
ORDER BY 1;

--CREATE CET to replace the null values
With cte As
(
SELECT name,m.score,budget,isnull(budget,avg(budget) OVER(PARTITION BY score)) replaced_budget
,gross, isnull(gross,avg(gross) OVER(PARTITION BY score)) replaced_gross
FROM movies$ m
)
UPDATE cte SET budget=replaced_budget;

With cte As
(
SELECT name,m.score,budget,isnull(budget,avg(budget) OVER(PARTITION BY score)) replaced_budget
,gross, isnull(gross,avg(gross) OVER(PARTITION BY score)) replaced_gross
FROM movies$ m
)
UPDATE cte SET gross=replaced_gross;


----CHECKING FOR NULL---
SELECT * FROM movies$
WHERE budget is null or gross is null;






