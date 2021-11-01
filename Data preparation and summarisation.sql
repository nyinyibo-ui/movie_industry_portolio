
SELECT * FROM movies$
--CREATE BOX_OFFICE COLUMN
SELECT name,budget,gross,
CASE 
	WHEN gross<=budget THEN 'box-office-flop'
	ELSE 'box-office-hit'
END box_office
from movies$
ORDER BY score, name;

ALTER TABLE movies$
ADD box_office VARCHAR(550);

UPDATE movies$
SET box_office=
CASE 
	WHEN gross<=budget THEN 'box-office-flop'
	ELSE 'box-office-hit'
END 
from movies$;

--CREATE ERA COLUMN
select name,YEAR(released_date),
CASE 
	WHEN YEAR(released_date)>1990 THEN 'new'
	ELSE 'old'
END era
from movies$
ORDEr BY 2;

ALTER TABLE movies$
ADD era VARCHAR(300);

UPDATE movies$ SET era=(CASE 	WHEN YEAR(released_date)>1990 THEN 'new' 	ELSE 'old'END) FROM movies$;

-----------SUMMARY SQL-------------
---Q1. WHICH GENRES ARE MORE LIKELY HAVE HIGHER IMDB SCORE ,VOTES AND AVERAGE RUNTIME---
SELECT genre,avg(score) avg_imdb_score,avg(votes) avg_votes,
avg(runtime) avg_time from movies$
GROUP BY genre
ORDER BY 2 DESC;

---Q2. IS OLD MOVIE WAS LONGER THAN MODERN MOVIES AND DO THEY LIKELY TO HAVE HIGHER IMDb SCORE---
SELECT era,
avg(runtime) avg_time,max(runtime) max_runtime, min(runtime) min_runtime,
avg(score) avg_score
from movies$
GROUP BY era
ORDER BY 2 DESC;

---WHICH PRODUCTION COMPANIES ARE THE BEST FROM THE PRESPECTIVE OF BOX OFFICE---
SELECT m1.company,hit_count,flop_count,
CASE 
	WHEN flop_count is not null THEN hit_count+flop_count 
	ELSE hit_count
end total_movies
FROM	
(SELECT company,count(company) hit_count
FROM movies$
WHERE box_office='box-office-hit'
GROUP BY company) as m1
LEFT JOIN 
(SELECT company,count(company) flop_count
FROM movies$
WHERE box_office='box-office-flop'
GROUP BY company) as m2
ON m1.company=m2.company
ORDER BY 2 DESC;


---Q3. AVERAGE BUDGET SPENT AND PROFIT GROSS GAINDED FOR A MOVE BY A COUNTY---
select released_country,avg(budget) avg_budget,AVG(gross) avg_gross from movies$
GROUP BY released_country
ORDER BY 2 DESC, 3 DESC ;


