-- ============================================================================
-- ۱. ایجاد پایگاه داده و تنظیمات اولیه
-- ============================================================================
CREATE DATABASE IF NOT EXISTS transactions_dw;
USE transactions_dw;

-- ============================================================================
-- ۲. ساخت جدول‌های Staging (مرحله آماده‌سازی)
-- ============================================================================
DROP TABLE IF EXISTS stg_american_users;
CREATE TABLE stg_american_users (
    id INT,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(150),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(20)
);

DROP TABLE IF EXISTS stg_european_users;
CREATE TABLE stg_european_users (
    id INT,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date VARCHAR(20),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(150),
    signup_date VARCHAR(20),
    user_segment VARCHAR(50),
    income_band VARCHAR(20)
);

DROP TABLE IF EXISTS stg_companies;
CREATE TABLE stg_companies (
    company_id VARCHAR(15),
    company_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(150),
    merchant_category VARCHAR(50),
    merchant_price_position VARCHAR(30)
);

DROP TABLE IF EXISTS stg_credit_cards;
CREATE TABLE stg_credit_cards (
    id VARCHAR(15),
    user_id INT,
    iban VARCHAR(34),
    expiring_date VARCHAR(15),
    card_type VARCHAR(30),
    card_renewal_flag TINYINT
);

DROP TABLE IF EXISTS stg_transactions;
CREATE TABLE stg_transactions (
    id VARCHAR(40),
    card_id VARCHAR(15),
    business_id VARCHAR(15),
    user_id INT,
    `timestamp` VARCHAR(30),
    amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    declined TINYINT,
    decline_reason VARCHAR(100),
    channel VARCHAR(30),
    campaign_id VARCHAR(50),
    device_type VARCHAR(30),
    is_international TINYINT,
    distance_km DECIMAL(10,2),
    lat DOUBLE,
    longitude DOUBLE,
    product_ids VARCHAR(200)
);

-- ============================================================================
-- ۳. بارگذاری داده‌ها از فایل‌های CSV به جدول‌های Staging
-- ============================================================================
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__american_users.csv'
INTO TABLE stg_american_users
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__european_users.csv'
INTO TABLE stg_european_users
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__companies.csv'
INTO TABLE stg_companies
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


DROP TABLE IF EXISTS stg_credit_cards;

CREATE TABLE stg_credit_cards (
    id VARCHAR(255),
    user_id VARCHAR(255),
    iban VARCHAR(255),
    expiring_date VARCHAR(255),
    card_type VARCHAR(255),
    card_renewal_flag VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv'
INTO TABLE stg_credit_cards
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ============================================================================
-- ۴. ساخت جدول‌های مدل ابعادی (Star Schema)
-- ============================================================================
DROP TABLE IF EXISTS fact_transactions;
DROP TABLE IF EXISTS dim_credit_card;
DROP TABLE IF EXISTS dim_company;
DROP TABLE IF EXISTS dim_user;
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_user (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date DATE,
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(150),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(20),
    region VARCHAR(20) -- نام ستون دقیقا مطابق با کد ثبت شده
);

CREATE TABLE dim_company (
    company_id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(30),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(150),
    merchant_category VARCHAR(50),
    merchant_price_position VARCHAR(30)
);

CREATE TABLE dim_credit_card (
    id VARCHAR(15) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(34),
    expiring_date VARCHAR(15), -- هماهنگ شده با نوع داده واقعی
    card_type VARCHAR(30),
    card_renewal_flag TINYINT,
    FOREIGN KEY (user_id) REFERENCES dim_user(id)
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    quarter INT,
    year INT,
    day_of_week VARCHAR(15),
    is_weekend BOOLEAN
);

CREATE TABLE fact_transactions (
    id VARCHAR(40) PRIMARY KEY,
    card_id VARCHAR(15),
    company_id VARCHAR(15),
    user_id INT,
    date_id INT,
    `timestamp` DATETIME,
    amount DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    shipping_amount DECIMAL(10,2),
    declined TINYINT,
    decline_reason VARCHAR(100),
    channel VARCHAR(30),
    campaign_id VARCHAR(50),
    device_type VARCHAR(30),
    is_international TINYINT,
    distance_km DECIMAL(10,2),
    lat DOUBLE,
    longitude DOUBLE,
    product_ids VARCHAR(200), -- حفظ شده طبق ساختار شما
    FOREIGN KEY (card_id) REFERENCES dim_credit_card(id),
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY (user_id) REFERENCES dim_user(id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

-- ============================================================================
-- ۵. بارگذاری داده‌ها به مدل نهایی (با رعایت اولویت کلیدهای خارجی)
-- ============================================================================

-- ۱-۵. بارگذاری کاربران (ترکیب کاربران آمریکا و اروپا)
INSERT INTO dim_user (id, name, surname, phone, email, birth_date, country, city, postal_code, address, signup_date, user_segment, income_band, region)
SELECT 
    id, name, surname, phone, email, 
    STR_TO_DATE(birth_date, '%Y-%m-%d'), 
    country, city, postal_code, address, 
    STR_TO_DATE(signup_date, '%Y-%m-%d'), 
    user_segment, income_band, 'US' AS region
FROM stg_american_users
UNION ALL
SELECT 
    id, name, surname, phone, email, 
    STR_TO_DATE(birth_date, '%Y-%m-%d'), 
    country, city, postal_code, address, 
    STR_TO_DATE(signup_date, '%Y-%m-%d'), 
    user_segment, income_band, 'EU' AS region
FROM stg_european_users;

-- ۲-۵. بارگذاری شرکت‌ها
INSERT INTO dim_company (company_id, company_name, phone, email, country, website, merchant_category, merchant_price_position)
SELECT company_id, company_name, phone, email, country, website, merchant_category, merchant_price_position
FROM stg_companies;

-- بررسی عدم وجود کاربر مفقود پیش از بارگذاری کارت‌ها:
SELECT DISTINCT s.user_id
FROM stg_credit_cards AS s
LEFT JOIN dim_user AS u ON u.id = s.user_id
WHERE s.user_id IS NOT NULL AND u.id IS NULL;

-- ۳-۵. بارگذاری کارت‌های اعتباری
INSERT INTO dim_credit_card (id, user_id, iban, expiring_date, card_type, card_renewal_flag)
SELECT id, user_id, iban, expiring_date, card_type, card_renewal_flag
FROM stg_credit_cards;

-- ۴-۵. بارگذاری تقویم (dim_date)
INSERT INTO dim_date (date_id, full_date, day, month, quarter, year, day_of_week, is_weekend)
SELECT DISTINCT
    CAST(DATE_FORMAT(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s'), '%Y%m%d') AS UNSIGNED),
    DATE(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    DAY(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    MONTH(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    QUARTER(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    YEAR(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    DAYNAME(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    IF(DAYOFWEEK(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')) IN (1,7), TRUE, FALSE)
FROM stg_transactions
WHERE `timestamp` IS NOT NULL AND `timestamp` != '';

-- ۵-۵. بارگذاری تراکنش‌ها (fact_transactions)
INSERT INTO fact_transactions
(id, card_id, company_id, user_id, date_id, `timestamp`, amount, discount_amount, tax_amount, shipping_amount,
 declined, decline_reason, channel, campaign_id, device_type, is_international, distance_km, lat, longitude, product_ids)
SELECT
    id, card_id, business_id, user_id,
    CAST(DATE_FORMAT(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s'), '%Y%m%d') AS UNSIGNED),
    STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s'),
    amount, discount_amount, tax_amount, shipping_amount,
    declined, decline_reason, channel, campaign_id, device_type, is_international,
    distance_km, lat, longitude, product_ids
FROM stg_transactions;

-- ============================================================================
-- ۶. تایید و شمارش ردیف‌های درج‌شده
-- ============================================================================
SELECT 'dim_user' AS tabla, COUNT(*) AS filas FROM dim_user
UNION ALL
SELECT 'dim_company', COUNT(*) FROM dim_company
UNION ALL
SELECT 'dim_credit_card', COUNT(*) FROM dim_credit_card
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_transactions', COUNT(*) FROM fact_transactions;