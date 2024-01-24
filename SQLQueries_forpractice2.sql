select * from olympics_history
select * from olympics_history_noc_regions

/*SQL query to find the total no of olympic games held*/
select count(distinct games) as total_olympic_games
from olympics_history

/*SQL query to list down all the Olympic Games held so far*/
select distinct oh.year, oh.season, oh.city
from olympics_history oh
order by year;

/*SQL query to fetch total no of countries participated in each olympic games.*/
with all_countries AS
	(select games, nr.region
	from olympics_history oh
	join olympics_history_noc_regions nr on nr.noc = oh.noc
	group by games, nr.region
	order by games, region)
select games, count(1) as total_Countries
from all_Countries
group by games
order by games

/*SQL query to return the Olympic Games which has the 
highest participating countries and the lowest participating countries*/

with t1 AS
	(select games, nr.region
	from olympics_history oh
	join olympics_history_noc_regions nr on nr.noc = oh.noc
	group by games, nr.region
	 ),
t2 as	
	(select games, count(1) as total_countries
	from t1
	group by games
	)
select distinct
concat(first_Value(games) over(order by total_countries), ' - '
	   , first_value(total_Countries) over(order by total_countries)) as Lowest_Countries,
concat(first_value(games) over(order by total_countries desc), ' - '
	  , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
from t2
order by 1

/*SQL query to return the list of countries who have been part of every Olympics games*/
with t1 AS
	(select games, nr.region
	from olympics_history oh
	join olympics_history_noc_regions nr on nr.noc = oh.noc
	group by games, nr.region),
t2 as 
	(select region as country, count(1) as total_participated_games
	from t1
	group by region),
t3 as
	(select count(distinct games) as total_olympic_games
	from olympics_history)
select country, total_participated_games
from t2
join t3 on t3.total_olympic_games = t2.total_participated_games
order by country

/*SQL query to fetch the list of all sports which were just played once in all of olympics*/
with t1 as
	(select distinct sport, games
	from olympics_history
	order by games)
, t2 as 
	(select sport, count(games) as no_of_games
	from t1
	group by sport)
select t2.*, t1.games
from t2
join t1 on t1.sport = t2.sport 
where t2.no_of_games = 1
order by sport







