
-- Create a table to hold review data from JSON file
CREATE TABLE public.reviews (
    review_id varchar(22),
    user_id varchar(22),
    business_id varchar(22),
    stars int,
    review_date date,
    review_text varchar,
    useful int,
    funny int,
    cool int
    );

-- Create a temporary table to store JSON data
CREATE TEMPORARY TABLE public.my_temp_table (json_data VARIANT);

-- Copy JSON data from S3 to temp table
COPY INTO my_temp_table
FROM '@S3_YELP_STAGE/yelp_academic_dataset_review.json'
FILE_FORMAT = (TYPE = 'JSON');

-- Populate table with data from JSON temp table
INSERT INTO public.REVIEWS (REVIEW_ID, USER_ID, BUSINESS_ID, STARS, REVIEW_DATE, REVIEW_TEXT, USEFUL, FUNNY, COOL)
SELECT
    json_data:review_id::VARCHAR(22),
    json_data:user_id::VARCHAR(22),
    json_data:business_id::VARCHAR(22),
    json_data:stars::INT,
    json_data:date::DATE,
    json_data:text::VARCHAR,
    json_data:useful::INT,
    json_data:funny::INT,
    json_data:cool::INT
FROM my_temp_table;

-- Drop temp table
DROP TABLE public.my_temp_table;

-- Create a table to hold business data from JSON file
CREATE TABLE public.business (
    business_id varchar(22),
    name varchar,
    address varchar,
    city varchar,
    state varchar,
    postal_code varchar,
    latitude float,
    longitude float,
    stars float,
    review_count int,
    is_open int,
    takeout varchar,
    garage_parking varchar,
    street_parking varchar,
    validated_parking varchar,
    lot_parking varchar,
    valet_parking varchar,
    categories variant,
    hours_monday varchar,
    hours_tuesday varchar,
    hours_wednesday varchar,
    hours_thursday varchar,
    hours_friday varchar,
    hours_saturday varchar,
    hours_sunday varchar
    );

-- Copy business json data into temporary table
COPY INTO my_temp_table
FROM '@S3_YELP_STAGE/yelp_academic_dataset_business.json'
FILE_FORMAT = (TYPE = 'JSON');

-- Populate table with data from JSON temp table
INSERT INTO public.BUSINESS (BUSINESS_ID,
NAME,
ADDRESS,
CITY,
STATE,
POSTAL_CODE,
LATITUDE,
LONGITUDE,
STARS,
REVIEW_COUNT,
IS_OPEN,
TAKEOUT,
GARAGE_PARKING,
STREET_PARKING,
VALIDATED_PARKING,
LOT_PARKING,
VALET_PARKING,
CATEGORIES,
HOURS_MONDAY, 
HOURS_TUESDAY,
HOURS_WEDNESDAY,
HOURS_THURSDAY,
HOURS_FRIDAY,
HOURS_SATURDAY,
HOURS_SUNDAY
)
SELECT
    json_data:business_id::VARCHAR(22),
    json_data:name::VARCHAR,
    json_data:address::VARCHAR,
    json_data:city::VARCHAR,
    json_data:state::VARCHAR,
    json_data:postal_code::VARCHAR,
    json_data:latitude::FLOAT,
    json_data:longitude::FLOAT,
    json_data:stars::FLOAT,
    json_data:review_count::INT,
    json_data:is_open::INT,
    json_data:attributes:takeout::VARCHAR,
    json_data:attributes:garage::VARCHAR,
    json_data:attributes:street::VARCHAR,
    json_data:attributes:validated::VARCHAR,
    json_data:attributes:lot::VARCHAR,
    json_data:attributes:valet::VARCHAR,
    json_data:categories::VARIANT,
    json_data:hours:Monday::VARCHAR,
    json_data:hours:Tuesday::VARCHAR,
    json_data:hours:Wednesday::VARCHAR,
    json_data:hours:Thursday::VARCHAR,
    json_data:hours:Friday::VARCHAR,
    json_data:hours:Saturday::VARCHAR,
    json_data:hours:Sunday::VARCHAR
FROM my_temp_table;


CREATE TABLE public.users (
    user_id varchar(22),
    name varchar,
    review_count int,
    yelping_since date,
    useful int,
    funny int,
    cool int,
    fans int,
    average_stars float,
    compliment_hot int,
    compliment_more int,
    compliment_profile int,
    compliment_cute int,
    compliment_list int,
    compliment_note int,
    compliment_plain int,
    compliment_cool int,
    compliment_funny int,
    compliment_writer int,
    compliment_photos int
    );

INSERT INTO public.USERS (USER_ID, NAME, REVIEW_COUNT, YELPING_SINCE, USEFUL, FUNNY, COOL, FANS, AVERAGE_STARS, COMPLIMENT_HOT, COMPLIMENT_MORE, COMPLIMENT_PROFILE, COMPLIMENT_CUTE, COMPLIMENT_LIST, COMPLIMENT_NOTE, COMPLIMENT_PLAIN, COMPLIMENT_COOL, COMPLIMENT_FUNNY, COMPLIMENT_WRITER, COMPLIMENT_PHOTOS)
SELECT
json_data:user_id::VARCHAR(22),
json_data:name::VARCHAR,
json_data:review_count::INT,
json_data:yelping_since::DATE,
json_data:useful::INT,
json_data:funny::INT,
json_data:cool::INT,
json_data:fans::INT,
json_data:average_stars::FLOAT,
json_data:compliment_hot::INT,
json_data:compliment_more::INT,
json_data:compliment_profile::INT,
json_data:compliment_cute::INT,
json_data:compliment_list::INT,
json_data:compliment_note::INT,
json_data:compliment_plain::INT,
json_data:compliment_cool::INT,
json_data:compliment_funny::INT,
json_data:compliment_writer::INT,
json_data:compliment_photos::INT
FROM my_temp_table;


CREATE TABLE public.checkins (
  business_id VARCHAR(22),
  checkin_date TIMESTAMP
);

CREATE TEMPORARY TABLE my_temp_table (
  json_data VARIANT
);

COPY INTO my_temp_table
FROM '@S3_YELP_STAGE/yelp_academic_dataset_checkin.json'
FILE_FORMAT = (TYPE = 'JSON');


INSERT INTO public.checkins (business_id, checkin_date)
SELECT
  json_data:business_id::VARCHAR(22),
  TO_TIMESTAMP(TRIM(split_dates.value::STRING), 'YYYY-MM-DD HH24:MI:SS')
FROM my_temp_table,
LATERAL FLATTEN(input => SPLIT(json_data:date::STRING, ',')) AS split_dates;


-- Create a temporary table to store JSON data
CREATE TEMPORARY TABLE public.my_temp_table (json_data VARIANT);

-- Copy JSON data from S3 to temp table
COPY INTO my_temp_table
FROM '@S3_YELP_STAGE/yelp_academic_dataset_tip.json'
FILE_FORMAT = (TYPE = 'JSON');

CREATE TABLE public.tips (
    user_id varchar(22),
    business_id varchar(22),
    text varchar,
    date date,
    compliment_count int
    );

INSERT INTO public.tips (USER_ID, BUSINESS_ID, TEXT, DATE, COMPLIMENT_COUNT)
SELECT
    json_data:user_id::VARCHAR(22),
    json_data:business_id::VARCHAR(22),
    json_data:text::VARCHAR,
    json_data:date::DATE,
    json_data:compliment_count::INT
FROM my_temp_table;


SELECT COUNT(*) as total_values_count
FROM public.business,
LATERAL FLATTEN(input => categories) AS flattened_categories;

SELECT flattened_categories.value AS category, COUNT(*) as count
FROM public.business,
LATERAL FLATTEN(input => categories) AS flattened_categories
GROUP BY flattened_categories.value
ORDER BY count DESC;

SELECT TRIM(flattened_categories.value) AS category, COUNT(*) as count
FROM public.business,
LATERAL FLATTEN(input => SPLIT(categories::STRING, ',')) AS flattened_categories
GROUP BY TRIM(flattened_categories.value)
ORDER BY count DESC;


SELECT * 
FROM PUBLIC.REVIEWS LEFT JOIN PUBLIC.BUSINESS ON PUBLIC.REVIEWS.BUSINESS_ID = PUBLIC.BUSINESS.BUSINESS_ID
WHERE CONTAINS(CATEGORIES, 'Restaurants');

ALTER TABLE PC_HEX_DB.PUBLIC.REVIEW_SENTIMENT RENAME TO YELP_REVIEWS.PUBLIC.REVIEW_SENTIMENT;


CREATE TABLE public.sentiments AS
SELECT 
    review_id,
    sentiment
FROM public.review_sentiment;


DROP TABLE public.review_sentiment;

