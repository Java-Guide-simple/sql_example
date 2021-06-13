use northwind;

--  1 WAQ TO DISPLAY NAME(COMPANY NAME) OF CUSTOMERS WHO HAVE NOT PLACED ANY ORDERS FAR? 

SELECT CompanyName
	FROM customers
	WHERE CustomerID NOT IN (SELECT CustomerID 
								FROM orders);

-- 2 WAQ TO DISPLAY NAME OF THE EMPLOYEE(FNMAE+LNAME DISPLAY AS FULLNAME) WHO NEVER HANDLED ANY ORDERS SO FAR 

SELECT concat(FirstName," " ,LastName) as FULLNAME 
	FROM employees
	WHERE EmployeeID 
	NOT IN (SELECT EmployeeID 
				FROM orders);

-- 3 DISPLAY CUSTOMERS(COMPANY NAME) WHO HAVE PLACED MAXIMUM ORDERS (IF MULTIPLE RECORDS, SORT IT). 

SELECT CompanyName
	FROM customers
    WHERE CustomerID =(SELECT CustomerID 
							FROM orders 
                            GROUP BY CustomerID 
                            ORDER BY count(CustomerID) 
                            DESC LIMIT 1);
                            
                            
 -- 4 WAQ TO DISPLAY NAME OF THE SUPPLIERS(COMPANY NAME) WHO SUPPLIED MAXIMUM NUMBER OF PRODUCTS FROM SEA FOOD CATEGORIES 

SELECT CompanyName
	   FROM Suppliers AS s
	   WHERE SupplierID =(SELECT p.SupplierID
								 FROM Products p,categories c
                                 WHERE p.CategoryID = c.CategoryID
								 AND CategoryName LIKE "seafood" 
                                 group by p.SupplierID 
                                 order by count(p.SupplierID) 
                                 DESC
                                 Limit 1);

 -- 5 WAQ TO IDENTIFY THE HIGHER VALUE PRODUCT NAME IN CONTINUITY PRODUCTS(DISCONTINUED=NO) 

SELECT ProductName 
	FROM products 
	WHERE  UnitPrice=(SELECT max(UnitPrice) 
							FROM products
                            WHERE Discontinued='n'
                            );
        
-- 6 WAQ to display the product name,price,discount,quantity units in stock 
-- (for generation of discount if price>=50 -- discount is 5%, if price >=20 and <49 discount is 8% 
-- for price is 1 to 19 2% discount for others n/a) calculate the discounted unit price as discounted_unitprice. 

SELECT ProductName,UnitPrice,UnitsInStock, 
		CASE WHEN unitprice >= 50 
        THEN (unitprice-(unitprice*0.05)) 
		WHEN unitprice>= 20 and unitprice<49 
        THEN (unitprice-(unitprice*0.08)) 
		when unitprice>=1 and unitprice<=19
        then (unitprice-(unitprice*0.02)) 
		ELSE unitprice END AS discounted_unitprice 
		FROM products;     
 
 -- 7 WAQ to display the name of shipper who have shipped the maximum of orders. 
 -- Arrange records based on shipper name. 
 
 
SELECT CompanyName 
	FROM shippers 
    WHERE ShipperID=(SELECT shipvia 
							FROM orders 
                            GROUP BY shipVia 
                            ORDER BY count(shipvia) 
                            DESC LIMIT 1);
                            
 -- 8 WAQ to display contact name,username,password for all the customers who have registered in the system.     
 -- note: for generating of user extract first 4 digit of company name nad last four digits of contact             --    name. for password last four digits of the company name +"@123". 

 SELECT contactName,concat(substring(CompanyName,1,4),substring(ContactName,(length(ContactName)-3),length(ContactName))) as UserName,
		concat(substring(CompanyName,(length(CompanyName)-3),length(CompanyName)),"@123") as UserPassword 
		FROM customers;
 
 -- 9 WAQ to display each product name and highest unit price ever sold for each product,because a 
 -- product can be sold at adifferent discount,we want the highest unit price ever sold for each product.
 SELECT p.ProductName, max(od.UnitPrice) as highestPrice
	   FROM order_details as od join products as p 
       WHERE od.ProductID=p.ProductID
       GROUP BY od.ProductID
       ORDER BY od.ProductID;
 -- 10 WAQ to display the name of the suppliers(company name) who not supplied any product so far?

 SELECT CompanyName 
		FROM suppliers 
        WHERE SupplierID 
        NOT IN (SELECT SupplierID 
						FROM products);
 
 -- 11 WAQ to display full name(fname+lname displau full name) of employee who have sold maximum sea food items.
SELECT DISTINCT concat(FirstName,LastName) as FullName
	   FROM employees 
       WHERE EmployeeID IN(SELECT EmployeeID
								  FROM products p 
                                  INNER JOIN categories c ON c.CategoryID=p.CategoryID
								  WHERE categoryName='sea food'
                                  GROUP BY EmployeeID
								  HAVING sum(QuantityPerUnit)=(
								  SELECT max(vt.productCount)
								  FROM (SELECT EmployeeID, sum(QuantityPerUnit) AS productCount
								  FROM orders o JOIN order_details od
								  ON o.OrderID=od.OrderID
								  JOIN products p
		                          ON od.ProductID=p.ProductID
								  JOIN categories c
								  ON p.ProductID=c.CategoryID
								  WHERE c.categoryName='seafood'
								  GROUP BY EmployeeID)as vt));
 -- 12 WAQ to display product name which is not ordered by any customers? 
 
 SELECT ProductName 
		FROM products
        WHERE ProductID NOT IN(SELECT  ProductID 
										FROM order_details);
                                        
-- 13 display category name and number of product available 
SELECT c.categoryName,count(p.productName) Count_Products
	   FROM categories c left join products p
       ON c.categoryId=p.categoryId
       GROUP BY c.categoryId;
-- SELECT CategoryName.categories,count(CategoryID).products 
-- 		FROM categories c 
--         join on products p 
--         where c.CategoryID =p.CategoryID 
--         group by CategoryID;
        
SELECT CategoryName, count(CategoryID) FROM categories JOIN products on products.CategoryID = categories.CategoryID group By CategoryID;
	
-- 14 WAQ to display the name of suppliers who have collected minimum freight charge
-- for all the orders among all the other suppliers? 

SELECT CompanyName 
		FROM suppliers 
        WHERE SupplierID IN (SELECT SupplierID 
									FROM products 
                                    WHERE ProductID IN (SELECT ProductID 
																FROM order_details 
                                                                WHERE OrderID=(SELECT OrderID 
																				FROM orders 
                                                                                WHERE freight = (SELECT min(DISTINCT(Freight)) 
																										FROM orders)))) ;                                       
                                        
-- 15 WAQ to display each city name and no of customers in each city,
-- display the result in descending order. 

SELECT City , count(CustomerID) as NumberOfCustomers 
		FROM customers
        group by City 
        order by count(CustomerID) DESC ;
        
-- 16 WAQ to display the name of the product,unitsinStock and supplier name 
-- of the product which contain low stock(Units in stock lesserthan the Reorder quantity) 
-- and not yet processed the ReOrder Process(Ie: unitsOnOrder is Zero) Display the records in descending order. 
SELECT ProductName,UnitsInStock,CompanyName
	   FROM products p join suppliers s 
       ON p.SupplierID=s.SupplierID
	   WHERE UnitsInStock<ReorderLevel AND UnitsOnOrder=0
	   ORDER BY ReorderLevel DESC;  