-- Create external table over existing wordcount MapReduce output
CREATE EXTERNAL TABLE wordcount (
  word STRING,
  count INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/hive/warehouse/wordcount';

-- Basic scan (no MapReduce job needed)
SELECT * FROM wordcount;

-- Aggregate query (compiles to a MapReduce job)
SELECT SUM(count) AS total_words FROM wordcount;

-- Sort query (compiles to a MapReduce job)
SELECT * FROM wordcount ORDER BY count DESC;
