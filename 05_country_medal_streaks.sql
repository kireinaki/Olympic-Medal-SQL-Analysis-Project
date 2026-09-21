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