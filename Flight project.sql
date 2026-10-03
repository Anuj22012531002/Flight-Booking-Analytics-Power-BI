create database flight_project;
use flight_project;
select * from Dim_Dates;
show tables;

DESCRIBE dim_airlines;

DESCRIBE dim_customers;

DESCRIBE dim_dates;

DESCRIBE dim_flights;

DESCRIBE dim_payments;

DESCRIBE fact_bookings;

SELECT 'dim_airlines' AS table_name, COUNT(*) AS row_count
FROM dim_airlines
UNION ALL
SELECT 'dim_customers', COUNT(*)
FROM dim_customers
UNION ALL
SELECT 'dim_dates', COUNT(*)
FROM dim_dates
UNION ALL
SELECT 'dim_flights', COUNT(*)
FROM dim_flights
UNION ALL
SELECT 'dim_payments', COUNT(*)
FROM dim_payments
UNION ALL
SELECT 'fact_bookings', COUNT(*)
FROM fact_bookings;


DESCRIBE fact_bookings;

SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(Booking_ID) AS Non_Null_Booking_ID,
    COUNT(DISTINCT Booking_ID) AS Unique_Booking_ID
FROM fact_bookings;

SELECT COUNT(*) AS Null_Booking_ID
FROM fact_bookings
WHERE Booking_ID IS NULL;

SELECT 
    Booking_ID,
    COUNT(*) AS Duplicate_Count
FROM fact_bookings
GROUP BY Booking_ID
HAVING COUNT(*) > 1;

ALTER TABLE dim_airlines
ADD PRIMARY KEY (Airline_ID);

ALTER TABLE dim_customers
ADD PRIMARY KEY (Customer_ID);

ALTER TABLE dim_dates
ADD PRIMARY KEY (Date_ID);

ALTER TABLE dim_flights
ADD PRIMARY KEY (Flight_ID);

ALTER TABLE dim_payments
ADD PRIMARY KEY (Payment_ID);	

ALTER TABLE fact_bookings
ADD PRIMARY KEY (Booking_ID);

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'flight_project'
AND CONSTRAINT_NAME = 'PRIMARY';

SELECT COUNT(*) AS Invalid_Customers
FROM fact_bookings f
LEFT JOIN dim_customers c
    ON f.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

SELECT COUNT(*) AS Invalid_Flights
FROM fact_bookings f
LEFT JOIN dim_flights fl
    ON f.Flight_ID = fl.Flight_ID
WHERE fl.Flight_ID IS NULL;

SELECT COUNT(*) AS Invalid_Booking_Dates
FROM fact_bookings f
LEFT JOIN dim_dates d
    ON f.Booking_Date_ID = d.Date_ID
WHERE d.Date_ID IS NULL;

SELECT COUNT(*) AS Invalid_Travel_Dates
FROM fact_bookings f
LEFT JOIN dim_dates d
    ON f.Travel_Date_ID = d.Date_ID
WHERE d.Date_ID IS NULL;

SELECT COUNT(*) AS Invalid_Payments
FROM fact_bookings f
LEFT JOIN dim_payments p
    ON f.Payment_ID = p.Payment_ID
WHERE p.Payment_ID IS NULL;

ALTER TABLE fact_bookings
ADD CONSTRAINT fk_booking_customer
FOREIGN KEY (Customer_ID)
REFERENCES dim_customers(Customer_ID);

ALTER TABLE fact_bookings
ADD CONSTRAINT fk_booking_flight
FOREIGN KEY (Flight_ID)
REFERENCES dim_flights(Flight_ID);

ALTER TABLE fact_bookings
ADD CONSTRAINT fk_booking_date
FOREIGN KEY (Booking_Date_ID)
REFERENCES dim_dates(Date_ID);

ALTER TABLE fact_bookings
ADD CONSTRAINT fk_travel_date
FOREIGN KEY (Travel_Date_ID)
REFERENCES dim_dates(Date_ID);

ALTER TABLE fact_bookings
ADD CONSTRAINT fk_booking_payment
FOREIGN KEY (Payment_ID)
REFERENCES dim_payments(Payment_ID);

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'flight_project'
AND REFERENCED_TABLE_NAME IS NOT NULL;

SELECT
    SUM(Booking_ID IS NULL) AS Booking_ID_NULL,
    SUM(Customer_ID IS NULL) AS Customer_ID_NULL,
    SUM(Flight_ID IS NULL) AS Flight_ID_NULL,
    SUM(Booking_Date_ID IS NULL) AS Booking_Date_ID_NULL,
    SUM(Travel_Date_ID IS NULL) AS Travel_Date_ID_NULL,
    SUM(Payment_ID IS NULL) AS Payment_ID_NULL,
    SUM(Passenger_Count IS NULL) AS Passenger_Count_NULL,
    SUM(Ticket_Class IS NULL) AS Ticket_Class_NULL,
    SUM(Booking_Channel IS NULL) AS Booking_Channel_NULL,
    SUM(Seat_Type IS NULL) AS Seat_Type_NULL,
    SUM(Ticket_Price IS NULL) AS Ticket_Price_NULL,
    SUM(Discount IS NULL) AS Discount_NULL,
    SUM(Final_Amount IS NULL) AS Final_Amount_NULL,
    SUM(Booking_Status IS NULL) AS Booking_Status_NULL
FROM fact_bookings;

## Total Bookings
SELECT 
    COUNT(DISTINCT Booking_ID) AS Total_Bookings
FROM fact_bookings;

## Total Passengers
SELECT 
    SUM(Passenger_Count) AS Total_Passengers
FROM fact_bookings;

## Total Revenue
SELECT 
    SUM(Final_Amount) AS Total_Revenue
FROM fact_bookings;

## Total Ticket Value
SELECT 
    SUM(Ticket_Price) AS Total_Ticket_Value
FROM fact_bookings;

## Total Discount
SELECT 
    SUM(Discount) AS Total_Discount
FROM fact_bookings;

## Average Booking Value
SELECT 
    ROUND(AVG(Final_Amount), 2) AS Average_Booking_Value
FROM fact_bookings;

## Average Ticket Price
SELECT 
    ROUND(AVG(Ticket_Price), 2) AS Average_Ticket_Price
FROM fact_bookings;

## Average Passengers per Booking
SELECT 
    ROUND(AVG(Passenger_Count), 2) AS Avg_Passengers_Per_Booking
FROM fact_bookings;

## Discount Percentage
SELECT 
    ROUND(
        (SUM(Discount) / NULLIF(SUM(Ticket_Price), 0)) * 100,
        2
    ) AS Discount_Percentage
FROM fact_bookings;

## Booking Status Breakdown
SELECT 
    Booking_Status,
    COUNT(*) AS Total_Bookings
FROM fact_bookings
GROUP BY Booking_Status
ORDER BY Total_Bookings DESC;

## Cancellation Rate
SELECT
    ROUND(
        SUM(CASE 
                WHEN Booking_Status = 'Cancelled' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*),
        2
    ) AS Cancellation_Rate
FROM fact_bookings;

## Confirmation Rate
SELECT
    ROUND(
        SUM(CASE 
                WHEN Booking_Status = 'Confirmed' THEN 1 
                ELSE 0 
            END) * 100.0 / COUNT(*),
        2
    ) AS Confirmation_Rate
FROM fact_bookings;

## Revenue per Passenger
SELECT
    ROUND(
        SUM(Final_Amount) / NULLIF(SUM(Passenger_Count), 0),
        2
    ) AS Revenue_Per_Passenger
FROM fact_bookings;

## Revenue Loss Due to Cancellation
SELECT
    SUM(Final_Amount) AS Cancelled_Revenue
FROM fact_bookings
WHERE Booking_Status = 'Cancelled';

## Average Discount per Booking
SELECT
    ROUND(AVG(Discount), 2) AS Avg_Discount_Per_Booking
FROM fact_bookings;

## Revenue by Airline
SELECT
    a.Airline_Name,
    SUM(f.Final_Amount) AS Total_Revenue
FROM fact_bookings f
JOIN dim_flights fl
    ON f.Flight_ID = fl.Flight_ID
JOIN dim_airlines a
    ON fl.Airline_ID = a.Airline_ID
GROUP BY a.Airline_Name
ORDER BY Total_Revenue DESC;

## Airlines with Revenue Greater Than Average
SELECT
    a.Airline_Name,
    SUM(f.Final_Amount) AS Total_Revenue
FROM fact_bookings f
JOIN dim_flights fl
    ON f.Flight_ID = fl.Flight_ID
JOIN dim_airlines a
    ON fl.Airline_ID = a.Airline_ID
GROUP BY a.Airline_Name
HAVING SUM(f.Final_Amount) >
(
    SELECT AVG(Airline_Revenue)
    FROM
    (
        SELECT
            SUM(f2.Final_Amount) AS Airline_Revenue
        FROM fact_bookings f2
        JOIN dim_flights fl2
            ON f2.Flight_ID = fl2.Flight_ID
        JOIN dim_airlines a2
            ON fl2.Airline_ID = a2.Airline_ID
        GROUP BY a2.Airline_Name
    ) x
);
## Sub Query
# Bookings Above Average Booking Value
SELECT
    Booking_ID,
    Final_Amount
FROM fact_bookings
WHERE Final_Amount >
(
    SELECT AVG(Final_Amount)
    FROM fact_bookings
)
ORDER BY Final_Amount DESC;

## Customers with Above-Average Spending
SELECT
    Customer_ID,
    SUM(Final_Amount) AS Customer_Spending
FROM fact_bookings
GROUP BY Customer_ID
HAVING SUM(Final_Amount) >
(
    SELECT AVG(Customer_Spending)
    FROM
    (
        SELECT
            Customer_ID,
            SUM(Final_Amount) AS Customer_Spending
        FROM fact_bookings
        GROUP BY Customer_ID
    ) x
);

## Second Highest Booking Amount
SELECT MAX(Final_Amount) AS Second_Highest_Amount
FROM fact_bookings
WHERE Final_Amount <
(
    SELECT MAX(Final_Amount)
    FROM fact_bookings
);

## Customers Having More Than 5 Bookings
SELECT
    Customer_ID,
    COUNT(*) AS Total_Bookings
FROM fact_bookings
GROUP BY Customer_ID
HAVING COUNT(*) > 5
ORDER BY Total_Bookings DESC;

## CTE
## Customer Revenue Ranking Dataset
WITH customer_revenue AS
(
    SELECT
        Customer_ID,
        SUM(Final_Amount) AS Total_Revenue
    FROM fact_bookings
    GROUP BY Customer_ID
)
SELECT *
FROM customer_revenue
ORDER BY Total_Revenue DESC;

## Top 10 Customers
WITH customer_revenue AS
(
    SELECT
        Customer_ID,
        SUM(Final_Amount) AS Total_Revenue
    FROM fact_bookings
    GROUP BY Customer_ID
)
SELECT *
FROM customer_revenue
ORDER BY Total_Revenue DESC
LIMIT 10;

## Window Function 
## Rank Airlines by Revenue
WITH airline_revenue AS
(
    SELECT
        a.Airline_Name,
        SUM(f.Final_Amount) AS Total_Revenue
    FROM fact_bookings f
    JOIN dim_flights fl
        ON f.Flight_ID = fl.Flight_ID
    JOIN dim_airlines a
        ON fl.Airline_ID = a.Airline_ID
    GROUP BY a.Airline_Name
)
SELECT
    Airline_Name,
    Total_Revenue,
    RANK() OVER (
        ORDER BY Total_Revenue DESC
    ) AS Revenue_Rank
FROM airline_revenue;

## Top 3 Airlines
WITH airline_revenue AS
(
    SELECT
        a.Airline_Name,
        SUM(f.Final_Amount) AS Total_Revenue
    FROM fact_bookings f
    JOIN dim_flights fl
        ON f.Flight_ID = fl.Flight_ID
    JOIN dim_airlines a
        ON fl.Airline_ID = a.Airline_ID
    GROUP BY a.Airline_Name
),
ranked_airlines AS
(
    SELECT
        Airline_Name,
        Total_Revenue,
        DENSE_RANK() OVER (
            ORDER BY Total_Revenue DESC
        ) AS Revenue_Rank
    FROM airline_revenue
)
SELECT *
FROM ranked_airlines
WHERE Revenue_Rank <= 5;

## Running Revenue
WITH daily_revenue AS
(
    SELECT
        Booking_Date_ID,
        SUM(Final_Amount) AS Daily_Revenue
    FROM fact_bookings
    GROUP BY Booking_Date_ID
)
SELECT
    Booking_Date_ID,
    Daily_Revenue,
    SUM(Daily_Revenue) OVER (
        ORDER BY Booking_Date_ID
    ) AS Running_Revenue
FROM daily_revenue
ORDER BY Booking_Date_ID;

## Percentage Contribution 
## Booking Revenue Contribution % 
SELECT
    Booking_ID,
    Final_Amount,
    ROUND(
        Final_Amount * 100.0 /
        SUM(Final_Amount) OVER (),
        2
    ) AS Revenue_Contribution_Percentage
FROM fact_bookings
ORDER BY Revenue_Contribution_Percentage DESC;

## Airline Revenue Contribution %
WITH airline_revenue AS
(
    SELECT
        a.Airline_Name,
        SUM(f.Final_Amount) AS Total_Revenue
    FROM fact_bookings f
    JOIN dim_flights fl
        ON f.Flight_ID = fl.Flight_ID
    JOIN dim_airlines a
        ON fl.Airline_ID = a.Airline_ID
    GROUP BY a.Airline_Name
)
SELECT
    Airline_Name,
    Total_Revenue,
    ROUND(
        Total_Revenue * 100.0 /
        SUM(Total_Revenue) OVER (),
        2
    ) AS Revenue_Contribution_Percentage
FROM airline_revenue
ORDER BY Revenue_Contribution_Percentage DESC;

