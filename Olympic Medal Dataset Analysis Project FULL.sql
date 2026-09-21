/*
Olympic Medal Analysis — SQL Portfolio Project

Purpose:
This project analyzes historical Summer Olympic medal records (1896 - 2014) to identify
country performance trends, athlete achievements, women's medal-record share,
changes in Olympic events, and country medal-winning streaks.

Database:
- [Olympic Data Project].[dbo].[summer]
- [Olympic Data Project].[dbo].[dictionary]

Key analyses:
1. Country medal rankings and medal-type breakdowns
2. Athlete medal performance and Olympic-year longevity
3. Women's share of medal records over time
4. Changes in the number of events by sport and Olympic year
5. Longest consecutive Olympic medal-winning streaks by country

Note:
Counts in this project represent medal records in the dataset. In team events,
multiple athletes may have a record for one official medal award; therefore,
record counts may not always match official medal totals.

Skills demonstrated:
JOINs, GROUP BY, aggregate functions, CASE statements, CTEs,
window functions, ROW_NUMBER(), DENSE_RANK(), LAG(), NULLIF(),
and gaps-and-islands logic.

Author: Robert Duanmu
Tools: SQL Server Management Studio (SSMS)
*/



-- 1) Medal overview by country and medal type
--    The following queries examine how Olympic medal records are distributed across countries and medal types. 
--    They identify countries with the highest overall medal totals and compare each country’s gold, silver, and bronze medal records.



--Which countries dominated each Olympic year? (Total Medals by Country)
WITH MedalCounts AS (
    SELECT
        Year,
        Country,
        COUNT(*) AS TotalMedals
    FROM [Olympic Data Project].[dbo].[summer] AS summer
    JOIN [Olympic Data Project].[dbo].[dictionary] AS info
        ON summer.CountryCode = info.Code
    GROUP BY
        Year,
        Country
)

SELECT
    Year,
    Country,
    TotalMedals,
    ROW_NUMBER() OVER (
        PARTITION BY Year
        ORDER BY TotalMedals DESC
    ) AS CountryRank
FROM MedalCounts
ORDER BY
    Year,
    CountryRank;


--Largest change since each country’s prior medal-winning Olympic appearance

WITH MedalCounts AS (
        SELECT
            Year,
            Country,
            COUNT(*) AS TotalMedals
        FROM [Olympic Data Project].[dbo].[summer] AS summer
        JOIN [Olympic Data Project].[dbo].[dictionary] AS info
            ON summer.CountryCode = info.Code
        GROUP BY
            Year,
            Country
            ),
    MedalChanges AS (
        SELECT 
            Year,
            Country,
            TotalMedals,
            LAG(TotalMedals) OVER (
                PARTITION BY Country
                ORDER BY Year) AS PreviousMedals
        FROM MedalCounts
            )

SELECT
    Year,
    Country,
    TotalMedals,
    PreviousMedals,
    TotalMedals - PreviousMedals AS MedalChange
FROM MedalChanges
WHERE PreviousMedals IS NOT NULL
ORDER BY
    MedalChange DESC;



-- Country Total Medal Ranking by Discipline (Top 5 per Discipline)

WITH MedalsByDiscipline AS(
    SELECT
        Discipline,
        Country,
        COUNT(*) AS MedalCount
    FROM [Olympic Data Project].[dbo].[summer] AS summer
    JOIN [Olympic Data Project].[dbo].[dictionary] AS info
         ON summer.CountryCode = info.Code 
    GROUP BY
        Discipline,
        Country
    ) ,

    CountryRankings AS(
 SELECT
    Discipline,
    Country,
    MedalCount,
    DENSE_RANK() OVER(
        PARTITION BY Discipline
        ORDER BY MedalCount DESC
        ) AS CountryRank
 FROM MedalsByDiscipline
    )

SELECT
    Discipline,
    Country,
    MedalCount,
    CountryRank
FROM CountryRankings
WHERE CountryRank <= 5;

 -- Country Ranking by Gold, Silver, and Bronze Medals, by Discipline (Top 5 per Discipline)

 WITH MedalsByDiscipline AS(
    SELECT
        Discipline,
        Country,
        COUNT(*) AS MedalCount,
        SUM(CASE WHEN Medal = 'Gold' THEN 1 ELSE 0 END) AS GoldMedals,
        SUM(CASE WHEN Medal = 'Silver' THEN 1 ELSE 0 END) AS SilverMedals,
        SUM(CASE WHEN Medal = 'Bronze' THEN 1 ELSE 0 END) AS BronzeMedals
    FROM [Olympic Data Project].[dbo].[summer] AS summer
    JOIN [Olympic Data Project].[dbo].[dictionary] AS info
         ON summer.CountryCode = info.Code 
    GROUP BY
        Discipline,
        Country
    ) ,
    CountryRankings AS(
SELECT
    Discipline,
    Country,
    MedalCount,
    GoldMedals,
    SilverMedals,
    BronzeMedals,
    DENSE_RANK() OVER(
        PARTITION BY Discipline
        ORDER BY 
            GoldMedals DESC,
            SilverMedals DESC,
            BronzeMedals DESC
        ) AS CountryRank
 FROM MedalsByDiscipline
    )

 SELECT
    Discipline,
    Country,
    MedalCount,
    GoldMedals,
    SilverMedals,
    BronzeMedals,
    CountryRank
FROM CountryRankings
WHERE CountryRank <= 5;


-- 2) Athlete performance 
--    The following queries examine Athlete rankings based on their number of medals.

 -- Number of Medals per Athlete
WITH MedalCounts AS (
    SELECT
        Athlete,
        Medal,
        COUNT(*) AS MedalCount
        FROM [Olympic Data Project].[dbo].[summer] AS summer
        JOIN [Olympic Data Project].[dbo].[dictionary] AS info
        ON summer.CountryCode = info.Code
    GROUP BY
        Athlete,
        Medal
)
SELECT 
    Athlete,
    Medal,
    MedalCount,
    SUM(MedalCount) OVER (PARTITION BY Athlete) AS TotalMedals
FROM MedalCounts
ORDER BY
    TotalMedals DESC,
    Athlete,
    CASE Medal
        WHEN 'Gold' THEN 1
        WHEN 'Silver' THEN 2
        WHEN 'Bronze' THEN 3
    END;


 -- Which athletes have won medals in the most distinct Olympic years?
SELECT
    Athlete,
    COUNT(DISTINCT Year) AS YearsWithMedal,
    COUNT(*) AS MedalCount
 
FROM [Olympic Data Project].[dbo].[summer] AS summer
    JOIN [Olympic Data Project].[dbo].[dictionary] AS info
         ON summer.CountryCode = info.Code 
GROUP BY
    Athlete
ORDER BY
    YearsWithMedal DESC,
    MedalCount DESC;

-- 3) Women’s share of medal records over time
--    The following queries examine the participation of women athletes by looking at women's share of medals over time.

-- Percentage of Women Medals compared to Total Medals across the years
With MedalCount AS(
SELECT
    Year,
    COUNT(*) as TotalMedals,
    COUNT(Case WHEN Gender = 'Women' THEN 1 END) AS WomenMedals
FROM [Olympic Data Project].[dbo].[summer]
GROUP BY 
    Year
    )

SELECT
    Year,
    WomenMedals,
    TotalMedals,
    ROUND(100.0* WomenMedals / NULLIF(TotalMedals, 0), 2) AS WomenMedalPercentage
FROM MedalCount
ORDER BY 
    Year

-- Percent change of Women Medals Share per year
With MedalCount AS(
SELECT
    Year,
    COUNT(*) as TotalMedals,
    COUNT(Case WHEN Gender = 'Women' THEN 1 END) AS WomenMedals
FROM [Olympic Data Project].[dbo].[summer]
GROUP BY 
    Year
    ),

    WomenPercentage AS(
SELECT
    Year,
    WomenMedals,
    TotalMedals,
    ROUND(100.0* WomenMedals / NULLIF(TotalMedals, 0), 2) AS WomenMedalPercentage
FROM MedalCount
    )

SELECT
    Year,
    WomenMedals,
    TotalMedals,
    WomenMedalPercentage,
    LAG(WomenMedalPercentage,1,0) OVER (ORDER BY Year) AS PreviousWomenMedalPercentage,
    WomenMedalPercentage - LAG(WomenMedalPercentage,1,0) OVER (ORDER BY Year)  AS PercentagePointChange

FROM WomenPercentage
ORDER BY 
    Year


-- 4) Sports events evolution
--    The following query examines the top 3 Sports each Olympic year that saw the most number of event additions or subtractions.

WITH EventsBySportYear AS(
    SELECT
        Year,
        Sport,
        COUNT(DISTINCT Event) AS NumberOfEvents
    FROM [Olympic Data Project].[dbo].[summer]
    GROUP BY
        Year,
        Sport
    ),

    EventChanges AS(
    SELECT
        Year,
        Sport,
        NumberOfEvents,
        LAG(NumberOfEvents) OVER (
            PARTITION BY Sport
            ORDER BY Year
        ) AS PreviousNumberOfEvents
    FROM EventsBySportYear
    ),

    RankedEventChanges AS (
        SELECT
            Year,
            Sport,
            NumberOfEvents,
            PreviousNumberOfEvents,
            NumberOfEvents - PreviousNumberOfEvents AS EventChange,
            DENSE_RANK() OVER (
                PARTITION BY Year
                ORDER BY NumberOfEvents - PreviousNumberOfEvents DESC
            ) AS ChangeRank
        FROM EventChanges
    )

SELECT
    Year,
    Sport,
    NumberOfEvents,
    PreviousNumberOfEvents,
    EventChange,
    ChangeRank
FROM RankedEventChanges
WHERE PreviousNumberOfEvents IS NOT NULL
      AND EventChange <> 0
      AND ChangeRank <= 3
ORDER BY
    Year,
    ChangeRank,
    Sport;


-- 5) Countries with longest medal streaks (years with at least 1 medal)

WITH CountryMedalYears AS(
    SELECT DISTINCT
        Country,
        Year
    FROM [Olympic Data Project].[dbo].[summer] AS summer
        JOIN [Olympic Data Project].[dbo].[dictionary] AS info
             ON summer.CountryCode = info.Code
    ),

    OlympicYears AS(
    SELECT DISTINCT
       Year,
       DENSE_RANK() OVER(ORDER BY Year) AS OlympicEdition
    FROM [Olympic Data Project].[dbo].[summer] AS summer
        JOIN [Olympic Data Project].[dbo].[dictionary] AS info
             ON summer.CountryCode = info.Code
    ),

    NumberedAppearances AS (
    SELECT
        cmy.Country,
        cmy.Year,
        oy.OlympicEdition,
        ROW_NUMBER() OVER (
            PARTITION BY cmy.Country
            ORDER BY oy.OlympicEdition
        ) AS CountryEditionNumber
    FROM CountryMedalYears AS cmy
    JOIN OlympicYears AS oy
        ON cmy.Year = oy.Year
    ),

    StreakGroups AS (
    SELECT
        Country,
        Year,
        OlympicEdition,
        CountryEditionNumber,
        OlympicEdition - CountryEditionNumber AS StreakGroup
    FROM NumberedAppearances
    ),
    Streaks AS (
    SELECT
        Country,
        StreakGroup,
        COUNT(*) AS StreakLength,
        MIN(Year) AS StreakStartYear,
        MAX(Year) AS StreakEndYear
    FROM StreakGroups
    GROUP BY
        Country,
        StreakGroup
)

SELECT
    Country,
    StreakLength,
    StreakStartYear,
    StreakEndYear
FROM Streaks
ORDER BY
    StreakLength DESC,
    Country;
