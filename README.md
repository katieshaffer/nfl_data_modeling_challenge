# Fantasy Football Insights – Paradime Data Modeling Challenge

## Table of Contents
- [Introduction](#introduction)
- [Data Sources](#data-sources)
- [Methodology](#methodology)
  - [Tools Used](#tools-used)
  - [Data Preparation & Modeling](#data-preparation--modeling)
  - [Model Lineage](#model-lineage)
- [Visuals & Key Metrics](#visuals--key-metrics)
  - [General Analysis](#general-analysis)
  - [Contracts & Fantasy Performance](#contracts--fantasy-performance)
  - [Availability & Fantasy Performance](#availability--fantasy-performance)
- [Insights & Findings](#insights--findings)
- [Final Thoughts](#final-thoughts)

---

## Introduction
For this edition of Paradime's data modeling challenge, I set out to uncover insights for fantasy football players using NFL-related datasets. My main goal was to analyze two key factors that impact fantasy performance:  
1. **Player Contracts** – How does a player's contract status (rookie year, final year, mid-contract) relate to their fantasy performance?  
2. **Player Availability** – Does past availability (games played) predict future fantasy output?  

To explore these questions, I combined player performance data with contract history, using dbt™, Snowflake, and visualization tools.

[Dashboard](https://app.lightdash.cloud/projects/df0c18fb-7380-4ffb-97ff-8807c7bcf839/dashboards/d4b436c0-d2a8-48de-aa2a-ead861aff88a/view)

---

## Data Sources
I used two primary datasets:  

- **NFL_PLAYERS_STATS_2015_2025** – A game-level dataset of NFL player statistics from the past 10 years, pulled using the `nfl_data_py` API (script provided by Paradime).  
- **NFL_CONTRACTS** – A dataset containing 20+ years of player contract history. I scraped this data from [OverTheCap](https://overthecap.com/contract-history) using a custom [Python script](scripts/nfl_contract_scraper.py).

---

## Methodology

### Tools Used
- **Paradime** – dbt™ modeling and SQL  
- **Snowflake** – Data warehousing  
- **Lightdash** – Data visualization  
- **Python** – Data extraction (from `nfl_data_py` and OverTheCap scraping)  

### Data Preparation & Modeling

1. Extracted 10 years of player data to ensure enough overlap between player contracts and performance.  
   - Longer contracts (4-6 years) mean some players might not have multiple contract periods within a shorter window.  
   - I avoided older data to minimize the impact of changes in the game’s style and rules.  

2. Built two **[staging models]**(models/staging):  
   - `stg_contracts` – Cleaned and structured contract data.  
   - `stg_player_stats_by_game` – Organized player performance on a per-game basis.  

3. Created an **intermediate model**(models/intermediate/int_fantasy_points.sql) to:  
   - Aggregate performance data at the **season level**.  
   - Select the **top 100** players from each season based on:
     - **Total PPR points** (important for season-long leagues).  
     - **Average PPR points per game** (to account for injuries and missed games).  
   - While standard fantasy leagues typically have 150-240 rostered players, the **top 100** represents the **core fantasy-relevant players**—those who are consistently starters and have the most impact on season outcomes.  

   This approach ensures we don’t exclude high-performing but injury-prone players solely due to missed games.  

4. Built **fact models**(models/marts/facts) to analyze different aspects:  
   - `fct_contract_year` – Identifies players' **first and last contract years** within the 10-year period.  
   - `fct_player_availability` – Focuses on how **games played** affects fantasy performance.  

### Model Lineage

![Visualization](viz/lineage_fct_contract.png)

![Visualization](viz/lineage_fct_player_av.png)


---

## Visuals & Key Metrics

### General Analysis

I included two general visuals to gain a clearer understanding of the dataset:

1. **Number of players by position**  

![Visualization](viz/number_of_players_per_position.png)

2. **PPR distribution per position**  

![Visualization](viz/ppr_per_position.png)

### Contracts & Fantasy Performance
3. **PPR by is_final_year**  

![Visualization](viz/ppr_by_final_year.png)

I initially assumed that players' performances in their final year would be better than in any other season. However, this trend isn't apparent in the chart, so I proceeded with further analysis:

![Visualization](viz/ppr_by_first_year.png)

Looking at this visual, we can observe that players in their first contract year tend to perform worse, likely due to the challenges of rookie seasons.

![Visualization](viz/ppr_by_first_final_year.png)

Incorporating both flags into the analysis reveals some interesting insights. To improve interpretation, I’ve created these categories based on the two flags:

![Visualization](viz/ppr_by_contract_status.png)

It’s clear that players in the 'Mid-contract' phase perform the best, followed closely by those in their final year. Players on 1-year contracts have the lowest performance.


4. **Mid-contract performance breakdown** (by contract year & position)

After observing this, I wanted to gain a deeper understanding of 'Mid-contract' players, so I broke down the average PPR by the specific year of the contract the players are in:

![Visualization](viz/mid_contract_by_contract_year.png)

Players in their 6th year perform the best, while those in their second year have the lowest average PPR.

I also analyzed the breakdown by position:

![Visualization](viz/mid_contract_by_position.png)

Quarterbacks are the top performers, while tight ends rank the lowest.

5. **Fantasy PPR by final contract year of a multi-year contract**  

Since final contract year performances were the second best, I wanted to gain a better understanding of them as well. I analyzed the breakdown by position:
 
![Visualization](viz/final_year_contract_by_position.png)

The breakdown shows the same order: quarterbacks, wide receivers, running backs, and tight ends.


### Availability & Fantasy Performance
6. **PPR vs. Average Games Played**  

Next, I wanted to explore whether a player’s performance is influenced by the average number of games they've played each season throughout their career.

![Visualization](viz/avg_ppr_by_avg_games_played.png)

Interestingly, average PPR is heavily influenced by the number of games played. Players who average around 1 game per season tend to have high PPR, but this isn’t relevant, as fantasy managers typically avoid drafting players with such limited playing time. I would highlight players who average around 8 games per season, as they show a significantly higher average than players with 9 or fewer games. However, the highest average PPR belongs to players who average around 15 games per season. As a fantasy football manager, I would definitely focus on these players, as they not only have the best skill —availability— but also the highest average PPR, making them a valuable asset to any fantasy team.

7. **Availability breakdown by position**  

![Visualization](viz/QB_games_played.png)
![Visualization](viz/RB_games_played.png)
![Visualization](viz/TE_games_played.png)
![Visualization](viz/WR_games_played.png)

For each of the four positions, the same trend is observed: as availability increases, average PPR also increases.

---

## Insights & Findings
- The analysis narrows down to just four positions in the top 100 players: QB, RB, WR, and TE.
- Players do not perform better in their final contract year. Instead, players in the "mid contract" phase tend to perform the best. Although final contract year players are a close second, drafting players from either of these two categories is generally more favorable.
- For "mid contract" players, longer contract durations are linked to better performance. This makes sense, as rookies often improve over time.
- Among both "mid contract" and "final year" players, QBs are the top performers, followed by wide receivers, running backs, and tight ends.
- Players on a one-year deal should be avoided.
- Availability clearly correlates with total PPR points, but it turns out to be also correlated with average PPR.

---

## Final Thoughts
In summary, fantasy football managers should prioritize players with proven availability, especially those in their "mid-contract" phase who show a balance of experience and performance. By focusing on players who offer both skill and durability, managers can build more robust and reliable fantasy teams.
