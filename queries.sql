USE ipl;

-- -----------------------------------------------------------------------------
-- Q1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.
-- -----------------------------------------------------------------------------
SELECT 
    bd.BIDDER_ID,
    bd.BIDDER_NAME,
    COUNT(bdt.SCHEDULE_ID) AS Total_Bids,
    SUM(CASE WHEN bdt.BID_STATUS = 'Won' THEN 1 ELSE 0 END) AS Total_Wins,
    (SUM(CASE WHEN bdt.BID_STATUS = 'Won' THEN 1 ELSE 0 END) * 100.0 / COUNT(bdt.SCHEDULE_ID)) AS Win_Percentage
FROM 
    IPL_BIDDER_DETAILS bd
JOIN 
    IPL_BIDDING_DETAILS bdt ON bd.BIDDER_ID = bdt.BIDDER_ID
GROUP BY 
    bd.BIDDER_ID, bd.BIDDER_NAME
HAVING 
    Total_Bids > 0
ORDER BY 
    Win_Percentage DESC;


-- -----------------------------------------------------------------------------
-- Q2. Display the number of matches conducted at each stadium with the stadium name and city.
-- -----------------------------------------------------------------------------
SELECT 
    s.STADIUM_NAME,
    s.CITY,
    COUNT(ms.SCHEDULE_ID) AS Matches_Conducted
FROM 
    IPL_STADIUM s
JOIN 
    IPL_MATCH_SCHEDULE ms ON s.STADIUM_ID = ms.STADIUM_ID
WHERE 
    ms.STATUS = 'Completed'
GROUP BY 
    s.STADIUM_ID, s.STADIUM_NAME, s.CITY
ORDER BY 
    Matches_Conducted DESC;


-- -----------------------------------------------------------------------------
-- Q3. In a given stadium, what is the percentage of wins by a team that has won the toss?
-- -----------------------------------------------------------------------------
SELECT 
    s.STADIUM_NAME,
    COUNT(m.MATCH_ID) AS Total_Matches,
    SUM(CASE WHEN m.TOSS_WINNER = m.MATCH_WINNER THEN 1 ELSE 0 END) AS Toss_And_Match_Wins,
    (SUM(CASE WHEN m.TOSS_WINNER = m.MATCH_WINNER THEN 1 ELSE 0 END) * 100.0 / COUNT(m.MATCH_ID)) AS Toss_Win_Percentage
FROM 
    IPL_STADIUM s
JOIN 
    IPL_MATCH_SCHEDULE ms ON s.STADIUM_ID = ms.STADIUM_ID
JOIN 
    IPL_MATCH m ON ms.MATCH_ID = m.MATCH_ID
WHERE 
    ms.STATUS = 'Completed'
GROUP BY 
    s.STADIUM_ID, s.STADIUM_NAME
ORDER BY 
    Toss_Win_Percentage DESC;


-- -----------------------------------------------------------------------------
-- Q4. Show the total bids along with the bid team and team name.
-- -----------------------------------------------------------------------------
SELECT 
    t.TEAM_NAME,
    bdt.BID_TEAM,
    COUNT(bdt.BIDDER_ID) AS Total_Bids
FROM 
    IPL_BIDDING_DETAILS bdt
JOIN 
    IPL_TEAM t ON bdt.BID_TEAM = t.TEAM_ID
GROUP BY 
    bdt.BID_TEAM, t.TEAM_ID, t.TEAM_NAME
ORDER BY 
    Total_Bids DESC;


-- -----------------------------------------------------------------------------
-- Q5. Show the team ID who won the match as per the win details.
-- -----------------------------------------------------------------------------
SELECT 
    m.MATCH_ID,
    m.WIN_DETAILS,
    t.TEAM_ID AS Winning_Team_ID,
    t.TEAM_NAME
FROM 
    IPL_MATCH m
JOIN 
    IPL_TEAM t ON m.WIN_DETAILS LIKE CONCAT('%', t.REMARKS, '%') 
    OR m.WIN_DETAILS LIKE CONCAT('%', t.TEAM_NAME, '%');


-- -----------------------------------------------------------------------------
-- Q6. Display the total matches played, total matches won and total matches lost by the team along with its team name.
-- -----------------------------------------------------------------------------
SELECT 
    t.TEAM_NAME,
    SUM(ts.MATCHES_PLAYED) AS Total_Matches_Played,
    SUM(ts.MATCHES_WON) AS Total_Matches_Won,
    SUM(ts.MATCHES_LOST) AS Total_Matches_Lost
FROM 
    IPL_TEAM_STANDINGS ts
JOIN 
    IPL_TEAM t ON ts.TEAM_ID = t.TEAM_ID
GROUP BY 
    t.TEAM_ID, t.TEAM_NAME;


-- -----------------------------------------------------------------------------
-- Q7. Display the bowlers for the Mumbai Indians team.
-- -----------------------------------------------------------------------------
SELECT 
    p.PLAYER_NAME,
    tp.PLAYER_ROLE
FROM 
    IPL_TEAM_PLAYERS tp
JOIN 
    IPL_TEAM t ON tp.TEAM_ID = t.TEAM_ID
JOIN 
    IPL_PLAYER p ON tp.PLAYER_ID = p.PLAYER_ID
WHERE 
    t.TEAM_NAME = 'Mumbai Indians' 
    AND tp.PLAYER_ROLE LIKE '%Bowler%';


-- -----------------------------------------------------------------------------
-- Q8. How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
-- -----------------------------------------------------------------------------
SELECT 
    t.TEAM_NAME,
    COUNT(tp.PLAYER_ID) AS All_Rounder_Count
FROM 
    IPL_TEAM_PLAYERS tp
JOIN 
    IPL_TEAM t ON tp.TEAM_ID = t.TEAM_ID
WHERE 
    tp.PLAYER_ROLE = 'All-Rounder'
GROUP BY 
    t.TEAM_ID, t.TEAM_NAME
HAVING 
    All_Rounder_Count > 4
ORDER BY 
    All_Rounder_Count DESC;


-- -----------------------------------------------------------------------------
-- Q9. Total bidders' points for each bidding status of those bidders who bid on CSK when they won the match in M. Chinnaswamy Stadium bidding year-wise.
-- -----------------------------------------------------------------------------
SELECT 
    bd.BID_STATUS,
    YEAR(bd.BID_DATE) AS Bid_Year,
    SUM(bp.TOTAL_POINTS) AS Total_Points
FROM 
    IPL_BIDDING_DETAILS bd
JOIN 
    IPL_MATCH_SCHEDULE ms ON bd.SCHEDULE_ID = ms.SCHEDULE_ID
JOIN 
    IPL_MATCH m ON ms.MATCH_ID = m.MATCH_ID
JOIN 
    IPL_STADIUM s ON ms.STADIUM_ID = s.STADIUM_ID
JOIN 
    IPL_TEAM t ON m.MATCH_WINNER = t.TEAM_ID
JOIN 
    IPL_BIDDER_POINTS bp ON bd.BIDDER_ID = bp.BIDDER_ID AND bp.TOURNMT_ID = ms.TOURNMT_ID
WHERE 
    t.REMARKS = 'CSK'
    AND s.STADIUM_NAME = 'M. Chinnaswamy Stadium'
    AND bd.BID_TEAM = t.TEAM_ID
GROUP BY 
    bd.BID_STATUS, Bid_Year
ORDER BY 
    Total_Points DESC;


-- -----------------------------------------------------------------------------
-- Q10. Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets. (No Joins, No Limit)
-- -----------------------------------------------------------------------------
SELECT 
    (SELECT TEAM_NAME FROM IPL_TEAM WHERE TEAM_ID = tp.TEAM_ID) AS Team_Name,
    (SELECT PLAYER_NAME FROM IPL_PLAYER WHERE PLAYER_ID = tp.PLAYER_ID) AS Player_Name,
    tp.PLAYER_ROLE,
    (SELECT CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(PERFORMANCE_DTLS, 'Wkt-', -1), ' ', 1) AS UNSIGNED) 
     FROM IPL_PLAYER p WHERE p.PLAYER_ID = tp.PLAYER_ID) AS Wickets
FROM 
    IPL_TEAM_PLAYERS tp
WHERE 
    tp.PLAYER_ROLE IN ('Bowler', 'All-Rounder')
    AND tp.PLAYER_ID IN (
        SELECT PLAYER_ID FROM (
            SELECT 
                PLAYER_ID,
                CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(PERFORMANCE_DTLS, 'Wkt-', -1), ' ', 1) AS UNSIGNED) AS Wickets,
                DENSE_RANK() OVER (
                    ORDER BY CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(PERFORMANCE_DTLS, 'Wkt-', -1), ' ', 1) AS UNSIGNED) DESC
                ) as Rank_Val
            FROM 
                IPL_PLAYER
        ) AS RankedPlayers
        WHERE Rank_Val <= 5
    )
ORDER BY
    Wickets DESC;


-- -----------------------------------------------------------------------------
-- Q11. Show the percentage of toss wins of each bidder and display the results in descending order based on the percentage.
-- -----------------------------------------------------------------------------
SELECT 
    bd.BIDDER_NAME,
    COUNT(bdt.SCHEDULE_ID) AS Total_Bids,
    SUM(CASE WHEN bdt.BID_TEAM = m.TOSS_WINNER THEN 1 ELSE 0 END) AS Bids_On_Toss_Winner,
    (SUM(CASE WHEN bdt.BID_TEAM = m.TOSS_WINNER THEN 1 ELSE 0 END) * 100.0 / COUNT(bdt.SCHEDULE_ID)) AS Toss_Win_Percentage
FROM 
    IPL_BIDDER_DETAILS bd
JOIN 
    IPL_BIDDING_DETAILS bdt ON bd.BIDDER_ID = bdt.BIDDER_ID
JOIN 
    IPL_MATCH_SCHEDULE ms ON bdt.SCHEDULE_ID = ms.SCHEDULE_ID
JOIN 
    IPL_MATCH m ON ms.MATCH_ID = m.MATCH_ID
WHERE 
    ms.STATUS = 'Completed'
GROUP BY 
    bd.BIDDER_ID, bd.BIDDER_NAME
ORDER BY 
    Toss_Win_Percentage DESC;


-- -----------------------------------------------------------------------------
-- Q12. Find the IPL season which has a duration and max duration.
-- -----------------------------------------------------------------------------
SELECT 
    TOURNMT_ID, 
    TOURNMT_NAME, 
    'Duration' AS 'Duration Column',
    DATEDIFF(TO_DATE, FROM_DATE) AS Duration
FROM 
    IPL_TOURNAMENT
WHERE 
    DATEDIFF(TO_DATE, FROM_DATE) = (
        SELECT MAX(DATEDIFF(TO_DATE, FROM_DATE)) FROM IPL_TOURNAMENT
    );


-- -----------------------------------------------------------------------------
-- Q13. Total points month-wise for the 2017 bid year (Using JOINS).
-- -----------------------------------------------------------------------------
SELECT 
    bd.BIDDER_ID, 
    bd.BIDDER_NAME, 
    YEAR(bdt.BID_DATE) AS Bid_Year, 
    MONTHNAME(bdt.BID_DATE) AS Bid_Month, 
    SUM(bp.TOTAL_POINTS) AS Total_Points
FROM 
    IPL_BIDDER_DETAILS bd
JOIN 
    IPL_BIDDING_DETAILS bdt ON bd.BIDDER_ID = bdt.BIDDER_ID
JOIN 
    IPL_BIDDER_POINTS bp ON bd.BIDDER_ID = bp.BIDDER_ID AND bp.TOURNMT_ID = YEAR(bdt.BID_DATE)
WHERE 
    YEAR(bdt.BID_DATE) = 2017
GROUP BY 
    bd.BIDDER_ID, bd.BIDDER_NAME, Bid_Year, Bid_Month
ORDER BY 
    Total_Points DESC, MONTH(bdt.BID_DATE) ASC;


-- -----------------------------------------------------------------------------
-- Q14. Total points month-wise for the 2017 bid year (Using SUB-QUERIES).
-- -----------------------------------------------------------------------------
SELECT 
    bd.BIDDER_ID, 
    bd.BIDDER_NAME, 
    b.Bid_Year, 
    b.Bid_Month, 
    (SELECT SUM(TOTAL_POINTS) FROM IPL_BIDDER_POINTS WHERE BIDDER_ID = bd.BIDDER_ID AND TOURNMT_ID = b.Bid_Year) AS Total_Points
FROM 
    IPL_BIDDER_DETAILS bd
JOIN 
    (SELECT DISTINCT 
        BIDDER_ID, 
        YEAR(BID_DATE) AS Bid_Year, 
        MONTHNAME(BID_DATE) AS Bid_Month,
        MONTH(BID_DATE) AS Month_Num
     FROM IPL_BIDDING_DETAILS 
     WHERE YEAR(BID_DATE) = 2017) AS b 
ON 
    bd.BIDDER_ID = b.BIDDER_ID
ORDER BY 
    Total_Points DESC, b.Month_Num ASC;


-- -----------------------------------------------------------------------------
-- Q15. Top 3 and Bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- -----------------------------------------------------------------------------
SELECT * FROM (
    SELECT 
        bp.BIDDER_ID,
        bp.TOTAL_POINTS,
        bd.BIDDER_NAME AS Highest_3_Bidders,
        NULL AS Lowest_3_Bidders,
        DENSE_RANK() OVER (ORDER BY bp.TOTAL_POINTS DESC) as Rank_Val
    FROM IPL_BIDDER_POINTS bp
    JOIN IPL_BIDDER_DETAILS bd ON bp.BIDDER_ID = bd.BIDDER_ID
    WHERE bp.TOURNMT_ID = 2018
) AS TopBidders
WHERE Rank_Val <= 3

UNION ALL

SELECT * FROM (
    SELECT 
        bp.BIDDER_ID,
        bp.TOTAL_POINTS,
        NULL AS Highest_3_Bidders,
        bd.BIDDER_NAME AS Lowest_3_Bidders,
        DENSE_RANK() OVER (ORDER BY bp.TOTAL_POINTS ASC) as Rank_Val
    FROM IPL_BIDDER_POINTS bp
    JOIN IPL_BIDDER_DETAILS bd ON bp.BIDDER_ID = bd.BIDDER_ID
    WHERE bp.TOURNMT_ID = 2018
) AS BottomBidders
WHERE Rank_Val <= 3;
