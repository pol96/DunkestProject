create view edwp.complete_boxscore as 
   SELECT 
        s.SEASONID AS SEASONID,
        s.PlayerID AS PlayerID,
        s.GameID AS GameID,
        s.GAMEDATE AS GAMEDATE,
        s.TeamID AS TEAM,
        round(s.Sec/60,0) AS MIN,
        s.FGM AS FGM,
        s.FGA AS FGA,
        s.P3M AS P3M,
        s.P3A AS P3A,
        s.FTM AS FTM,
        s.FTA AS FTA,
        s.OREB AS OREB,
        s.DREB AS DREB,
        (s.OREB+s.DREB) AS REB,
        s.AST AS AST,
        s.STL AS STL,
        s.BLK AS BLK,
        s.TOV AS TOV,
        s.Fouls AS PF,
        s.PTS AS points,
        s.PLUSMINUS AS PlusMinus,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hPlayerRotation
            ELSE b.vPlayerRotation
        END) AS tPlayerRotation,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hMIN
            ELSE b.vMIN
        END) AS tMIN,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hFGM
            ELSE b.vFGM
        END) AS tFGM,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hFGA
            ELSE b.vFGA
        END) AS tFGA,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hP3M
            ELSE b.vP3M
        END) AS tP3M,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hP3A
            ELSE b.vP3A
        END) AS tP3A,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hFTM
            ELSE b.vFTM
        END) AS tFTM,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hFTA
            ELSE b.vFTA
        END) AS tFTA,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hOREB
            ELSE b.vOREB
        END) AS tOREB,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hDREB
            ELSE b.vDREB
        END) AS tDREB,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hREB
            ELSE b.vREB
        END) AS tREB,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hAST
            ELSE b.vAST
        END) AS tAST,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hSTL
            ELSE b.vSTL
        END) AS tSTL,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hBLK
            ELSE b.vBLK
        END) AS tBLK,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hTOV
            ELSE b.vTOV
        END) AS tTOV,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hPF
            ELSE b.vPF
        END) AS tPF,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hPTS
            ELSE b.vPTS
        END) AS tpoints,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.hPlusMinus
            ELSE b.vPlusMinus
        END) AS tPlusMinus,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vPlayerRotation
            ELSE b.hPlayerRotation
        END) AS opp_PlayerRotation,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vMIN
            ELSE b.hMIN
        END) AS opp_MIN,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vFGM
            ELSE b.hFGM
        END) AS opp_FGM,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vFGA
            ELSE b.hFGA
        END) AS opp_FGA,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vP3M
            ELSE b.hP3M
        END) AS opp_P3M,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vP3A
            ELSE b.hP3A
        END) AS opp_P3A,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vFTM
            ELSE b.hFTM
        END) AS opp_FTM,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vFTA
            ELSE b.hFTA
        END) AS opp_FTA,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vOREB
            ELSE b.hOREB
        END) AS opp_OREB,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vDREB
            ELSE b.hDREB
        END) AS opp_DREB,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vREB
            ELSE b.hREB
        END) AS opp_REB,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vAST
            ELSE b.hAST
        END) AS opp_AST,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vSTL
            ELSE b.hSTL
        END) AS opp_STL,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vBLK
            ELSE b.hBLK
        END) AS opp_BLK,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vTOV
            ELSE b.hTOV
        END) AS opp_TOV,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vPF
            ELSE b.hPF
        END) AS opp_PF,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vPTS
            ELSE b.hPTS
        END) AS opp_points,
        (CASE
            WHEN (s.TeamID = b.home) THEN b.vPlusMinus
            ELSE b.hPlusMinus
        END) AS opp_PlusMinus
    FROM
        (edwp.f_stats s
        JOIN edwp.team_boxscore b ON ((s.GameID = b.gameid)));