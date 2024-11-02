# Load libraries
library(quantmod)  # for getting stock data
library(ggplot2)   # for plotting
library(dplyr)     # for data manipulation

# Function to simulate portfolios and find the best one
myMeanVarPort <- function(tickers, start_date, end_date, rf_rate) {
  set.seed(12)  # so results stay the same each time
  
  # Step 1: Download stock data and calculate returns
  stock_returns <- lapply(tickers, function(ticker) {
    data <- getSymbols(ticker, src = 'yahoo', from = start_date, to = end_date, auto.assign = FALSE)
    monthly_data <- to.monthly(data, indexAt = 'lastof', OHLC = FALSE)
    monthly_returns <- na.omit(periodReturn(Ad(monthly_data), period = 'monthly', type = 'log'))
    colnames(monthly_returns) <- ticker
    return(monthly_returns)
  })
  
  # Combine returns and calculate average and std dev (annualized)
  returns_data <- do.call(merge, stock_returns)
  avg_returns <- colMeans(returns_data) * 12  # Annualized mean returns
  std_devs <- apply(returns_data, 2, sd) * sqrt(12)  # Annualized std dev
  
  # Make a summary table for stocks
  stock_summary <- data.frame(
    Ticker = tickers,
    Avg_Annual_Return = avg_returns,
    Annual_Std_Dev = std_devs
  )
  
  # Calculate annualized covariance matrix
  cov_matrix <- cov(returns_data) * 12
  
  # Step 2: Simulate portfolios with random weights
  num_assets <- length(tickers)
  num_portfolios <- 100 * num_assets  # Number of portfolios to simulate
  portfolio_means <- numeric(num_portfolios)
  portfolio_risks <- numeric(num_portfolios)
  portfolio_sharpe <- numeric(num_portfolios)
  weights_matrix <- matrix(nrow = num_portfolios, ncol = num_assets)
  
  for (i in 1:num_portfolios) {
    # Random weights
    weights <- runif(num_assets)
    weights <- weights / sum(weights)  # Normalize weights
    
    # Calculate portfolio return, risk, and Sharpe Ratio
    portfolio_means[i] <- sum(weights * avg_returns)
    portfolio_risks[i] <- sqrt(t(weights) %*% cov_matrix %*% weights)
    portfolio_sharpe[i] <- (portfolio_means[i] - rf_rate) / portfolio_risks[i]
    weights_matrix[i, ] <- weights
  }
  
  # Put portfolio data into a data frame
  portfolio_data <- data.frame(
    Mean_Return = portfolio_means,
    Risk = portfolio_risks,
    Sharpe_Ratio = portfolio_sharpe
  )
  portfolio_data <- cbind(portfolio_data, weights_matrix)
  colnames(portfolio_data)[-(1:3)] <- tickers
  
  # Step 3: Find the "best" portfolios
  optimal_idx <- which.max(portfolio_data$Sharpe_Ratio)
  min_var_idx <- which.min(portfolio_data$Risk)
  optimal_portfolio <- portfolio_data[optimal_idx, ]
  min_variance_portfolio <- portfolio_data[min_var_idx, ]
  
  # Create the "efficient frontier" - only keep portfolios on the top edge
  efficient_frontier <- portfolio_data %>%
    arrange(Risk) %>%
    filter(cummax(Mean_Return) == Mean_Return)
  
  # Capital Market Line (CML) for the optimal portfolio
  cml_slope <- (optimal_portfolio$Mean_Return - rf_rate) / optimal_portfolio$Risk
  cml_x <- seq(0, max(portfolio_data$Risk), length.out = 100)
  cml_y <- rf_rate + cml_slope * cml_x
  
  # Return key data frames
  return(list(
    stock_summary = stock_summary,
    optimal_portfolio = optimal_portfolio,
    min_variance_portfolio = min_variance_portfolio,
    efficient_frontier = efficient_frontier,
    portfolio_data = portfolio_data,
    cml_x = cml_x,
    cml_y = cml_y
  ))
}

# Test it out with specified stocks and dates
tickers <- c("GE", "XOM", "GBX", "SBUX", "PFE", "HMC", "NVDA")
risk_free_rate <- 0.02
results <- myMeanVarPort(tickers, '2014-01-01', '2017-12-31', risk_free_rate)

# Extract the results for viewing
Stock_Summary <- results$stock_summary
Optimal_Portfolio <- results$optimal_portfolio
Min_Variance_Portfolio <- results$min_variance_portfolio
Efficient_Frontier_Portfolios <- results$efficient_frontier

print("Stock Summary:")
print(Stock_Summary)
print("Optimal Portfolio:")
print(Optimal_Portfolio)
print("Minimum Variance Portfolio:")
print(Min_Variance_Portfolio)
print("Efficient Frontier Portfolios:")
print(Efficient_Frontier_Portfolios)

# Plot the portfolios with the efficient frontier and Capital Market Line
ggplot(results$portfolio_data, aes(x = Risk, y = Mean_Return)) +
  geom_point(color = "blue", alpha = 0.5) +
  geom_line(data = results$efficient_frontier, aes(x = Risk, y = Mean_Return), color = "green", linewidth = 1.2) +
  annotate("point", x = Optimal_Portfolio$Risk, y = Optimal_Portfolio$Mean_Return, color = "red", size = 4) +
  annotate("point", x = Min_Variance_Portfolio$Risk, y = Min_Variance_Portfolio$Mean_Return, color = "purple", size = 4) +
  geom_line(data = data.frame(x = results$cml_x, y = results$cml_y), aes(x = x, y = y), color = "orange", linetype = "dashed", linewidth = 1) +
  labs(title = "Simulated Portfolios: Risk vs. Return with Efficient Frontier and CML",
       x = "Portfolio Risk (Standard Deviation)",
       y = "Portfolio Mean Return") +
  annotate("text", x = Optimal_Portfolio$Risk, y = Optimal_Portfolio$Mean_Return,
           label = "Optimal Portfolio", color = "red", vjust = -1) +
  annotate("text", x = Min_Variance_Portfolio$Risk, y = Min_Variance_Portfolio$Mean_Return,
           label = "Min Variance Portfolio", color = "purple", vjust = -1) +
  annotate("text", x = 0.05, y = risk_free_rate + 0.05 * results$cml_slope,
           label = "Capital Market Line", color = "orange", vjust = -1) +
  theme_minimal()

