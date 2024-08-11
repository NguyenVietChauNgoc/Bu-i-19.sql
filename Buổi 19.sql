
EX3 
SELECT
  contactfullname,
  INITCAP(contactfullname) AS chuan_hoa,
  CASE 
    WHEN POSITION('-' IN INITCAP(contactfullname)) > 0 
    THEN SUBSTRING(INITCAP(contactfullname) FROM 1 FOR POSITION('-' IN INITCAP(contactfullname)) - 1) 
    ELSE INITCAP(contactfullname) 
  END AS firstname,
  CASE 
    WHEN POSITION('-' IN INITCAP(contactfullname)) > 0 
    THEN SUBSTRING(INITCAP(contactfullname) FROM POSITION('-' IN INITCAP(contactfullname)) + 1) 
    ELSE NULL
  END AS lastname
FROM
  public.sales_dataset_rfm_prj;

ex2
SELECT
  ordernumber,
  quantityordered,
  priceeach,
  orderlinenumber,
  sales,
  orderdate,
  CASE 
    WHEN ordernumber IS NULL OR TRIM(ordernumber) = '' THEN 'ORDERNUMBER is NULL or BLANK'
    ELSE 'ORDERNUMBER is valid'
  END AS ordernumber_status,
  CASE 
    WHEN quantityordered IS NULL OR TRIM(quantityordered) = '' THEN 'QUANTITYORDERED is NULL or BLANK'
    ELSE 'QUANTITYORDERED is valid'
  END AS quantityordered_status,
  CASE 
    WHEN priceeach IS NULL OR TRIM(priceeach) = '' THEN 'PRICEEACH is NULL or BLANK'
    ELSE 'PRICEEACH is valid'
  END AS priceeach_status,
  CASE 
    WHEN orderlinenumber IS NULL OR TRIM(orderlinenumber) = '' THEN 'ORDERLINENUMBER is NULL or BLANK'
    ELSE 'ORDERLINENUMBER is valid'
  END AS orderlinenumber_status,
  CASE 
    WHEN sales IS NULL OR TRIM(sales) = '' THEN 'SALES is NULL or BLANK'
    ELSE 'SALES is valid'
  END AS sales_status,
  CASE 
    WHEN orderdate IS NULL OR TRIM(orderdate) = '' THEN 'ORDERDATE is NULL or BLANK'
    ELSE 'ORDERDATE is valid'
  END AS orderdate_status
FROM
  public.sales_dataset_rfm_prj;
ex4 
SELECT
  orderdate,
  TO_DATE(SUBSTRING(orderdate FROM 1 FOR 10), 'MM/DD/YYYY') AS chuyen_doi,  
  EXTRACT(MONTH FROM TO_DATE(SUBSTRING(orderdate FROM 1 FOR 10), 'MM/DD/YYYY')) AS month,
  EXTRACT(YEAR FROM TO_DATE(SUBSTRING(orderdate FROM 1 FOR 10), 'MM/DD/YYYY')) AS year,
  CASE 
    WHEN EXTRACT(MONTH FROM TO_DATE(SUBSTRING(orderdate FROM 1 FOR 10), 'MM/DD/YYYY')) BETWEEN 1 AND 3 THEN 1
    WHEN EXTRACT(MONTH FROM TO_DATE(SUBSTRING(orderdate FROM 1 FOR 10), 'MM/DD/YYYY')) BETWEEN 4 AND 6 THEN 2
    WHEN EXTRACT(MONTH FROM TO_DATE(SUBSTRING(orderdate FROM 1 FOR 10), 'MM/DD/YYYY')) BETWEEN 7 AND 9 THEN 3
    ELSE 4
  END AS quy
From  public.sales_dataset_rfm_prj;
 ex5 
cách 1 
WITH stats AS (
  SELECT
    AVG(CAST(quantityordered AS NUMERIC)) AS avg_quantity,
    STDDEV(CAST(quantityordered AS NUMERIC)) AS stddev_quantity
  FROM
    public.sales_dataset_rfm_prj
)
SELECT
  quantityordered,
  (CAST(quantityordered AS NUMERIC) - avg_quantity) / stddev_quantity AS z_score,
  CASE
    WHEN ABS((CAST(quantityordered AS NUMERIC) - avg_quantity) / stddev_quantity) > 3 THEN 'Outlier'  -- Ngưỡng 3 là phổ biến
    ELSE 'Not Outlier'
  END AS outlier_status
FROM
  public.sales_dataset_rfm_prj, stats;

cách 2
 WITH stats AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CAST(quantityordered AS NUMERIC)) AS Q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CAST(quantityordered AS NUMERIC)) AS Q3
  FROM
    public.sales_dataset_rfm_prj
),
IQR AS (
  SELECT
    Q1,
    Q3,
    (Q3 - Q1) AS IQR
  FROM
    stats
)
SELECT
  quantityordered,
  CASE
    WHEN CAST(quantityordered AS NUMERIC) < (SELECT Q1 - 1.5 * IQR FROM IQR) 
      OR CAST(quantityordered AS NUMERIC) > (SELECT Q3 + 1.5 * IQR FROM IQR) 
    THEN 'Outlier'
    ELSE 'Not Outlier'
  END AS outlier_status
FROM
  public.sales_dataset_rfm_prj, IQR;
EX6 


