-- Databricks notebook source
WITH CTE1 AS (
SELECT UserID,

-- Checking of blanks in the name column
--Name

   CASE
         WHEN Name IS NULL OR Name IN (' ', 'None') THEN 'Unknown name'
         ELSE Name
         END AS Customer_name,

---Surname 
      CASE
            WHEN Surname IS NULL OR Surname IN ('', ' ', 'None') THEN 'Unknown surname'
            ELSE Surname
            END AS Customer_surname,

---- Checking for blanks in the gender column

CASE
        WHEN Gender IS NULL OR Gender IN (' ', 'None') THEN 'Unknown Gender'
        ELSE Gender
        END AS Gender_group,

------ Checking for blanks in the race column
     
   CASE
          WHEN Race IS NULL OR Race IN (' ', 'None') THEN 'No Race'
          ELSE Race
          END AS Ethnic_group,  
     
--Age buckets 

CASE
     WHEN Age BETWEEN 0 AND 11 THEN 'Young Child'
     WHEN Age BETWEEN 12 AND 17 THEN 'Teenagers' 
     WHEN Age BETWEEN 18 AND 24 THEN 'Young Adults'
     WHEN Age BETWEEN 25 AND 34 THEN 'Adults'
     WHEN Age BETWEEN 35 AND 44 THEN 'Middle-Aged Adults'
     WHEN Age BETWEEN 45 AND 54 THEN 'Mature Adults'
     WHEN Age BETWEEN 55 AND 64 THEN 'Older Adults'
     WHEN Age >= 65 THEN 'Pensioner'
     ELSE 'Unknown'
     END AS Age_buckets,

--Provinces
 
CASE
          WHEN Province IS NULL OR Province IN (' ', 'None') THEN 'Unknown Province'
          ELSE Province
          END AS Region, 
     
---Social media handle

CASE
          WHEN `Social Media Handle` IS NULL OR `Social Media Handle` IN ('', ' ', 'None') THEN 'No social handle'
          ELSE `Social Media Handle`
          END AS Social_group
FROM brightlearn.bright_tv.user_profiles),

------Viewership------------------------
CTE2 AS (
       SELECT 
       COALESCE(UserID0,userid4) AS UserID,
         
---Date Functions
DAYNAME(TO_DATE(RecordDate2))AS Day_name,
DAYOFWEEK(TO_DATE(RecordDate2))AS Number_of_day,
DATE_FORMAT(TO_DATE(RecordDate2),'yyyyMM') AS Month_id,
DATE_FORMAT(TO_DATE(RecordDate2),'MMMM') AS Month_name,
TO_DATE(RecordDate2) AS Actual_Date,


-- Convert UTC to South African Time
        FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg') AS SAST_RecordTime,

        -- Display Watch Time in SAST
        DATE_FORMAT(
            FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg'),
            'HH:mm:ss'
        ) AS Watch_time,

---Weekend vs Weekday
    CASE
         WHEN DAYNAME(TO_DATE(RecordDate2)) IN ('Sat','Sun') THEN 'Weekend'
         ELSE 'Weekday'
         END AS Day_classification,

--Converting duration to mintues
             (
            CAST(DATE_FORMAT(`Duration 2`, 'HH') AS INT) * 3600+
            CAST(DATE_FORMAT(`Duration 2`, 'mm') AS INT) * 60+
            CAST(DATE_FORMAT(`Duration 2`, 'ss') AS INT)
        ) / 60.0 AS Duration_minutes,

--Converting duration to seconds
         (
            CAST(DATE_FORMAT(`Duration 2`, 'HH') AS INT) * 3600+
            CAST(DATE_FORMAT(`Duration 2`, 'mm') AS INT) * 60+
            CAST(DATE_FORMAT(`Duration 2`, 'ss') AS INT)
        ) AS Duration_seconds,

---Duration buckets
CASE
    WHEN duration_minutes BETWEEN 0 AND 30 THEN 'Short Viewing'
    WHEN duration_minutes BETWEEN 31 AND 60 THEN 'Medium Viewing'
    WHEN duration_minutes BETWEEN 61 AND 90 THEN 'Long Viewing'
    WHEN duration_minutes BETWEEN 91 AND 120 THEN 'Extended Viewing'
    WHEN duration_minutes >= 120 THEN 'Very Extended Viewing'
    ELSE 'Unknown'
    END AS Duration_bucket,

--Channels 
CASE
     WHEN Channel2 IN('Sawsee','SawSee') THEN 'Sawsee'
     ELSE Channel2
     END AS Channels_subscriptions,

--- Creating time buckets 
CASE 
     WHEN HOUR(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) BETWEEN 0 AND 5
                THEN 'Early Morning'
            WHEN HOUR(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) BETWEEN 6 AND 11
                THEN 'Morning'
            WHEN HOUR(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) BETWEEN 12 AND 16
                THEN 'Afternoon'
            WHEN HOUR(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) BETWEEN 17 AND 20
                THEN 'Evening'
            WHEN HOUR(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) BETWEEN 21 AND 23
                THEN 'Night'
        END AS Time_buckets
        FROM brightlearn.bright_tv.viewership
)

----Joining tables
SELECT COALESCE(A.userid,B.userid) AS sub_id,
A.Customer_name,
A.Customer_surname,
A.Gender_group,
A.Ethnic_group,
A.Age_buckets,
A.Region,
A.Social_group,
B.Day_name,
B.Number_of_day,
B.Month_id,
B.Month_name,
B.Actual_Date,
B.SAST_RecordTime,
B.Watch_time,
B.Day_classification,
B.Duration_minutes,
B.Duration_seconds,
B.Duration_bucket,
B.Channels_subscriptions,
B.Time_buckets
FROM CTE1 A
LEFT JOIN CTE2 B
ON A.UserID = B.UserID;

----------------------------------------------------------------------------------------       
                    -------END OF THE FINAL CODE-------
----------------------------------------------------------------------------------------



     




















