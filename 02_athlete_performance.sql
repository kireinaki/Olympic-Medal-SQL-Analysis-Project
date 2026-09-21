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