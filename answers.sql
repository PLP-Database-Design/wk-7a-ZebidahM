-- Question 1
-- First, create the tables needed for the transformation, assuming OrderID is the primary key for the new table:
CREATE TABLE OrderProducts (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product) -- Assuming quantity is necessary; adjust as per actual requirement
);

-- Use a temporary table to split the products
CREATE TEMPORARY TABLE tmp_product_details AS
SELECT OrderID,
       SPLIT_PART(Products, ',', 1) AS Product,
       NULL AS Quantity  -- Assuming quantity is not initially given, adjust as per requirement
FROM ProductDetail;

-- Insert the split product details into the new table
INSERT INTO OrderProducts (OrderID, Product, Quantity)
SELECT OrderID, Product, 
       CASE 
         WHEN POSITION(',', Products) > 1 THEN (VALUE_AT(SUBSTRING(Products FROM POSITION(',', Products)+1), ',', 1)::INT)
         ELSE NULL
       END AS Quantity -- Adjust the quantity calculation based on actual need (here assumed to be separate)
FROM tmp_product_details;

-- Drop the temporary table
DROP TABLE tmp_product_details;

-- `OrderProducts` is in 1NF if we assume each product has a quantity or we're tracking products only.

CREATE TABLE Customers (
    OrderID INT,
    CustomerName VARCHAR(255),
    PRIMARY KEY (OrderID, CustomerName),
    FOREIGN KEY (OrderID) REFERENCES OrderDetails(OrderID)
);

-- Inserting data into the Customers table:
INSERT INTO Customers (OrderID, CustomerName)
SELECT OrderID, CustomerName
FROM OrderDetails;

-- Now, removing the CustomerName from the OrderDetails table as it's now in a separate table:
ALTER TABLE OrderDetails DROP COLUMN CustomerName;
