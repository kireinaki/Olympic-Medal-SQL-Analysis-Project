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
