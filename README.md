# UK E-Commerce Retail Data Warehouse Project

## Overview

This project demonstrates an end-to-end retail analytics workflow using Python, SQL, and Excel. The objective is to clean raw UK e-commerce transaction data, engineer business features, and build a dimensional data warehouse for reporting and analytics.

The project covers:

- Data Profiling
- Data Cleaning
- Feature Engineering
- Data Warehousing
- ETL Concepts
- Retail Analytics

---

## Project Structure

```
├── data
│   ├── raw.csv
│   └── clean_sheet.py

├── python
│   ├── clean_sheet.py
│   ├── clean_sheet.csv
│   └── profiling_log.xlsx

├── sql
│   ├── tables.sql
│   ├── values_insert.sql
│   ├── retail_dw_project.sql
│   └── view_file.sql

└── Excel.xlsx
```

---

## Technologies Used

- Python
- Pandas
- NumPy
- PostgreSQL / SQL
- Microsoft Excel

---

## Data Cleaning Process

The Python ETL script performs the following operations:

### Data Profiling

- Dataset shape analysis
- Data type inspection
- Missing value detection
- Duplicate detection
- Statistical summary generation

### Data Quality Improvements

- Convert InvoiceDate to datetime
- Convert Quantity and UnitPrice to numeric format
- Remove negative and invalid transactions
- Handle missing Customer IDs
- Standardize country names
- Clean product descriptions
- Remove duplicate records

### Feature Engineering

Additional business fields were created:

- Revenue
- Year
- Month
- Day Of Week
- Hour
- Total Order Volume
- Customer Type (B2B / B2C)

---

## Customer Segmentation Logic

Customers are classified based on order volume:

| Order Volume | Segment |
|-------------|----------|
| >= 100 | B2B |
| < 100 | B2C |

---

## Data Warehouse Design

The project follows a dimensional modeling approach.

### Fact Table

#### Fact Orders

Stores transaction-level sales data.

---

### Dimension Tables

#### Dim Customers

Contains customer information:

- Customer ID
- Customer Segment
- Country
- First Purchase Date
- Lifetime Value

#### Dim Products

Contains product information:

- Product ID
- Stock Code
- Description
- Category
- Average Price

#### Dim Date

Contains calendar attributes:

- Year
- Quarter
- Month
- Week
- Day Of Week
- Weekend Indicator

#### Dim Country

Contains geographical information:

- Country Name
- Region
- Continent
- Currency

---

## ETL Workflow

### Step 1

Load raw retail dataset.

### Step 2

Profile and assess data quality.

### Step 3

Clean and transform data using Python.

### Step 4

Export cleaned dataset.

### Step 5

Load data into SQL staging table.

### Step 6

Populate dimension tables.

### Step 7

Populate fact tables.

### Step 8

Perform analytical reporting queries.

---

## Business Metrics

The project enables analysis of:

- Total Revenue
- Monthly Revenue Trends
- Customer Lifetime Value
- Product Performance
- Country-Wise Sales
- Customer Segmentation
- Order Volume Analysis

---

## Learning Outcomes

This project demonstrates practical skills in:

- Data Cleaning
- Data Transformation
- Feature Engineering
- SQL Data Warehousing
- Star Schema Design
- ETL Development
- Business Intelligence Preparation

---

## Author

**Mubeen Azam**

ADP Computer Science Student | Data Analytics Enthusiast

Skills:
- Python
- SQL
- Excel
- Power BI
- Data Analysis
- Data Warehousing
