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