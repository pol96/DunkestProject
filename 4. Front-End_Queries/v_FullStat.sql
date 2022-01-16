use edwp;
select 
    SeasonID,
    GameDate,
    DunkestGameID,
    TeamID,
    OpponentID,
    GameCity,
    GameState,
    Player,
    BirthDate,
    Position,
    Height,
    Weight,
    FirstYr,
    ContractValue,
    GameResult,
    Sec,
    PTS,
    OREB,
    DREB,
    AST,
    BLK,
    TOV,
    Fouls,
    PlusMinus,
    TrueShooting,
    UsagePerc,
    OffRating,
    DefRating,
    GameScore,
    case 
		when rank() over (order by team_pts desc) = 1 then 3 + espulso + tripla_doppia + doppia_doppia + pdk_base
        else -3 + espulso + tripla_doppia + doppia_doppia + pdk_base
	end PDK
from
    (select 
        s.SeasonID,
        c.GameDate,
        c.DunkestGameID,
        s.TeamID,
        s.OpponentID,
        case when GameLocation = 'Visit' then o.City else t.City end GameCity,
        case when GameLocation = 'Visit' then o.State else t.State end GameState,
        s.Player,
        p.BirthDate,
        substr(p.Position,1,1) Position,
        round(p.Height*0.3048,2) Height,
        round(p.Weight*0.453592,1) Weight,
        p.FirstYr,
        p.ContractValue,
        s.GameResult,
        s.Sec,
        s.PTS,
        s.OREB,
        s.DREB,
        s.AST,
        s.BLK,
        s.TOV,
        s.Fouls,
        s.PlusMinus,
        r.true_shooting TrueShooting,
        r.usage_perc UsagePerc,
        r.Offensive_rating OffRating,
        coalesce(r.Defensive_rating,0.0000) DefRating,
        round(r.GameScore,1) GameScore,
        pts + dreb + 1.25*oreb + 1.5 * ast + 1.5 * stl + 1.5 * blk - ((fga-fgm) + (fta - ftm)) - 1.5 * tov PDK_base,
        case 
            when (pts > 10 and dreb+oreb > 10) or
                (pts > 10 and ast > 10) or
                (pts > 10 and blk > 10) or
                (pts > 10 and stl > 10) or 
                (dreb+oreb > 10 and ast > 10) or
                (dreb+oreb > 10 and blk > 10) or
                (dreb+oreb > 10 and stl >10) or
                (ast > 10 and blk > 10) or 
                (ast > 10 and stl > 10) or 
                (blk >10 and stl > 10) then 5
            else 0
        end doppia_doppia,
        case 
            when (pts>10 and oreb+dreb>10 and ast>10) or
                (pts>10 and oreb+dreb>10 and blk>10) or
                (pts>10 and oreb+dreb>10 and stl>10) or
                (pts>10 and ast>10 and blk>10) or
                (pts>10 and ast>10 and stl>10) or
                (pts>10 and blk>10 and stl>10) or
                (oreb+dreb>10 and ast>10 and blk>10) or
                (oreb+dreb>10 and ast>10 and stl>10) or
                (oreb+dreb>10 and blk>10 and stl>10) or
                (ast>10 and blk>10 and stl>10) then 20
            else 0
        end tripla_doppia,
        case 
            when fouls >= 5 then -5
            else 0 
        end espulso,
        sum(pts) over (partition by s.gameid, s.teamid) team_pts
    from edwp.f_stat s
        inner join d_calendar c
            on c.GameID = s.GameID
        inner join edwp.d_player p
            on p.PlayerID = s.PlayerID
        inner join edwp.d_teams t
            on s.teamid = t.teamid
        inner join edwp.d_teams o
            on s.OpponentID = o.teamid
        inner join edwp.f_rates r
            on s.PlayerID = r.PlayerID and s.GameID = r.GameID
    order by s.GameID desc, s.TeamID) t
;