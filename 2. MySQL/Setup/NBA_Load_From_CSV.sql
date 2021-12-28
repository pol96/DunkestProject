truncate table stg.contracts;
truncate table stg.duncalendar;
truncate table stg.dunstats;
truncate table stg.nbacalendar;
truncate table stg.nbaplayers;
truncate table stg.nbastats;
truncate table stg.teams;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/contracts.csv'
into table stg.contracts
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Dun_credits.csv'
into table stg.dunstats
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NBA_Active_Players.csv'
into table stg.nbaplayers
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NBA_Players_Stats.csv'
into table stg.nbastats
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Dun_calendar.csv'
into table stg.duncalendar
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/filtered_schedule.csv'
into table stg.nbacalendar
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NBA_Teams.csv'
into table stg.teams
fields terminated by ','
lines terminated by '\r\n'
ignore 1 rows
;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/par_season.csv'
into table stg.par_season
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dist.csv'
into table stg.pw0_distance
fields terminated by ';'
lines terminated by '\r\n'
ignore 1 rows
;

