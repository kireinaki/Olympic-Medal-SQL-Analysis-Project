# Olympic Medal Records Analysis

## Project Overview

This SQL project analyzes historical Summer Olympic medal records to examine country performance, athlete achievements, women's medal-record share, changes in Olympic events, and country medal-winning streaks.

**Tools:** Microsoft SQL Server and SQL Server Management Studio (SSMS)

## Dataset

- Source: https://www.kaggle.com/datasets/the-guardian/olympic-games
- Tables:
  - `dbo.summer`
  - `dbo.dictionary`

`dictionary` is joined to `summer` to map country codes to country names.

## Data Assumptions

- Each row represents a medal record in the dataset.
- Team events may contain one record per athlete, so medal-record counts may differ from official medals awarded.
- Athlete analysis uses the `Athlete` name field as an identifier; identical names may represent different people.

## Analysis Questions

- Which countries led medal records in each Olympic year?
- Which countries had the largest change from their previous medal-winning Olympic appearance?
- Which countries ranked highest within each discipline?
- Which athletes won the most medal records and medaled across the most Olympic years?
- How did women's share of medal records change over time?
- Which sports gained or lost the most distinct events?
- Which countries had the longest consecutive Olympic medal-winning streaks?

## Notable Findings

- South Korea leads Archery in both Total Medals and Gold Medals.
- Michael Phelps dominates Total Medal Count and Gold Medal Count, with 18 golds and 22 total medals. Second place for total medals is Edoardo Mangiarotti at 13.
- Women's medal percentage has gradually increased over the years, starting at a low 2.15% when women medals were first introduced in 1900, to 47.41% in 2012.
- United Kingdom has the longest medal streak (consecutive Olympic years winning at least 1 medal) as of 2012, with a streak of 27 Olympics. 
 
## SQL Skills Demonstrated

- `JOIN`, `GROUP BY`, and `HAVING`
- `SUM()`, `COUNT()`, and `COUNT(DISTINCT ...)`
- Common Table Expressions (CTEs)
- Conditional aggregation with `CASE`
- Window functions: `SUM() OVER()`, `ROW_NUMBER()`, `DENSE_RANK()`, and `LAG()`
- Percentage calculations with `NULLIF()`
- Gaps-and-islands logic for consecutive medal-winning streaks

## Project Structure

```text
sql/
├── 01_country_performance.sql
├── 02_athlete_performance.sql
├── 03_womens_medal_share.sql
├── 04_sports_event_evolution.sql
├── 05_country_medal_streaks.sql
└── olympic_medal_analysis_full.sql

```

## How to Run

1. Download the source dataset and load it into SQL Server.
2. Import the tables as `dbo.summer` and `dbo.dictionary`.
3. Update the database name in the SQL scripts if needed.
4. Run the numbered scripts individually, or run the full analysis script.
