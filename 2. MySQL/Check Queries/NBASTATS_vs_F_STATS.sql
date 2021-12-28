select dategame, Player, teamid, oppid, sum(stg), sum(edwp), sum(stg-edwp) from 
(
	select dategame, 
			Player, 
			case 
				when teamid = 'BRK' then 'BKN'
				when TeamID = 'CHO' then 'CHA'
				when teamid = 'PHO' then 'PHX'
				else teamid
			end TeamID,
			case 
				when oppid = 'BRK' then 'BKN'
				when oppid = 'CHO' then 'CHA'
				when oppid = 'PHO' then 'PHX'
				else oppid
			end oppid,
			pts stg, 
			0 edwp 
	from stg.nbastats
	union all
	select  gamedate dategame, 
			Player, 
			teamid, 
			opponentid oppid, 
			0 stg, 
			pts edwp 
	from edwp.f_stats
)t
group by dategame, Player, teamid, oppid
having sum(stg-edwp)<>0
into outfile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NBASTATS_vs_F_STATS.csv'
fields terminated by ';'
lines terminated by '\n'
;