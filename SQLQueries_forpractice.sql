create table olympics_history
(
	id		INT,
	name 	VARCHAR,
	sex		VARCHAR,
	age		VARCHAR,
	height	VARCHAR,
	weight	VARCHAR,
	team	VARCHAR,
	noc		VARCHAR,
	games	VARCHAR,
	year	INT,
	season	VARCHAR,
	city	VARCHAR,
	event	VARCHAR,
	medal	VARCHAR
);

create table olympics_history_noc_regions
(
	noc		VARCHAR,
	region	VARCHAR,
	notes	VARCHAR
);


/*Identify the sport which was played in a summer olympic*/
select * from olympics_history;

with t1 as
	(select count(distinct games) as total_summer_games 
	 from olympics_history
	where season = 'Summer'),
t2 as
	(select distinct sport, games
	from olympics_history
	where season = 'Summer' order by games),
t3 as
	(select sport, count(games) as no_of_games
	from t2
	group by sport)
select *
from t3
join t1 on t1.total_summer_games = t3.no_of_games;

/*Fetch the top 5 athletes who have won the most gold medals*/
with t1 as
	(select name, count(1) as total_medals
	from olympics_history
	where medal = 'Gold'
	group by name
	order by count(1) desc),
t2 as
	(select *, dense_rank() over(order by total_medals desc) as rnk
	from t1)
select *
from t2
where rnk <=5;

/*List down total gold, silver and bronze medals won by each country.*/
select nr.region as country, medal, count(1) as total_medals
from olympics_history oh
join olympics_history_noc_regions nr on nr.noc = oh.noc
where medal <> 'NA'
group by nr.region, medal
order by nr.region, medal

create extension tablefunc /*used to create crosstab*/

select country,
 coalesce(gold, 0) as gold
, coalesce(silver, 0) as silver
, coalesce(bronze, 0) as bronze
from crosstab('select nr.region as country, medal, count(1) as total_medals
			from olympics_history oh
			join olympics_history_noc_regions nr on nr.noc = oh.noc
			where medal <> ''NA''
			group by nr.region, medal
			order by nr.region, medal',
			 'values (''Bronze''), (''Gold''), (''Silver'')')
		as result(country varchar, bronze bigint, gold bigint, silver bigint)
order by gold desc, silver desc, bronze desc;

/*Identify which country won the most gold, most silver and most bronze medals in each olympic games*/
with temp as
	(select substring(games_country, 1, position(' - ' in games_country) - 1) as games
	, substring(games_country, position(' - ' in games_country) + 3) as country
	, coalesce(gold, 0) as gold
	, coalesce(silver, 0) as silver
	, coalesce(bronze, 0) as bronze
	from crosstab('select concat(games,'' - '', nr.region) as games_country, medal, count(1) as total_medals
				from olympics_history oh
				join olympics_history_noc_regions nr on nr.noc = oh.noc
				where medal <> ''NA''
				group by games, nr.region, medal
				order by games, nr.region, medal',
				 'values (''Bronze''), (''Gold''), (''Silver'')')
			as result(games_country varchar, bronze bigint, gold bigint, silver bigint)
	order by games_country)
select distinct games
, concat(first_value(country) over(partition by games order by gold desc)
	, ' - '
	, first_value(gold) over(partition by games order by gold desc)) as gold
, concat(first_value(country) over(partition by games order by silver desc)
	, ' - '
	, first_value(silver) over(partition by games order by silver desc)) as silver
, concat(first_value(country) over(partition by games order by bronze desc)
	, ' - '
	, first_value(bronze) over(partition by games order by bronze desc)) as bronze
from temp
order by games;












