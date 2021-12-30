insert into edwp.d_calendar (GameDate, Home, Visitor, DunkestGameID, SeasonID, InsertDate, UpdateDate)
select *
from(
	select 
		nba.GameDate,
		nba.Home,
		nba.Visitor,
		coalesce(dun.DunGameDate,-1) DunkestGameID,
		coalesce(par.SeasonID,-1) SeasonID,
        curdate() ins,
        curdate() upd
	from 
				(select 																		
					str_to_date(GameDate, '%Y-%m-%d') as GameDate,
					trim(Visitor) as Visitor,
					trim(Home) as Home,
					case 
						when HomeWin = 'True' then 1
						when HomeWin = 'False' then 0
						else -1
					end HomeWin
				from stg.nbacalendar) nba
		left join 
				(select 
					  trim(h.abbreviation) visitor
					, trim(v.abbreviation) home
					, case    
						when str_to_date(Date,'%d/%m') between '0000-01-01' and '0000-08-30' then str_to_date(concat(convert(year(sysdate())+1,char),Date), '%Y%d/%m')   
						else str_to_date(concat(convert(year(sysdate()),char),Date), '%Y%d/%m') 
					  end GameDate
					, case    
						when str_to_date(Date,'%d/%m') between '0000-01-01' and '0000-08-30' then year(sysdate())-1
						else year(sysdate())
					  end SeasonID
					, cast(replace(trim(DunGameDate), 'Giornata','') as signed) DunGameDate
				from stg.duncalendar d
					inner join stg.teams h
						on h.full_name = d.Home
					inner join stg.teams v
						on v.full_name = d.visitor
				order by GameDate, DunGameDate) dun
		on 		nba.GameDate between date_add(dun.GameDate, interval -1 day) and dun.GameDate
			and nba.Home = dun.Home
			and nba.Visitor = dun.Visitor
		inner join
			(select cast(seasonID as signed) seasonID,
					str_to_date(start,'%d/%m/%Y') as Start,
					str_to_date(end,'%d/%m/%Y') as End
			 from stg.par_season
			) par
		on nba.GameDate between par.start and par.end
	order by GameDate) t
    
on duplicate key update
	updatedate = curdate();
	