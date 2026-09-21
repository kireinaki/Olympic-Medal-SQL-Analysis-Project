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
