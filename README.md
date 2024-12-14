# Determinants of Subjective Well-Being: A Data-Driven Analysis

This repository contains all materials, data, and code related to the analysis of subjective well-being determinants using econometric methods and survey data from the **Encuesta de Condiciones de Vida (ECV)** provided by INEC.

## Project Overview

The primary objective of this project is to explore the factors influencing subjective well-being, focusing on:

- The relationship between **absolute income** and **relative income** with happiness.
- The role of objective factors, such as household income and ownership, compared to subjective perceptions, like the importance of family or popularity.
- The inclusion of econometric techniques to provide a robust analysis of key variables.

## Key Components

1. **Data Cleaning and Preparation**:
   - Merging datasets and cleaning variables.
   - Renaming variables for clarity and correcting missing values.
   - Producing a refined dataset ready for analysis.

2. **Descriptive Statistics**:
   - Summary statistics and visualizations for key variables.
   - Exploratory analysis using scatter plots and histograms.

3. **Econometric Analysis**:
   - Regression models, including Tobit models for censored data.
   - Examination of absolute and relative income impacts on happiness.
   - Robustness checks and alternative model specifications.

4. **Results Interpretation**:
   - Statistical insights on the relative importance of various determinants of well-being.
   - Policy implications and potential avenues for future research.

## Repository Contents

- **Code**:
  - `data_cleaning.do`: Stata script for data cleaning and preparation.
  - `analysis.do`: Stata script for econometric analysis and exporting results.

## Research Findings

Key findings include:
- Absolute income positively correlates with happiness, while relative income has a significant negative impact.
- Other influential factors include education, gender, and family importance.
- Insights align with existing literature on positional concerns and subjective well-being.

## Usage

To replicate the analysis:
1. Clone this repository.
2. Install required software (Stata 17 or higher).
3. Run the `.do` scripts in the provided order:
   - `data_cleaning.do`
   - `analysis.do`
