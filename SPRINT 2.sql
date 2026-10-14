##################Exercici 1
 CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
    
    
SELECT (SELECT COUNT(*) FROM company) AS total_company,
       (SELECT COUNT(*) FROM transaction) AS total_transaction;
       
       
       
       
##############Exercici 2       
# Lista de países que generan ventas.
SELECT DISTINCT c.country AS pais
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
ORDER BY c.country;

# De la cantidad de ventas de países se generan.
SELECT c.country                AS pais,
       COUNT(*)                 AS num_ventas,
       ROUND(SUM(t.amount), 2)  AS total_ventas
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY num_ventas DESC;


# Identificar la empresa con el promedio de ventas más alto.
SELECT c.company_name             AS empresa,
       ROUND(AVG(t.amount), 2)    AS media_ventas,
       COUNT(*)                   AS num_ventas
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY c.id, c.company_name
ORDER BY media_ventas DESC
LIMIT 1;



#################Exercici 3
# Mostrar todas las transacciones realizadas por empresas en Alemania.
SELECT *
FROM transaction
WHERE company_id IN (
    SELECT id
    FROM company
    WHERE country = 'Germany'
);


# Enumere las empresas que han realizado transacciones por un promedio superior a la media de todas las transacciones
SELECT *
FROM company
WHERE id IN (
    SELECT company_id
    FROM transaction
    WHERE amount > (SELECT AVG(amount) FROM transaction)
);


# Las empresas que no tengan transacciones registradas serán retiradas del sistema, entregando la lista de estas empresas
SELECT *
FROM company c
WHERE NOT EXISTS (
    SELECT 1
    FROM transaction t
    WHERE t.company_id = c.id
);



#########################Ejercici 4
# crear una tabla llamada "credit_card"
USE transactions;

CREATE TABLE If NOT EXISTS credit_card (
id VARCHAR(15) NOT NULL PRIMARY KEY,
iban VARCHAR(34) NOT NULL,
pan VARCHAR(19) NOT NULL,
pin CHAR(4) NOT NULL,
cvv CHAR(3) NOT NULL,
expiring_date VARCHAR(8) NOT NULL
);
###########Aqui  Ejecutas 
ALTER TABLE credit_card
ADD COLUMN expiring_date_date DATE NULL;
UPDATE credit_card
SET expiring_date_date = STR_TO_DATE(expiring_date, '%m/%d/%y');
SELECT COUNT(*) AS fechas_no_convertidas
FROM credit_card
WHERE expiring_date_date IS NULL;

ALTER TABLE credit_card DROP COLUMN expiring_date;
ALTER TABLE credit_card
CHANGE COLUMN expiring_date_date expiring_date DATE NOT NULL;

ALTER TABLE `transaction`
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);




#######################Ejercici 5Exercici 5
USE transactions;

START TRANSACTION;

SELECT * FROM credit_card WHERE id = 'CcU-2938';

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban FROM credit_card WHERE id = 'CcU-2938';  
COMMIT; 


########################Exercici 6
USE transactions;
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES (
    '108B1D1D-5B23-A76C-55EF-C568E49A99DD',
    'CcU-9999',
    'b-9999',
    9999,
    829.999,
    -117.999,
    111.11,
    0
);
SELECT * FROM transaction WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';



#######################Exercici 7

ALTER TABLE credit_card ADD COLUMN pan VARCHAR(25);
DESCRIBE credit_card;


ALTER TABLE credit_card DROP COLUMN pan;
DESCRIBE credit_card;


########################Exercici 8
TRUNCATE TABLE stg_american_users;
TRUNCATE TABLE stg_european_users;
TRUNCATE TABLE stg_companies;
TRUNCATE TABLE stg_credit_cards;
TRUNCATE TABLE stg_transactions;

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

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv'
INTO TABLE stg_credit_cards
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv'
INTO TABLE stg_transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 'american_users' AS tbl, COUNT(*) AS total FROM stg_american_users
UNION ALL SELECT 'european_users', COUNT(*) FROM stg_european_users
UNION ALL SELECT 'companies', COUNT(*) FROM stg_companies
UNION ALL SELECT 'credit_cards', COUNT(*) FROM stg_credit_cards
UNION ALL SELECT 'transactions', COUNT(*) FROM stg_transactions;


USE transactions_dw;

CREATE TABLE dim_user (
    id            INT PRIMARY KEY,
    name          VARCHAR(50),
    surname       VARCHAR(50),
    phone         VARCHAR(30),
    email         VARCHAR(100),
    birth_date    DATE,
    country       VARCHAR(50),
    city          VARCHAR(50),
    postal_code   VARCHAR(20),
    address       VARCHAR(150),
    signup_date   DATE,
    user_segment  VARCHAR(50),
    income_band   VARCHAR(20),
    region        VARCHAR(20)
);

CREATE TABLE dim_company (
    company_id               VARCHAR(15) PRIMARY KEY,
    company_name             VARCHAR(100),
    phone                    VARCHAR(30),
    email                    VARCHAR(100),
    country                  VARCHAR(50),
    website                  VARCHAR(150),
    merchant_category        VARCHAR(50),
    merchant_price_position  VARCHAR(30)
);

CREATE TABLE dim_credit_card (
    id                  VARCHAR(15) PRIMARY KEY,
    user_id             INT,
    iban                VARCHAR(34),
    expiring_date       VARCHAR(8),
    card_type           VARCHAR(30),
    card_renewal_flag   TINYINT,
    FOREIGN KEY (user_id) REFERENCES dim_user(id)
);

CREATE TABLE dim_date (
    date_id      INT PRIMARY KEY,
    full_date    DATE,
    day          INT,
    month        INT,
    quarter      INT,
    year         INT,
    day_of_week  VARCHAR(15),
    is_weekend   BOOLEAN
);

CREATE TABLE fact_transactions (
    id                 VARCHAR(40) PRIMARY KEY,
    card_id            VARCHAR(15),
    company_id         VARCHAR(15),
    user_id            INT,
    date_id            INT,
    `timestamp`        DATETIME,
    amount             DECIMAL(10,2),
    discount_amount    DECIMAL(10,2),
    tax_amount         DECIMAL(10,2),
    shipping_amount    DECIMAL(10,2),
    declined           TINYINT,
    decline_reason     VARCHAR(100),
    channel            VARCHAR(30),
    campaign_id        VARCHAR(50),
    device_type        VARCHAR(30),
    is_international   TINYINT,
    distance_km        DECIMAL(10,2),
    lat                DOUBLE,
    longitude          DOUBLE,
    product_ids        VARCHAR(200),
    FOREIGN KEY (card_id) REFERENCES dim_credit_card(id),
    FOREIGN KEY (company_id) REFERENCES dim_company(company_id),
    FOREIGN KEY (user_id) REFERENCES dim_user(id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);



INSERT INTO transactions_dw.dim_company (company_id, company_name, phone, email, country, website, merchant_category, merchant_price_position)
SELECT company_id, company_name, phone, email, country, website, merchant_category, merchant_price_position
FROM transactions.stg_companies;

INSERT INTO transactions_dw.dim_credit_card (id, user_id, iban, expiring_date, card_type, card_renewal_flag)
SELECT id, user_id, iban, expiring_date, card_type, card_renewal_flag
FROM transactions.stg_credit_cards;


INSERT INTO transactions_dw.dim_date (date_id, full_date, day, month, quarter, year, day_of_week, is_weekend)
SELECT DISTINCT
    CAST(DATE_FORMAT(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s'), '%Y%m%d') AS UNSIGNED),
    DATE(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    DAY(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    MONTH(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    QUARTER(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    YEAR(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    DAYNAME(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')),
    IF(DAYOFWEEK(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s')) IN (1,7), TRUE, FALSE)
FROM transactions.stg_transactions
WHERE `timestamp` IS NOT NULL AND `timestamp` != '';


INSERT INTO transactions_dw.fact_transactions
(id, card_id, company_id, user_id, date_id, `timestamp`, amount, discount_amount, tax_amount, shipping_amount,
 declined, decline_reason, channel, campaign_id, device_type, is_international, distance_km, lat, longitude, product_ids)
SELECT
    id, card_id, business_id, user_id,
    CAST(DATE_FORMAT(STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s'), '%Y%m%d') AS UNSIGNED),
    STR_TO_DATE(`timestamp`, '%Y-%m-%d %H:%i:%s'),
    amount, discount_amount, tax_amount, shipping_amount,
    declined, decline_reason, channel, campaign_id, device_type, is_international,
    distance_km, lat, longitude, product_ids
FROM transactions.stg_transactions;



############################Exercici 9
CREATE DATABASE IF NOT EXISTS transactions_dw;
SELECT *
FROM transactions_dw.dim_user u
WHERE u.id IN (
    SELECT ft.user_id
    FROM transactions_dw.fact_transactions ft
    GROUP BY ft.user_id
    HAVING COUNT(*) > 80
);


########################Exercici 10
SELECT COUNT(*) FROM transactions_dw.dim_user;
SELECT COUNT(*) FROM transactions_dw.dim_company;
SELECT COUNT(*) FROM transactions_dw.dim_credit_card;
SELECT COUNT(*) FROM transactions_dw.fact_transactions;


SELECT cc.iban, ROUND(AVG(ft.amount), 2) AS avg_amount
FROM transactions_dw.fact_transactions ft
JOIN transactions_dw.dim_credit_card cc ON ft.card_id = cc.id
JOIN transactions_dw.dim_company c ON ft.company_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban
ORDER BY avg_amount DESC;



######################Exercici 1-NIVEL2
SELECT dd.full_date,  ROUND(SUM(ft.amount),2) AS total_sales
FROM transactions_dw.fact_transactions ft
JOIN transactions_dw.dim_date dd ON ft.date_id = dd.date_id
WHERE ft.declined = 0
GROUP BY dd.full_date
ORDER BY total_sales DESC
LIMIT 5;

#########################Exercici 2-NIVEL2
SELECT c.company_name, c.phone, c.country, dd.full_date, ft.amount
FROM transactions_dw.fact_transactions ft
JOIN transactions_dw.dim_company c ON ft.company_id = c.company_id
JOIN transactions_dw.dim_date dd ON ft.date_id = dd.date_id
WHERE ft.amount BETWEEN 350 AND 400
  AND dd.full_date IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY ft.amount DESC;


#######################Exercici 3-NIVEL2
SELECT
    c.company_name,
    COUNT(ft.id) AS total_transactions,
    CASE
        WHEN COUNT(ft.id) >= 400 THEN 'Igual o més de 400'
        ELSE 'Menys de 400'
    END AS capacitat
FROM transactions_dw.dim_company c
LEFT JOIN transactions_dw.fact_transactions ft ON c.company_id = ft.company_id
GROUP BY c.company_id, c.company_name
ORDER BY total_transactions DESC;



########################Exercici 4-NIVEL2
DELETE FROM transactions_dw.fact_transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

SELECT * FROM transactions_dw.fact_transactions
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';



###################Exercici 5-NIVEL2
CREATE VIEW transactions_dw.VistaMarketing AS
SELECT
    c.company_name AS Nom_Companyia,
    c.phone AS Telefon,
    c.country AS Pais,
    ROUND(AVG(ft.amount), 2) AS Mitjana_Compra
FROM transactions_dw.dim_company c
JOIN transactions_dw.fact_transactions ft ON c.company_id = ft.company_id
GROUP BY c.company_id, c.company_name, c.phone, c.country
ORDER BY Mitjana_Compra DESC;


SELECT * FROM transactions_dw.VistaMarketing;




##################Exercici 1-NIVEL3
DROP TABLE IF EXISTS credit_card_status;

CREATE TABLE credit_card_status AS
WITH ranked_transactions AS (
    SELECT
        t.card_id,
        t.declined,
        ROW_NUMBER() OVER (PARTITION BY t.card_id ORDER BY t.timestamp DESC) AS rn
    FROM transactions.stg_transactions t
),
card_state AS (
    SELECT
        card_id AS credit_card_id,
        COUNT(*) AS transacciones_ultimas,
        SUM(CASE WHEN declined = 1 THEN 1 ELSE 0 END) AS transacciones_rechazadas
    FROM ranked_transactions
    WHERE rn <= 3
    GROUP BY card_id
)
SELECT
    credit_card_id,
    CASE
        WHEN transacciones_ultimas = 0 THEN 'Sin transacciones'
        WHEN transacciones_ultimas < 3 THEN 'Datos insuficientes'
        WHEN transacciones_rechazadas = 3 THEN 'Inactiva'
        ELSE 'Activa'
    END AS estado,
    transacciones_ultimas,
    transacciones_rechazadas
FROM card_state;

SELECT COUNT(*) AS tarjetas_activas
FROM credit_card_status
WHERE estado = 'Activa';


################Exercici 2-NIVEL3
CREATE TABLE product (
id INT PRIMARY KEY,
product_name VARCHAR(255) NOT NULL,
price DECIMAL(10,2) NOT NULL,
colour CHAR(7),
weight DECIMAL(8,2),
warehouse_id VARCHAR(10),
category VARCHAR(50),
brand VARCHAR(100),
cost DECIMAL(10,2),
launch_date DATE
) ENGINE=InnoDB;
CREATE TABLE transaction_product (
transaction_id VARCHAR(255) NOT NULL,
product_id INT NOT NULL,
PRIMARY KEY (transaction_id, product_id),
FOREIGN KEY (transaction_id) REFERENCES `transaction`(id),
FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB;

