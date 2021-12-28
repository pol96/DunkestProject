insert into stg.pw0_distance(nba, contract, dist)

	select  a.player nba, 
			b.player contract, 
			levenshtein(a.player, b.player) dist
	from 
		(select distinct player from nbaplayers) a
	cross join 
		(select distinct player from contracts) b
	where levenshtein(a.player, b.player) <=8
;