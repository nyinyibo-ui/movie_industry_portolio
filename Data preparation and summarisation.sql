
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

---Q3. WHAT FACTORS CAN MAKE A MOVIE ACCQUIRE HIGHER IMDb
WITH good_cte AS 
(
SELECT score, AVG(avg(runtime)) OVER(PARTITION BY score) avg_runtime,rating,count(rating) count_rating,
ROW_NUMBER() over (PARTITION BY score ORDER BY count(rating)  DESC) as  row_num
FROM movies$
GROUP BY rating,score
),  good1 as 
(
SELECT score,genre,count(genre) count_rating,
ROW_NUMBER() over (PARTITION BY score ORDER BY count(genre)  DESC) as  row_num
FROM movies$
GROUP BY genre,score
), good2 as
(
SELECT score,company,count(company) count_rating,
ROW_NUMBER() over (PARTITION BY score ORDER BY count(company)  DESC) as  row_num
FROM movies$
GROUP BY company,score
) 
SELECT good_cte.score,avg_runtime,rating,genre ,company
FROM good_cte
LEFT JOIN good1 ON
good_cte.score=good1.score
LEFT JOIN good2 ON
good_cte.score=good2.score
WHERE good_cte.row_num=1 and good1.row_num=1 and good2.row_num=1
ORDER BY 1 DESC;











