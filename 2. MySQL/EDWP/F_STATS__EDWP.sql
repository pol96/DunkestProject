insert into edwp.f_stat(GameId,gamedate,seasonid,DunWeek,player,PlayerID,TeamID,OpponentID,GameLocation,GameResult,AgeDays,AgeYr,Credits,
						 PDK,Sec,Min,FGM,FGA,P3M,P3A,FTM,FTA,OREB,DREB,AST,STL,BLK,TOV,Fouls,PTS,GameScore,PlusMinus,InsertDate,UpdateDate)                        
	select * from
			(select 	
				  c.GameId,
				  c.gamedate,
				  c.SeasonID,
				  coalesce(cast(t2.week as signed),-1) DunWeek,
				  t1.player,
				  coalesce(t1.PlayerID,-1) PlayerID,
				  t1.TeamID,
				  t1.OpponentID,
				  t1.GameLocation,
				  t1.GameResult,
				  cast(t1.AgeDays as signed) AgeDays,
				  cast(t1.AgeYr as signed) AgeYr,
				  case 
					when left(plus,1) = '+' then cast(trim(replace(plus,'+','')) as decimal(6,1)) 
					when left(plus,1) = '−' then cast(trim(substr(plus,2,length(plus))) as decimal(6,1)) * (-1)
					else 0.0
				  end Credits,
				  coalesce(cast(t2.pdk as decimal(6,1)),99.0) PDK,
				  t1.Sec,
				  t1.Min,
				  t1.FGM,
				  t1.FGA,
				  t1.P3M,
				  t1.P3A,
				  t1.FTM,
				  t1.FTA,
				  t1.OREB,
				  t1.DREB,
				  t1.AST,
				  t1.STL,
				  t1.BLK,
				  t1.TOV,
				  t1.pf Fouls,
				  t1.PTS,
				  t1.GameScore,
				  t1.PlusMinus,
                  curdate() ins,
                  curdate() upd
			from
					(select 
						p.playerid,
						p.DotName,
						player,
						p.position,
						str_to_date(dategame, '%Y-%m-%d') GameDate,
						s.seasonid,
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
						case when gamelocation = '@' then 'Visit' else 'Home' end GameLocation,
						cast(trim(replace(substring_index(trim(gameresult),'(',-1),')','')) as signed) GameResult,
						cast(substring_index(trim(age),'-',1)*365 + substring_index(age,'-',-1) as signed) AgeDays,
						cast(floor((substring_index(trim(age),'-',1)*365 + substring_index(age,'-',-1))/365) as signed) AgeYr,
						case when mp <> '' then cast(substring_index(trim(mp),':',1)*60+substring_index(mp,':',-1) as signed) else 0 end Sec,
						coalesce(mp,'ND') as Min,
						case when fgm = '' then 0 else cast(format(fgm,0) as signed) end FGM,
						case when fga = '' then 0 else cast(format(fga,0) as signed) end FGA,
						case when p3m = '' then 0 else cast(format(p3m,0) as signed) end P3M,
						case when p3a = '' then 0 else cast(format(p3a,0) as signed) end P3A,
						case when ftm = '' then 0 else cast(format(ftm,0) as signed) end FTM,
						case when fta = '' then 0 else cast(format(fta,0) as signed) end FTA,
						case when orb = '' then 0 else cast(format(orb,0) as signed) end OREB,
						case when drb = '' then 0 else cast(format(drb,0) as signed) end DREB,
						case when ast = '' then 0 else cast(format(ast,0) as signed) end AST,
						case when stl = '' then 0 else cast(format(stl,0) as signed) end STL,
						case when blk = '' then 0 else cast(format(blk,0) as signed) end BLK,
						case when tov = '' then 0 else cast(format(tov,0) as signed) end TOV,
						case when pf = '' then 0 else cast(format(pf,0) as signed) end PF,
						case when pts = '' then 0 else cast(format(pts,0) as signed) end PTS,
						case when GameScore = '' then 0.0 else cast(trim(GameScore) as decimal(6,1)) end GameScore,
						case when PlusMinus = '' then 0 else cast(trim(format(PlusMinus,0)) as signed) end PlusMinus
					from stg.nbastats n
						inner join stg.par_season s
						on str_to_date(n.dategame, '%Y-%m-%d') between str_to_date(s.start,'%d/%m/%Y') and str_to_date(s.end,'%d/%m/%Y')
						left join edwp.d_player p
						on  concat(p.Name,' ',p.LastName) = n.player 
							and s.seasonid = p.seasonID) t1
			inner join edwp.d_calendar c 
				on c.gamedate = t1.gamedate
				   and case when gamelocation = 'Visit' then c.home = t1.opponentid and c.visitor = t1.teamid else c.home = t1.teamid and c.visitor = t1.opponentid end
			left join 
					(select
						 Player,
						 Team,
						 cast(format(PTS,0) as signed) as  PTS,
						 cast(format(AST,0) as signed) as  AST,
						 cast(format(OREB,0) as signed) as  OREB,
						 cast(format(DREB,0) as signed) as  DREB,
						 cast(Week as signed) as  Week,
						 GameID,
						 GameDate,
						 Home,
						 Visitor,
						 DunkestGameID,
						 SeasonID,
						 case 
							when left(plus,1) = '+' then cast(trim(replace(plus,'+','')) as decimal(6,1)) 
							when left(plus,1) = '−' then cast(trim(substr(plus,2,length(plus))) as decimal(6,1)) * (-1)
							else 0.0
						 end plus,
						 coalesce(cast(pdk as decimal(4,1)),99.0) PDK
					from stg.dunstats d
								inner join edwp.d_calendar c
									on ((d.team = c.home) or (d.team = c.visitor)) and c.dunkestgameid = d.week) t2
			on  t1.gamedate = t2.gamedate
				and case 
						when t1.GameLocation = 'Home' then t1.teamid = t2.home and t1.opponentid = t2.visitor
						else t1.teamid = t2.visitor and t1.opponentid = t2.home
					end 
				and t1.dotname = t2.player
				and t1.pts = cast(t2.pts as signed)
				and t1.ast = cast(t2.ast as signed)
				and t1.oreb = cast(t2.oreb as signed)
				and t1.dreb = cast(t2.dreb as signed))t
on duplicate key update
	updatedate = curdate()
;