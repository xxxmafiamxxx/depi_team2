CREATE DATABASE Olist_Store

DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS ProductTranslations;
DROP TABLE IF EXISTS Sellers;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Geolocation;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Reviews;

--1. Table for Geolocation
CREATE TABLE Geolocation (
    id INT IDENTITY(1,1) PRIMARY KEY,                       
    geolocation_zip_code_prefix NVARCHAR(10) NOT NULL UNIQUE, 
    geolocation_lat DECIMAL(9, 6) NOT NULL,                
    geolocation_lng DECIMAL(9, 6) NOT NULL,                
    geolocation_city NVARCHAR(100) NOT NULL,               
    geolocation_state CHAR(2) NOT NULL                      
);

--2. Table for Customers
CREATE TABLE Customers (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    customer_id NVARCHAR(50) NOT NULL,                       
    customer_unique_id NVARCHAR(50) NOT NULL,                
    customer_zip_code_prefix NVARCHAR(10) NOT NULL,          
    customer_city NVARCHAR(100) NOT NULL,                    
    customer_state CHAR(2) NOT NULL,                         
    CONSTRAINT UC_Customers UNIQUE (customer_id)             
);

-- Add foreign key constraint between Customers and Geolocation tables
ALTER TABLE Customers
ADD CONSTRAINT FK_Customers_Geolocation
FOREIGN KEY (customer_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix);

-- Add index to improve JOIN performance
CREATE INDEX idx_customer_zip_code ON Customers (customer_zip_code_prefix);

--3. Create the Orders table
CREATE TABLE Orders (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    order_id NVARCHAR(50) NOT NULL UNIQUE,                   
    customer_id NVARCHAR(50) NOT NULL,                       
    order_status NVARCHAR(20) NOT NULL,                      
    order_purchase_timestamp DATETIME NOT NULL,              
    order_approved_at DATETIME NULL,                         
    order_delivered_carrier_date DATETIME NULL,              
    order_delivered_customer_date DATETIME NULL,             
    order_estimated_delivery_date DATETIME NOT NULL,         
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) 
);

-- Add indexes for frequently queried columns
CREATE INDEX idx_orders_customer_id ON Orders (customer_id);
CREATE INDEX idx_orders_status ON Orders (order_status);

--4. Create the Payments table
CREATE TABLE Payments (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    order_id NVARCHAR(50) NOT NULL,                          
    payment_sequential INT NOT NULL,                         
    payment_type NVARCHAR(20) NOT NULL,                      
    payment_installments INT NOT NULL,                       
    payment_value DECIMAL(10, 2) NOT NULL,                   
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) 
);

--5. Add index to improve payment lookups
CREATE INDEX idx_payments_order_id ON Payments (order_id);

--6. Create the Reviews table
CREATE TABLE Reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    review_id NVARCHAR(50) NOT NULL,                         
    order_id NVARCHAR(50) NOT NULL,                          
    review_score INT NOT NULL,                               
    review_comment_title NVARCHAR(255) NULL,                 
    review_comment_message NVARCHAR(MAX) NULL,               
    review_creation_date DATETIME NOT NULL,                  
    review_answer_timestamp DATETIME NULL,                   
    CONSTRAINT FK_Reviews_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id) 
);

--7. Add index to improve review searches
CREATE INDEX idx_reviews_order_id ON Reviews (order_id);

--8. Create the Products table
CREATE TABLE Products (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    product_id NVARCHAR(50) NOT NULL UNIQUE,                 
    product_category_name NVARCHAR(50) NOT NULL,             
    product_name_length INT NOT NULL,                        
    product_description_length INT NOT NULL,                 
    product_photos_qty INT NOT NULL,                         
    product_weight_g INT NOT NULL,                           
    product_length_cm INT NOT NULL,                          
    product_height_cm INT NOT NULL,                          
    product_width_cm INT NOT NULL                            
);

-- Add index to improve product lookups
CREATE INDEX idx_products_category ON Products (product_category_name);

--9. Create the Sellers table
CREATE TABLE Sellers (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    seller_id NVARCHAR(50) NOT NULL UNIQUE,                  
    seller_zip_code_prefix NVARCHAR(10) NOT NULL,            
    seller_city NVARCHAR(100) NOT NULL,                      
    seller_state CHAR(2) NOT NULL,                           
    CONSTRAINT FK_Sellers_Geolocation FOREIGN KEY (seller_zip_code_prefix) REFERENCES Geolocation(geolocation_zip_code_prefix) 
);

-- Add index to improve seller lookups
CREATE INDEX idx_sellers_zip_code ON Sellers (seller_zip_code_prefix);

--10. Create the OrderItems table
CREATE TABLE OrderItems (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    order_id NVARCHAR(50) NOT NULL,                          
    order_item_id INT NOT NULL,                              
    product_id NVARCHAR(50) NOT NULL,                        
    seller_id NVARCHAR(50) NOT NULL,                         
    shipping_limit_date DATETIME NOT NULL,                   
    price DECIMAL(10, 2) NOT NULL,                           
    freight_value DECIMAL(10, 2) NOT NULL,                   
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id), 
	CONSTRAINT FK_Products_OrderItems FOREIGN KEY (product_id) REFERENCES Products(product_id), 
	CONSTRAINT FK_Sellers_OrderItems FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id) 
);

-- Add indexes to improve order item lookups
CREATE INDEX idx_orderitems_order_id ON OrderItems (order_id);
CREATE INDEX idx_orderitems_product_id ON OrderItems (product_id);
CREATE INDEX idx_orderitems_seller_id ON OrderItems (seller_id);

--11. Create the ProductTranslations table
CREATE TABLE ProductTranslations (
    id INT IDENTITY(1,1) PRIMARY KEY,                        
    product_category_name NVARCHAR(50) NOT NULL UNIQUE,      
    product_category_name_english NVARCHAR(50) NOT NULL      
);

-- Foreign key constraint from Products to ProductTranslations
ALTER TABLE Products
ADD CONSTRAINT FK_Products_ProductTranslations
FOREIGN KEY (product_category_name) REFERENCES ProductTranslations(product_category_name);

-- Add index to improve product category lookups
CREATE INDEX idx_producttranslations_category_name ON ProductTranslations (product_category_name);
