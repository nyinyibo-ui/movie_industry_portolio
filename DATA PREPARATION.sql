
SELECT * FROM movies$
--CREATE PROFIT COLUMN
SELECT name,budget,gross, (gross-budget) profit from movies$
ORDER BY score, name;