insert into edwp.d_player(SeasonID, Name, LastName, DotName, FirstYr, LastYr, Position, Height, Weight, BirthDate, College, ContractValue,InsertDate,UpdateDate)
select * from	
    (select t.*, coalesce(hook.contractvalue,'ND') contractvalue, curdate() ins, curdate() upd from 
				(select distinct  																
						p.seasonid,
						substring_index(n.player, ' ',1) Name,
						replace(n.player, concat(substring_index(n.player,' ',1),' '),'') LastName,
						concat(left(substring_index(n.player, ' ',1),1),'. ', replace(n.player, concat(substring_index(n.player,' ',1),' '),'')) DotName,
						cast(year_min as signed) FirstYr,
						cast(year_max as signed) LastYr,
						pos Position,
						cast(replace(Height,'-','.') as decimal(3,2)) Height,
						cast(Weight as signed) Weight,
						str_to_date(birth_date, '%M %e, %Y') birthdate,
						colleges College
				from 	stg.nbaplayers n													
					inner join stg.par_season p
						on cast(p.seasonID as signed) between n.year_min-1 and n.year_max-1)t 			# define a player career either up-to-date (if currently playing) or the whole playing period 
		left join 
				(select nba, t.contract, c.contract ContractValue, year, dist 
				from 
					(select * from 
						(select *, rank() over(partition by nba order by dist) rnk
						from pw0_distance)a
						where rnk = 1 and ((dist = 7  and contract = 'BJ Boston') or dist <> 7)
					  )t
				inner join stg.contracts c																# attach per year contracts value for each single player
					on 	c.player = t.contract) hook
		on 	concat(t.name,' ',t.lastname) = hook.nba
			and t.seasonID = hook.year)t
on duplicate key update
	updatedate = curdate(),
    contractvalue = t.contractvalue
	;
    
