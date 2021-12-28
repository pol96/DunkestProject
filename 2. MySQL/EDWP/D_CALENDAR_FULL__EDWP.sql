### for games before 2015 (no historical data are available in NBA JSON api)
insert into edwp.d_calendar (GameDate, Home, Visitor, DunkestGameID, SeasonID, InsertDate, UpdateDate) 
select distinct
	dt,
    case when gamelocation = '@' then opponentid else teamid end home,
    case when gamelocation <> '@' then opponentid else teamid end visitor,
    dunkestgameid,
    seasonid,
    ins,
    upd
from(
select distinct
		str_to_date(n.dategame,'%Y-%m-%d') dt,
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
		end OpponentID,
        gamelocation,
		-1 dunkestgameid,
		seasonid,
		curdate() ins,
		curdate() upd
	from stg.nbastats n
		inner join stg.par_season p
			on str_to_date(n.dategame,'%Y-%m-%d') between str_to_date(start,'%d/%m/%Y') and str_to_date(end,'%d/%m/%Y')
	where p.seasonID<2015)t
on duplicate key update 
	updatedate = sysdate();