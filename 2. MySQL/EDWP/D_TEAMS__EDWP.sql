insert into edwp.d_teams(teamid, fullname, nickname, city, state, foundationyr, insertdate, updatedate)
select * from 
	(select 
		abbreviation TeamID,
		full_name FullName,
		nickname,
		city,
		state,
		cast(year_founded as signed) FoundationYr,
		curdate() ins,
		curdate() upd
	from stg.teams)t
    on duplicate key update
		fullname = t.fullname,
        nickname = t.nickname,
        city = t.city,
        state = t.state,
        foundationyr = t.foundationyr,
        updatedate = curdate()
;