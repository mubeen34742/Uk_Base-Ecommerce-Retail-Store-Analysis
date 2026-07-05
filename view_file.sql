CREATE TABLE retail_raw (
    invoice_no VARCHAR(50),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INT,
    invoice_date DATE,
    unit_price DECIMAL(10,2),
    customer_id VARCHAR(50),
    country VARCHAR(100),
    revenue DECIMAL(10,2),
    year INT,
    month INT,
    day_of_week VARCHAR(20),
    hour INT,
    total_order INT,
    customer_type VARCHAR(50)
);

CREATE TABLE dim_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_segment VARCHAR(50),
    country VARCHAR(100),
    first_purchase_date DATE,
    lifetime_value DECIMAL(12,2)
);

CREATE TABLE dim_products (
    product_id serial  PRIMARY KEY,
    stock_code VARCHAR(50),
    description TEXT,
    category VARCHAR(100),
    avg_price DECIMAL(10,2)
);

CREATE TABLE dim_date (
    date_id serial PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter_no INT,
    month_no INT,
    month_name VARCHAR(20),
    week_no INT,
    day_of_week VARCHAR(20),
    is_weekend BOOLEAN
);

CREATE TABLE dim_country (
    country_id serial PRIMARY KEY,
    country_name VARCHAR(100),
    region VARCHAR(100),
    continent VARCHAR(100),
    currency VARCHAR(50)
);

CREATE TABLE fact_returns (
    return_id serial PRIMARY KEY,
    invoice_no VARCHAR(50),
    customer_id VARCHAR(50),
    product_id INT,
    return_qty INT,
    return_revenue DECIMAL(10,2)
);

CREATE TABLE fact_orders (
    order_id serial PRIMARY KEY,
    customer_id VARCHAR(50),
    product_id INT,
    date_id INT,
    country_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    revenue DECIMAL(10,2),

    FOREIGN KEY (customer_id)
        REFERENCES dim_customers(customer_id),

    FOREIGN KEY (product_id)
        REFERENCES dim_products(product_id),

    FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id),

    FOREIGN KEY (country_id)
        REFERENCES dim_country(country_id)
);

INSERT INTO dim_customers (
    customer_id,
    customer_segment,
    country,
    first_purchase_date,
    lifetime_value
)
SELECT
    customer_id,
    MAX(customer_type),
    MAX(country),
    MIN(invoice_date),
    SUM(revenue)
FROM retail_raw
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

INSERT INTO dim_products (
    stock_code,
    description,
    category,
    avg_price
)
SELECT
    stock_code,
    description,
    'General',
    AVG(unit_price)
FROM retail_raw
GROUP BY stock_code, description;


INSERT INTO dim_date (
    full_date,
    year,
    quarter_no,
    month_no,
    month_name,
    week_no,
    day_of_week,
    is_weekend
)

SELECT DISTINCT
    invoice_date,
    EXTRACT(YEAR FROM invoice_date),
    EXTRACT(QUARTER FROM invoice_date),
    EXTRACT(MONTH FROM invoice_date),
    TO_CHAR(invoice_date, 'Month'),
    EXTRACT(WEEK FROM invoice_date),
    TO_CHAR(invoice_date, 'Day'),
    CASE
        WHEN TO_CHAR(invoice_date, 'Day') IN ('Saturday ', 'Sunday   ')
        THEN TRUE
        ELSE FALSE
    END
FROM retail_raw;


INSERT INTO dim_country (
    country_name,
    region,
    continent,
    currency
)
SELECT DISTINCT
    country,
    'Unknown',
    'Unknown',
    'Unknown'
FROM retail_raw;

INSERT INTO fact_orders (
    customer_id,
    product_id,
    date_id,
    country_id,
    quantity,
    unit_price,
    revenue
)
SELECT
    r.customer_id,
    p.product_id,
    d.date_id,
    c.country_id,
    r.quantity,
    r.unit_price,
    r.revenue
FROM retail_raw r
JOIN dim_products p
    ON r.stock_code = p.stock_code
JOIN dim_date d
    ON r.invoice_date = d.full_date
JOIN dim_country c
    ON r.country = c.country_name;

WITH monthly_revenue AS (

    SELECT
        d.year,
        d.month_no,

        SUM(f.revenue) AS total_revenue

    FROM fact_orders f

    JOIN dim_date d
    ON f.date_id = d.date_id

    GROUP BY
        d.year,
        d.month_no
)

SELECT
    year,
    month_no,

    ROUND(total_revenue,2),

    ROUND(
        LAG(total_revenue)
        OVER (
            ORDER BY year, month_no
        ),
        2
    ) AS previous_month,

    ROUND(
        (
            (
                total_revenue
                -
                LAG(total_revenue)
                OVER (
                    ORDER BY year, month_no
                )
            )
            /
            LAG(total_revenue)
            OVER (
                ORDER BY year, month_no
            )
        ) * 100,
        2
    ) AS mom_growth_percent

FROM monthly_revenue;

WITH customer_rfm AS (

    SELECT
        c.customer_id,

        CURRENT_DATE
        -
        MAX(d.full_date::DATE) AS recency,

        COUNT(f.order_id) AS frequency,

        SUM(f.revenue) AS monetary

    FROM dim_customers c

    JOIN fact_orders f
    ON c.customer_id = f.customer_id

    JOIN dim_date d
    ON f.date_id = d.date_id

    GROUP BY c.customer_id
),

rfm_scores AS (

    SELECT
        customer_id,

        recency,
        frequency,
        monetary,

        NTILE(4)
        OVER (ORDER BY recency DESC)
        AS recency_score,

        NTILE(4)
        OVER (ORDER BY frequency)
        AS frequency_score,

        NTILE(4)
        OVER (ORDER BY monetary)
        AS monetary_score

    FROM customer_rfm
)

SELECT
    customer_id,

    recency,
    frequency,
    monetary,

    CASE

        WHEN (
            recency_score +
            frequency_score +
            monetary_score
        ) >= 10

        THEN 'Platinum'

        WHEN (
            recency_score +
            frequency_score +
            monetary_score
        ) >= 8

        THEN 'Gold'

        WHEN (
            recency_score +
            frequency_score +
            monetary_score
        ) >= 6

        THEN 'Silver'

        ELSE 'Bronze'

    END AS customer_segment

FROM rfm_scores;

WITH product_revenue AS (

    SELECT
        c.country_name,

        p.description,

        SUM(f.revenue) AS total_revenue

    FROM fact_orders f

    JOIN dim_products p
    ON f.product_id = p.product_id

    JOIN dim_country c
    ON f.country_id = c.country_id

    GROUP BY
        c.country_name,
        p.description
)

SELECT *

FROM (

    SELECT
        country_name,

        description,

        ROUND(total_revenue,2),

        RANK()
        OVER (
            PARTITION BY country_name
            ORDER BY total_revenue DESC
        ) AS rank_no

    FROM product_revenue

) ranked

WHERE rank_no <= 10;

SELECT
    c.country_name,

    SUM(f.revenue) AS country_revenue,

    ROUND(
        (
            SUM(f.revenue)
            /
            SUM(SUM(f.revenue))
            OVER ()
        ) * 100,
        2
    ) AS revenue_share_percent

FROM fact_orders f

JOIN dim_country c
ON f.country_id = c.country_id

GROUP BY c.country_name;