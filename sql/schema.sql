-- Create database
CREATE DATABASE InventoryDB;
GO

USE InventoryDB;
GO

-- Users Table
CREATE TABLE Users (
    id INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password NVARCHAR(255) NOT NULL,
    otp NVARCHAR(6),
    otp_expiry DATETIME,
    created_at DATETIME DEFAULT GETDATE()
);

-- Categories Table
CREATE TABLE Categories (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) COLLATE Khmer_100_CI_AS NOT NULL,
    description NVARCHAR(MAX) COLLATE Khmer_100_CI_AS,
    created_at DATETIME DEFAULT GETDATE()
);

-- Products Table
CREATE TABLE Products (
    id INT PRIMARY KEY IDENTITY(1,1),
    product_code NVARCHAR(50) UNIQUE NOT NULL,
    category_id INT FOREIGN KEY REFERENCES Categories(id),
    name NVARCHAR(200) COLLATE Khmer_100_CI_AS NOT NULL,
    description NVARCHAR(MAX) COLLATE Khmer_100_CI_AS,
    price DECIMAL(10, 2) NOT NULL,
    image_url NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

-- Sample Data
INSERT INTO Categories (name, description) VALUES 
(N'គ្រឿងអេឡិចត្រូនិច', N'Electronics products like phones, laptops, etc.'),
(N'សម្លៀកបំពាក់', N'Clothing and accessories'),
(N'អាហារនិងភេសជ្ជៈ', N'Food and beverages');

INSERT INTO Products (product_code, category_id, name, description, price, image_url) VALUES 
('IPH15', 1, N'ទូរស័ព្ទ iPhone 15', N'Apple iPhone 15 with 128GB', 999.00, 'IPH15.jpg'),
('MBA2', 1, N'កុំព្យូទ័រ MacBook Air', N'M2 chip, 8GB RAM', 1099.00, 'MBA2.jpg'),
('TS01', 2, N'អាវយឺត', N'Cotton T-shirt', 15.00, 'TS01.jpg');


select *from Users


ALTER LOGIN [hoeunraksa] WITH PASSWORD = 'strong@123';
ALTER LOGIN [hoeunraksa] ENABLE;
ALTER LOGIN [hoeunraksa] WITH DEFAULT_DATABASE = [InventoryDB];
-- If user doesn't exist yet:
CREATE USER [hoeunraksa] FOR LOGIN [hoeunraksa];
GO

ALTER ROLE db_owner ADD MEMBER [hoeunraksa];
GO
GO