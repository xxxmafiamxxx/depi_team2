--1. Insert into Dim_Date
INSERT INTO Olist_Warehouse_2.Dim_Date (date_key, date, year, month, day, weekday)
SELECT 
    CAST(CONVERT(VARCHAR, date, 112) AS INT) AS date_key,
    date,
    YEAR(date) AS year,
    MONTH(date) AS month,
    DAY(date) AS day,
    DATEPART(WEEKDAY, date) AS weekday
FROM Olist_Store.Dim_Date
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Date wd 
    WHERE wd.date_key = CAST(CONVERT(VARCHAR, date, 112) AS INT)
);

--2. Insert into Dim_Geolocation
INSERT INTO Olist_Warehouse_2.Dim_Geolocation (olist_db_id, geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
SELECT 
    id AS olist_db_id,
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM Olist_Store.Dim_Geolocation
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Geolocation wg 
    WHERE wg.olist_db_id = id
);

--3. Insert into Dim_Customers
INSERT INTO Olist_Warehouse_2.Dim_Customers (olist_db_id, customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT 
    id AS olist_db_id,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM Olist_Store.Dim_Customers
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Customers wc 
    WHERE wc.olist_db_id = id
);

--4. Insert into Dim_Orders
INSERT INTO Olist_Warehouse_2.Dim_Orders (olist_db_id, order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date, date_key)
SELECT 
    id AS olist_db_id,
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    date_key
FROM Olist_Store.Dim_Orders
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Orders wo 
    WHERE wo.olist_db_id = id
);

--5. Insert into Dim_Products
INSERT INTO Olist_Warehouse_2.Dim_Products (olist_db_id, product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT 
    id AS olist_db_id,
    product_id,
    product_category_name,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM Olist_Store.Dim_Products
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Products wp 
    WHERE wp.olist_db_id = id
);

--6. Insert into Dim_Sellers
INSERT INTO Olist_Warehouse_2.Dim_Sellers (olist_db_id, seller_id, seller_zip_code_prefix, seller_city, seller_state)
SELECT 
    id AS olist_db_id,
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM Olist_Store.Dim_Sellers
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Sellers ws 
    WHERE ws.olist_db_id = id
);

--7. Insert into Junk_OrderItems
INSERT INTO Olist_Warehouse_2.Junk_OrderItems (olist_db_id, order_id, order_item_id, product_id, seller_id)
SELECT 
    id AS olist_db_id,
    order_id,
    order_item_id,
    product_id,
    seller_id
FROM Olist_Store.Junk_OrderItems
WHERE NOT EXISTS (
    SELECT 1 
    FROM O list_Warehouse_2.Junk_OrderItems woi 
    WHERE woi.olist_db_id = id
);

--8. Insert into Dim_Reviews
INSERT INTO Olist_Warehouse_2.Dim_Reviews (dim_order_warehouse_id, olist_db_id, review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date)
SELECT 
    wo.warehouse_id AS dim_order_warehouse_id,
    id AS olist_db_id,
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date
FROM Olist_Store.Dim_Reviews
JOIN Olist_Warehouse_2.Dim_Orders wo ON Olist_Store.Dim_Reviews.order_id = wo.order_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Reviews wr 
    WHERE wr.olist_db_id = id
);

--9. Insert into Dim_Payments
INSERT INTO Olist_Warehouse_2.Dim_Payments (dim_order_warehouse_id, olist_db_id, order_id, payment_sequential, payment_type, payment_installments, payment_value, date_key)
SELECT 
    wo.warehouse_id AS dim_order_warehouse_id,
    id AS olist_db_id,
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    wd.date_key
FROM Olist_Store.Dim_Payments
JOIN Olist_Warehouse_2.Dim_Orders wo ON Olist_Store.Dim_Payments.order_id = wo.order_id
JOIN Olist_Warehouse_2.Dim_Date wd ON Olist_Store.Dim_Payments.payment_date = wd.date
WHERE NOT EXISTS (
    SELECT 1 
    FROM Olist_Warehouse_2.Dim_Payments wp 
    WHERE wp.olist_db_id = id
);