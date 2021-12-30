select 
    s.SeasonID,
    c.GameDate,
    c.DunkestGameID,
    s.TeamID,
    s.OpponentID,
    case when GameLocation = 'Visit' then o.City else t.City end GameCity,
    case when GameLocation = 'Visit' then o.State else t.State end GameState,
    p.Name,
    p.LastName,
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
    round(r.GameScore,1) GameScore
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
order by s.GameID desc, s.TeamID
;