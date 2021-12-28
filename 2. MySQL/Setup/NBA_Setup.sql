/* ******************************** STG  ******************************** */
create table stg.Contracts (
	player varchar(100),
    contract varchar(100),
    year varchar(100)
);
create table stg.NBAplayers (
	player varchar(100),
    url varchar(250),
    year_min varchar(100),
    year_max varchar(100),
    pos varchar(100),
    height varchar(100),
    weight varchar(100),
    birth_date varchar(100),
    colleges varchar(100)
);
create table stg.Teams (
	id varchar(100),
    full_name varchar(100),
    abbreviation varchar(100),
    nickname varchar(100),
    city varchar(100),
    state varchar(100),
    year_founded varchar(100)
);
create table stg.NBAcalendar(
	GameDate varchar(100),
    GameID varchar(100),
    Visitor varchar(100),
    Home varchar(100),
    HomeWin varchar(100)
);
create table stg.DUNcalendar(
	Home varchar(100),
    Visitor varchar(100),
    Date varchar(100),
    DunGameDate varchar(100)
);
create table stg.DUNstats(
	Player varchar(100),
    Role varchar(100),
    Team varchar(100),
    PDK varchar(100),
    CR varchar(100),
    PLUS varchar(100),
    GP varchar(100),
    MIN varchar(100),
    ST varchar(100),
    PTS varchar(100),
    REB varchar(100),
    AST varchar(100),
    STL varchar(100),
    BLK varchar(100),
    BA varchar(100),
    FGM varchar(100),
    FGA varchar(100),
    FGperc varchar(100),
    P3M varchar(100),
    P3A varchar(100),
    P3perc varchar(100),
    FTM varchar(100),
    FTA varchar(100),
    FTperc varchar(100),
    OREB varchar(100),
    DREB varchar(100),
    TOV varchar(100),
    PF varchar(100),
    PlusMinus varchar(100),
    Week varchar(100)
);
create table stg.NBAstats(
	GameSeason varchar(100),
	DateGame varchar(100),
	Age varchar(100),
	TeamID varchar(100),
	GameLocation varchar(100),
	OppID varchar(100),
    GameResult varchar(100),
    GS varchar(100),
    MP varchar(100),
    FGM varchar(100),
    FGA varchar(100),
    FGperc varchar(100),
    P3M varchar(100),
    P3A varchar(100),
    P3perc varchar(100),
    FTM varchar(100),
    FTA varchar(100),
    FTperc varchar(100),
    ORB varchar(100),
    DRB varchar(100),
    TRB varchar(100),
    AST varchar(100),
    STL varchar(100),
    BLK varchar(100),
    TOV varchar(100),
    PF varchar(100),
    PTS varchar(100),
    GameScore varchar(100),
    PlusMinus varchar(100),
    Player varchar(100)
);
create table stg.par_season(
	seasonID varchar(100),
    start varchar(100),
    end varchar(100));
create table stg.pw0_distance(
	nba varchar(50),
    contract varchar(50),
    dist int);
DELIMITER $$
CREATE FUNCTION levenshtein( s1 VARCHAR(255), s2 VARCHAR(255) )
    RETURNS INT
    DETERMINISTIC
    BEGIN
        DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT;
        DECLARE s1_char CHAR;
        -- max strlen=255
        DECLARE cv0, cv1 VARBINARY(256);

        SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0;

        IF s1 = s2 THEN
            RETURN 0;
        ELSEIF s1_len = 0 THEN
            RETURN s2_len;
        ELSEIF s2_len = 0 THEN
            RETURN s1_len;
        ELSE
            WHILE j <= s2_len DO
                SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1;
            END WHILE;
            WHILE i <= s1_len DO
                SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = UNHEX(HEX(i)), j = 1;
                WHILE j <= s2_len DO
                    SET c = c + 1;
                    IF s1_char = SUBSTRING(s2, j, 1) THEN
                        SET cost = 0; ELSE SET cost = 1;
                    END IF;
                    SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost;
                    IF c > c_temp THEN SET c = c_temp; END IF;
                    SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1;
                    IF c > c_temp THEN
                        SET c = c_temp;
                    END IF;
                    SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1;
                END WHILE;
                SET cv1 = cv0, i = i + 1;
            END WHILE;
        END IF;
        RETURN c;
    END$$
DELIMITER ;

/* ******************************** EDWP  ******************************** */
create table edwp.d_calendar(
	GameID int not null auto_increment primary key,
    GameDate Date,
    Home varchar(3),
    Visitor varchar(3),
    DunkestGameID INT,
    SeasonID INT,
    InsertDate date,
    UpdateDate date,
    unique (GameDate, Home, Visitor)
);
create table edwp.d_teams(
	TeamID varchar(3) not null primary key,
    FullName varchar(50),
    NickName varchar(50),
    City varchar(50),
    State varchar(20),
    FoundationYr int,
	InsertDate date,
    UpdateDate date,
    unique (TeamID, FullName, NickName)
);
create table edwp.d_player(
	PlayerID int not null auto_increment primary key,
    SeasonID int,
    Name varchar(30),
    LastName varchar(30),
    DotName varchar(30),
    FirstYr int,
    LastYr int,
    Position varchar(5),
    Height int,
    Weight int,
    BirthDate date,
    College varchar(100),
    ContractValue varchar(15),
    InsertDate date,
    UpdateDate date,
    unique(SeasonID, Name, LastName, FirstYr)
);
create table edwp.f_stats(
	StatID int not null auto_increment primary key,
	GameID int not null,
	GameDate date,
	SeasonID varchar(4) not null,
	DunWeek int,
	Player varchar(50),
	PlayerID int not null,
	TeamID varchar(3) not null,
	OpponentID varchar(3),
	GameLocation varchar(5),
	GameResult int,
	AgeDays int,
	AgeYr int,
	Credits decimal(6,1),
	PDK decimal(6,1),
	Sec int,
	Min varchar(8),
	FGM int,
	FGA int,
	P3M int,
	P3A int,
	FTM int,
	FTA int,
	OREB int,
	DREB int,
	AST int,
	STL int,
	BLK int,
	TOV int,
	Fouls int,
	PTS int,
	GameScore decimal(6,1),
	PlusMinus int, 
    InsertDate date,
    UpdateDate date,
unique(GameID,SeasonID,PlayerID,TeamID));