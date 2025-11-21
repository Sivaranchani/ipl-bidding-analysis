# ipl-bidding-analysis

## Project Overview
This project simulates a backend database for an "IPL Match Bidding App." It manages user bidding, tracks match schedules, and calculates bidder points using complex logic. The project demonstrates advanced SQL skills including Database Engineering, Normalization, and complex Data Analysis.

## Key Features
* **Dynamic Point System:** Automated logic to calculate points based on match outcomes and team standings.
* **Data Integrity:** Normalized schema with 12 tables, Primary/Foreign keys, and constraints to ensure data accuracy.
* **Complex Analysis:** Solved 17+ business questions using advanced SQL techniques to derive insights on bidder behavior and match statistics.

## Technologies Used
* **Database:** MySQL
* **Language:** SQL
* **Concepts:** Normalization, Window Functions (`DENSE_RANK`, `RANK`), Subqueries, Joins, String Manipulation (`SUBSTRING_INDEX`).

## Database Structure
The system consists of 12 normalized tables including:
* `IPL_User` & `IPL_Bidder_Details`: User management and profiles.
* `IPL_Team` & `IPL_Match`: Core tournament data and match results.
* `IPL_Bidding_Details`: Transactional data for every bid placed.
* `IPL_Team_Standings`: Aggregated performance stats for the tournament.

## Analysis & Insights
This repository contains a `2_queries.sql` file with solutions to 17 business questions, including:
1.  **Bidder Leaderboard:** Identifying the highest win% among users using Aggregations.
2.  **Stadium Analytics:** Calculating the "Toss Win %" advantage for specific venues.
3.  **Fan Favorites:** Analyzing which teams receive the highest volume of bids.
4.  **Top Performers:** extracting top bowlers and all-rounders using string parsing and window functions.

## How to Run
1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/ipl-bidding-analysis.git](https://github.com/YOUR_USERNAME/ipl-bidding-analysis.git)
    ```
2.  **Import the Database:**
    * Open your SQL Client (e.g., MySQL Workbench).
    * Run the script `1_schema_and_data.sql`. This will create the `ipl` database and insert all sample data.
3.  **Run Analysis:**
    * Open and execute `2_queries.sql` to see the solutions to the analytical questions.
