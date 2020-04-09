%==========================================================================
% Asset pricing and portfolio analysis
% Assignment 1: Estimating discount rate for WMT
% Date: February - March, 2020
%==========================================================================

%==========================================================================
% Preliminary commands - clear all data, clear command space, close all files and figures
%==========================================================================
clear;
clc;
close all;


%==========================================================================
% WMT data
%==========================================================================
% Import the data for WMT from Yahoo! Finance
% Saved the file at C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\WMT.xlsx
% Run the code to read in the data
% Make sure you remember to convert first column to numeric dates
WMT = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\WMT.xlsx');

% Convert excel dates in first column to matlab dates
WMT(:, 1) = x2mdate(WMT(:, 1));

% Add an extra column at the end of the file with years
WMT(:, end+1) = year(WMT(:, 1));

% Add another extra column at the end of the filw with the month
WMT(:, end+1) = month(WMT(:, 1));

% Compute stock returns using adjusted close prices
% Add another column at the end to save the returns
WMT(2:end, end+1) = WMT(2:end, 6)./WMT(1:end-1, 6) - 1;

% Create final file - Column1: Year / Column 2: Month / Column 3: Returns
WMTFinal = WMT(2:end, end-2:end);


%==========================================================================
% Stock market data
%==========================================================================
% Import the data for the SP500
SP500 = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\SP.xlsx');

% Convert excel dates in first column to matlab dates
SP500(:, 1) = x2mdate(SP500(:, 1));

% Add an extra column at the end with the years
SP500(:, end+1) = year(SP500(:, 1));
   
% Add an extra column at the end with the month
SP500(:, end+1) = month(SP500(:, 1));

% Compute stock returns using adjusted close prices
SP500(2:end, end+1) = SP500(2:end, 6)./SP500(1:end-1, 6) - 1;

% Create final file - Column1: Year / Column 2: Month / Column 3: Returns
SPFinal = SP500(2:end, end-2:end);


%==========================================================================
% Squared market returns data
%==========================================================================
% Add another column at the end with market squared returns
% Create final file - Column1: Year / Column 2: Month / Column 3: Returns
SPFinal(:, end+1) = SPFinal(:, 3).^2;


%==========================================================================
% Long Term Interest Rate Data (Index)
%==========================================================================
% Import the data for long-term interest rates
LTIR = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\LTIR.xlsx');

% Convert excel dates to matlab dates
LTIR(:, 1) = x2mdate(LTIR(:, 1));

% Add a column with the years
LTIR(:, end+1) = year(LTIR(:, 1));

% Add a column with the month
LTIR(:, end+1) = month(LTIR(:, 1));

% Compute change in long term interest rates
LTIR(2:end, end+1) = LTIR(2:end, 2) ./ LTIR(1:end-1, 2) - 1;

% Create final file - Column1: Year / Column 2: Month / Column 3: Returns
LTIRFinal = LTIR(2:end, end-2:end);


%==========================================================================
% Unemployment Rate data
%==========================================================================
% Import the data for the Unemployment Rate
UNRATE = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\CPI.xlsx');

% Convert excel dates to matlab dates
UNRATE(:, 1) = x2mdate(UNRATE(:, 1));

% Add a column with the years
UNRATE(:, end+1) = year(UNRATE(:, 1));
 
% Add a column with the month
UNRATE(:, end+1) = month(UNRATE(:, 1));

% Compute change in inflation
UNRATE(13:end, end+1) = UNRATE(13:end, 2) - UNRATE(1:end-12, 2);

% Create final file - Column1: Year / Column 2: Month / Column 3: Returns
UNRATEFinal = UNRATE(13:end, end-2:end);


%==========================================================================
% Consumer Confidence data
%==========================================================================
% Import the data
SENT = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\SENT.xlsx');

% Convert excel dates to matlab dates
SENT(:, 1) = x2mdate(SENT(:, 1));

% Add a column with the years
SENT(:, end+1) = year(SENT(:, 1));

% Add a column with the month
SENT(:, end+1) = month(SENT(:, 1));

% Compute change in unemployment rate
SENT(13:end, end+1) = SENT(13:end, 2) - SENT(1:end-12, 2);

% Create final file - Column1: Year / Column 2: Month / Column 3: Returns
SENTFinal = SENT(13:end, end-2:end);


%==========================================================================
% Small and large firm data
%==========================================================================
% Import the data
FFDATA = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\FFDATA.xlsx');

% Divide returns by 100
% Column 3 of this file is market returns
% Column 4 of this file is smb
% Column 5 of this file is hml
% Column 6 of this file is the risk-free rate
% Make sure you remember that the numbers need to be divided by 100
FFDATAFinal = [FFDATA(:, 1:2) FFDATA(:, 3:end)./100];


%==========================================================================
% Merge the files by year and month
%==========================================================================
[~, d1, d2, d3, d4, d5, d6] = mintersect(WMTFinal(:, 1:2), SPFinal(:, 1:2), FFDATAFinal(:, 1:2), LTIRFinal(:, 1:2), UNRATEFinal(:, 1:2), SENTFinal(:, 1:2), 'rows');

WMTsync = WMTFinal(d1, :);
SPsync = SPFinal(d2, :);
FFDATAsync = FFDATAFinal(d3, :);
LTIRsync = LTIRFinal(d4, :);
UNRATEsync = UNRATEFinal(d5, :);
SENTsync = SENTFinal(d6, :);


%==========================================================================
% Run regression to estimate betas
% How sensitive is WMT to factors
%==========================================================================
Y = WMTsync(:, 3) - FFDATAsync(:, 6);
X = [ones(size(WMTsync, 1), 1) SPsync(:, 3) SPsync(:, 4) FFDATAsync(:,4) LTIRsync(:, 3) UNRATEsync(:, 3) SENTsync(:, 3)];
MODEL_WMT = ols(Y, X);

% Keep data for beta, bstd, tstat, rbar
beta = MODEL_WMT.beta;
se = MODEL_WMT.bstd;
tstat = MODEL_WMT.tstat;
rsqr = MODEL_WMT.rbar;


%==========================================================================
% Collect data on betas, R-squared values, standard errors, t-statistics
%==========================================================================
% I collect the data on these variables and store them in an Excel file
% Remember we ignore the alphas
% We ignore betas where t-stats are more than -1.96 and less than 1.96


%==========================================================================
% 1. Estimate risk premium required for stock market
%==========================================================================
% Use the data in SP500sync
mean_mkt_return = mean(SPsync(:, 3)) * 12;
std_mkt_return = std(SPsync(:, 3)) * sqrt(12) / sqrt(size(SPsync, 1));


%==========================================================================
% 3. Estimate risk premium required for small and large firms
%==========================================================================
% Use the data in FFDATAsync - Column 4
mean_smb_return = mean(FFDATAsync(:, 4)) * 12;
std_smb_return = std(FFDATAsync(:, 4)) * sqrt(12) / sqrt(size(FFDATAsync, 1));


%==========================================================================
% 2. FAMA FRENCH METHODOLOGY: Estimate risk premium for mkt squared returns
%==========================================================================
% Import data for 100 stocks;
hund_stocks = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\100_Stocks.xlsx');

% Synchronize the file for 100 stocks with FFDATA and with SP500;
[~, d7, d8, d9] = mintersect(hund_stocks(:, 1:2), FFDATAFinal(:, 1:2), SPFinal(:, 1:2), 'rows');
hund_stocks_sync = hund_stocks(d7, :);
FFDATAsync2 = FFDATAFinal(d8, :);
SPsync2 = SPFinal(d9, :);

% Declare a variable with zeros to store the results of the 100 regressions
% This file creates a file with 2 columns and 100 rows, All values = 0
betas1 = zeros(100, 2);

% Run a 100 regression, one for each stock; idx0 is just an index variable that keeps track of the columns
for idx0 = 1 : 100
    % Clear repeatedly used variables
    clearvars X Y r;
    
    % Set dependent variables equal to data in 3rd, 4th, 5th column in file
    % Make sure you remember to subtract the risk-free rate
    Y = hund_stocks_sync(:, 2+idx0) - FFDATAsync2(:, 6);
    
    % Set the independent variable equal to a column of ones and market squared returns
    X = [ones(size(SPsync2, 1), 1) SPsync2(:, 4)];
    
    % Run a regression
    r = ols(Y, X);
    
    % Store the beta from this regression
    % Ignore the alpha from this regression
    % Keep only the second value from the beta
    betas1(idx0, 1) = r.beta(2);
    
    % Compute the annual mean return of the stock
    % And store the mean return in the second column
    betas1(idx0, 2) = mean(hund_stocks_sync(:, 2+idx0));
end

% Set Y as the mean annual average return on the 100 stocks
Y = betas1(:, 2);
% Set X as the 100 betas you just got
X = betas1(:, 1);

% Run a second regression
% Note this time we do not have a column of ones in X
s = ols(Y, X);

% Use only the value of beta from this regression
mean_ret_for_mkt2 = s.beta(1)*12;

% Also get the standard error to compute ranges
std_for_mkt2 = s.bstd(1) * sqrt(12);


%==========================================================================
% 4. Estimate risk premium for LTIR
%==========================================================================
%This is an index, actual returns, so no need for fama french
mean_ltir_return = mean(LTIRsync(:, 3)) * 12;
std_ltir_return = std(LTIRsync(:, 3)) * sqrt(12) / sqrt(size(LTIRsync, 1));


%==========================================================================
% 5. FAMA FRENCH METHODOLOGY: Estimate risk premium for Unemployment Rate
%==========================================================================
% Import data for 100 stocks;
hund_stocks = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\100_Stocks.xlsx');

% Synchronize the file for 100 stocks with FFDATA and with inflation;
[~, d7, d8, d9] = mintersect(hund_stocks(:, 1:2), FFDATAFinal(:, 1:2), UNRATEFinal(:, 1:2), 'rows');
hund_stocks_sync = hund_stocks(d7, :);
FFDATAsync2 = FFDATAFinal(d8, :);
UNRATEsync2 = UNRATEFinal(d9, :);

% Declare a variable with zeros to store the results of the 100 regressions
% This file creates a file with 2 columns and 100 rows, All values = 0
betas1 = zeros(100, 2);

% Run a 100 regression, one for each stock; idx0 is just an index variable that keeps track of the columns
for idx0 = 1 : 100
    
    % Clear repeatedly used variables
    clearvars X Y r;
    
    % Set dependent variables equal to data in 3rd, 4th, 5th column in file
    % Make sure you remember to subtract the risk-free rate
    Y = hund_stocks_sync(:, 2+idx0) - FFDATAsync2(:, 6);
    
    % Set the independent variable equal to a column of ones and inflation
    X = [ones(size(UNRATEsync2, 1), 1) UNRATEsync2(:, 3)];
    
    % Run a regression
    r = ols(Y, X);
    
    % Store the beta from this regression
    % Ignore the alpha from this regression
    % Keep only the second value from the beta
    betas1(idx0, 1) = r.beta(2);
    
    % Compute the annual mean return of the stock
    % And store the mean return in the second column
    betas1(idx0, 2) = mean(hund_stocks_sync(:, 2+idx0));
end
   
    % Set Y as the mean annual average return on the 100 stocks
    Y = betas1(:, 2);
    
    % Set X as the 100 betas you just got
    X = betas1(:, 1);
    
    % Run a second regression
    % Note this time we do not have a column of ones in X
    s = ols(Y, X);
    
    % Use only the value of beta from this regression
    mean_ret_for_unrate = s.beta(1) * 12;
    
    % Also get the standard error to compute ranges
    std_for_unrate = s.bstd(1) * sqrt(12);

    
%==========================================================================
% 6. FAMA FRENCH METHODOLOGY: Estimate risk premium for Consumer Confidence
%==========================================================================
   
% Import data for 100 stocks;
hund_stocks = xlsread('C:\Users\Jeffrey\Google Drive\Sync All\Spring 2020\Asset Pricing and Portfolio Analysis\Assignments\Assignment 1\Files for Assignment 01 - WMT\100_Stocks.xlsx');

% Synchronize the file for 100 stocks with FFDATA and with Unemployment Rate;
[~, d7, d8, d9] = mintersect(hund_stocks(:, 1:2), FFDATAFinal(:, 1:2), SENTFinal(:, 1:2), 'rows');
hund_stocks_sync = hund_stocks(d7, :);
FFDATAsync2 = FFDATAFinal(d8, :);
SENTsync2 = SENTFinal(d9, :);

% Declare a variable with zeros to store the results of the 100 regressions
% This file creates a file with 2 columns and 100 rows, All values = 0
betas1 = zeros(100, 2);

% Run a 100 regression, one for each stock; idx0 is just an index variable that keeps track of the columns
for idx0 = 1 : 100
    
    % Clear repeatedly used variables
    clearvars X Y r;
    
    % Set dependent variables equal to data in 3rd, 4th, 5th column in file
    % Make sure you remember to subtract the risk-free rate
    Y = hund_stocks_sync(:, 2+idx0) - FFDATAsync2(:, 6);
    
    % Set the independent variable equal to a column of ones and consumer confidence
    X = [ones(size(SENTsync2, 1), 1) SENTsync2(:, 3)];
    
    % Run a regression
    r = ols(Y, X);
    
    % Store the beta from this regression
    % Ignore the alpha from this regression
    % Keep only the second value from the beta
    betas1(idx0, 1) = r.beta(2);
    
    % Compute the annual mean return of the stock
    % And store the mean return in the second column
    betas1(idx0, 2) = mean(hund_stocks_sync(:, 2+idx0));
end
   
    % Set Y as the mean annual average return on the 100 stocks
    Y = betas1(:, 2);
    
    % Set X as the 100 betas you just got
    X = betas1(:, 1);
    
    % Run a second regression
    % Note this time we do not have a column of ones in X
    s = ols(Y, X);
    
    % Use only the value of beta from this regression
    mean_ret_for_sent = s.beta(1) * 12;
    
    % Also get the standard error to compute ranges
    std_for_sent = s.bstd(1) * sqrt(12);
    
    
    
%==========================================================================
% risk free rate
%==========================================================================
rf = mean(FFDATAsync2(:, 6));