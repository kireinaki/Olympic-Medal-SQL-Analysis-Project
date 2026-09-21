# Olympic-Medal-SQL-Analysis-Project

Purpose:
This project analyzes historical Summer Olympic medal records (1896 - 2014) to identify
country performance trends, athlete achievements, women's medal-record share,
changes in Olympic events, and country medal-winning streaks.

Database:
Dataset from: https://www.kaggle.com/datasets/the-guardian/olympic-games
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
