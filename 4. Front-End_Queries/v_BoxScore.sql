select 
    c.GameDate,
    c.Home,
    c.Visitor,
    coalesce(b.hpts,0) hPTS,
    coalesce(b.vpts,0) vPTS
from edwp.d_calendar c
	left join edwp.team_boxscore b
		on c.GameDate = b.GameDate
		and c.Home = b.Home
        and c.Visitor = b.Visitor
order by GameDate desc;