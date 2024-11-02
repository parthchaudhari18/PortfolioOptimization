# Portfolio Optimization using Mean-Variance Analysis

This project demonstrates a portfolio optimization technique using **mean-variance analysis** and **Monte Carlo simulation** in R. The goal is to identify an **optimal portfolio** from a selected set of stocks based on risk-return characteristics. The optimal portfolio maximizes the **Sharpe Ratio** for the best risk-adjusted return, while a **minimum variance portfolio** minimizes overall risk.

## Project Overview

This project performs the following key calculations:
- **Mean Annual Returns and Standard Deviations** for each selected stock.
- **Simulated Portfolios** using random weights to generate diverse portfolio configurations.
- **Optimal Portfolio** with the highest Sharpe Ratio.
- **Minimum Variance Portfolio** with the lowest risk.
- **Efficient Frontier** representing the set of portfolios with the best risk-return profiles.
- **Capital Market Line (CML)** illustrating the relationship between the risk-free rate and the optimal portfolio return.

The results include a plot of the simulated portfolios, efficient frontier, and the Capital Market Line (CML), providing a clear visualization of risk-return trade-offs.

## Project Features

- **Stock Data Retrieval**: Fetches historical stock data from Yahoo Finance using `quantmod`.
- **Monte Carlo Simulation**: Generates random portfolios to identify optimal configurations.
- **Efficient Frontier Calculation**: Filters portfolios to identify those on the top edge of risk-return space.
- **Visualization**: `ggplot2`-based visualization of portfolios, efficient frontier, and CML.

## Dependencies

The project is built using the following R packages:
- **[quantmod](https://cran.r-project.org/web/packages/quantmod/index.html)**: For retrieving stock data from Yahoo Finance.
- **[ggplot2](https://ggplot2.tidyverse.org/)**: For data visualization.
- **[dplyr](https://dplyr.tidyverse.org/)**: For data manipulation.

## Setup Instructions

1. **Clone the repository**: `https://github.com/parthchaudhari18/PortfolioOptimization`
2. **Install the necessary R packages** if they are not already installed: `install.packages(c("quantmod", "ggplot2", "dplyr"))`
3. **Run the R Markdown file** (`PortfolioOptimization.Rmd`) in RStudio to execute the analysis and view the results.

## Usage

The main function in this project is `myMeanVarPort()`, which takes the following inputs:
- `tickers`: A vector of stock symbols (e.g., `c("GE", "XOM", "SBUX")`).
- `start_date`: The start date for historical data in `YYYY-MM-DD` format.
- `end_date`: The end date for historical data in `YYYY-MM-DD` format.
- `rf_rate`: The annual risk-free rate (e.g., `0.02` for 2%).


## Visualization
The project includes a plot of the simulated portfolios, efficient frontier, and the Capital Market Line (CML), providing a clear visualization of the risk-return trade-offs. Run the visualization section in the R Markdown file to view the graph.
