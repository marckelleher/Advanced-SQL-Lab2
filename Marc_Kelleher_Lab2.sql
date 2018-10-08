/*
*******************************************************************************************
CIS276 at PCC
LAB 2 using SQL SERVER 2012 and the SalesDB tables
*******************************************************************************************

                                   CERTIFICATION:

   By typing my name below I certify that the enclosed is original coding written by myself
without unauthorized assistance.  I agree to abide by class restrictions and understand that
if I have violated them, I may receive reduced credit (or none) for this assignment.

                CONSENT:   Marc Kelleher	
                DATE:      1/20/18

*******************************************************************************************
*/
PRINT '================================================================================' + CHAR(10)
    + 'CIS276 Lab2'                                   + CHAR(10)
    + '================================================================================' + CHAR(10)

USE SalesDB
GO


PRINT '1. 1.	What is the dollar total for each of the salespeople?' + CHAR(10) 
PRINT 'Calculate totals for all salespeople (even if they have no sales).' + CHAR(10)
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, SUM(ORDERITEMS.Qty*INVENTORY.Price) 
Display the total dollar value that each and every sales person has sold.
List in dollar value descending.
NOTE: You need to include all salespeople, not just those salespeople with orders;
so you cannot do a simple inner JOIN. The outer JOIN picks up all salespeople.  
The warning statement is because of the NULL and can be disregarded.
*/

select CAST(SALESPERSONS.EmpID AS CHAR (18)) AS Salesperson, CAST(SALESPERSONS.Ename AS CHAR(18)) AS Name, SUM(ORDERITEMS.Qty*INVENTORY.Price) as "Total Sales"
from SALESPERSONS left outer join ORDERS on SALESPERSONS.EmpID = ORDERS.EmpID
left outer join ORDERITEMS on ORDERS.OrderID = ORDERITEMS.OrderID
left outer join INVENTORY on ORDERITEMS.PartID = INVENTORY.PartID
group by SALESPERSONS.EmpID, SALESPERSONS.Ename
order by "Total Sales" desc;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '2. What is the $$ value of each of the orders?' + CHAR(10) 
/*
Columns to display: ORDERS.OrderID, SUM(ORDERITEM.Qty*INVENTORY.Price) 
List in dollar value descending.
*/

select CAST(ORDERS.OrderID AS CHAR(8)) AS "Order ID", SUM(ORDERITEMS.Qty*INVENTORY.Price) as "Order Value"
from ORDERS left outer join ORDERITEMS on ORDERS.OrderID = ORDERITEMS.OrderID
left outer join INVENTORY on ORDERITEMS.PartID = INVENTORY.PartID
group by ORDERS.OrderID
Order by "Order Value" desc;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '3. Which orders contain widgets?' + CHAR(10)
/*
Columns to display: ORDERS.OrderID, ORDERS.SalesDate 
The word 'widget' may not be the only word in the part's description (use a wildcard).
Display the orders where a 'widget' part appears in at least one ORDERITEMS rows for the order.
List in sales date sequence with the newest first. 
Do not use the EXISTS clause.
*/

select CAST(ORDERS.OrderID AS CHAR(8)) AS "Order ID", CONVERT(varchar, (ORDERS.SalesDate), 11)
from ORDERS 
join ORDERITEMS ON ORDERS.OrderID = ORDERITEMS.OrderID
join INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
where INVENTORY.Description LIKE ('%widget%')
order by ORDERS.SalesDate desc;

GO


PRINT '================================================================================' + CHAR(10)
PRINT '4. Which orders contain widgets?' + CHAR(10)
/*
Columns to display: ORDERS.OrderID, ORDERS.SalesDate 
The word 'widget' might not be the only word in the part's description (use a wildcard).
Display the orders where a 'widget' part appears in at least one ORDERITEMS rows for the order.
List in sales date sequence with the most recent first. 
Use the EXISTS clause.
*/

select CAST(ORDERS.OrderID AS CHAR(8)) AS "Order ID", CONVERT(varchar, (ORDERS.SalesDate), 11)
from ORDERS, ORDERITEMS
where ORDERS.OrderID = ORDERITEMS.OrderID 
AND exists (select * from INVENTORY 
			where ORDERITEMS.PartID = INVENTORY.PartID
			AND lower(INVENTORY.Description) LIKE '%widget%')
order by ORDERS.SalesDate desc;


GO


PRINT '================================================================================' + CHAR(10)
PRINT '5. What are the gadget and gizmo only orders? i.e. which orders contain at least one gadget and at least one gizmo, but no other parts?' + CHAR(10)
/*
Columns to display:  OrderID 
The words 'gadget' and 'gizmo' may not be the only word in the part's description. Code accordingly.
List in ascending order of OrderID.
*/

select CAST(ORDERS.OrderID AS CHAR(8)) AS "Order ID"
from ORDERS
where OrderID IN (select OrderID from ORDERITEMS where PartID IN (select PartID from INVENTORY where Description LIKE '%gadget%'))

AND OrderID IN (select OrderID from ORDERITEMS where PartID IN (select PartID from INVENTORY where Description LIKE '%gizmo%'))

AND OrderID NOT IN (select OrderID from ORDERITEMS where PartID IN (select PartID from INVENTORY where Description NOT LIKE '%gadget%'
																		AND Description NOT LIKE '%gizmo%'));


(INVENTORY.Description LIKE '%gadget%' OR INVENTORY.Description LIKE '%gizmo%') 
AND INVENTORY.Description NOT LIKE (select INVENTORY.Description from INVENTORY where (INVENTORY.Description LIKE '%gadget%' AND INVENTORY.Description LIKE '%gizmo%'));

--3 criteria in where clause

GO


PRINT '================================================================================' + CHAR(10)
PRINT '6. Who are our profit-less customers?' + CHAR(10)
/*
Columns to display: CUSTOMERS.CustID, CUSTOMERS.Cname 
Display the customers that have not placed orders.
Show in customer name order (either ascending or descending). 
Use the EXISTS clause.
*/

select CUSTOMERS.CustID, CUSTOMERS.Cname
from CUSTOMERS
where  EXISTS (select * from CUSTOMERS join ORDERS ON CUSTOMERS.CustID = ORDERS.CustID)-- right outer join ORDERS ON CUSTOMERS.CustID = ORDERS.CustID)  --(select CUSTOMERS.CustID from CUSTOMERS where CUSTOMERS.CustID = ORDERS.CustID) 
order by CUSTOMERS.Cname ASC;

-- use not exists

GO


PRINT '================================================================================' + CHAR(10)
PRINT '7. What is the average $$ value of an order?' + CHAR(10)
/*
To get the answer, you need to add up all the order values (see #2, above) and divide this by the number of orders. 
There are two possible averages on this question, because not all of the order numbers in the ORDERS table are in the ORDERITEMS table...
You will calculate and display both averages.
Columns to display are determined by whether your output is horizontal (two columns: "Orders Average" and "OrderItems Average") 
  or vertical (one column, holding both averages in separate lines).
Write one query that produces both averages. 
*/

select	SUM(ORDERITEMS.Qty*INVENTORY.Price)/COUNT(DISTINCT ORDERS.OrderID) as "Orders Average",
		SUM(ORDERITEMS.Qty*INVENTORY.Price)/COUNT(DISTINCT ORDERITEMS.OrderID) as "OrderItems Average"
from ORDERS left join ORDERITEMS on ORDERS.OrderID = ORDERITEMS.OrderID
			left join INVENTORY on ORDERITEMS.PartID = INVENTORY.PartID

select count(*) from ORDERS where not exists (select * from ORDERITEMS where ORDERITEMS.OrderID = ORDERS.OrderID)

GO


PRINT '================================================================================' + CHAR(10)
PRINT '8. Who is our most profitable salesperson?' + CHAR(10)
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) 
A salesperson's profit (or loss) is the difference between what the person sold and what the person earns 
((SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)).  If the value is positive then there is a profit, otherwise 
there is a loss.  The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss.
Display the most profitable salesperson (there can be more than one).
*/

select TOP 1 WITH TIES CAST(SALESPERSONS.EmpID AS CHAR(5)) AS "Salesperson ID", CAST(SALESPERSONS.Ename AS CHAR(18)) AS "Salesperson Name", SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary as "Profitability"
from SALESPERSONS join ORDERS ON SALESPERSONS.EmpID = ORDERS.EmpID
join ORDERITEMS on ORDERS.OrderID = ORDERITEMS.OrderID
join INVENTORY on ORDERITEMS.PartID = INVENTORY.PartID
group by SALESPERSONS.EmpID, SALESPERSONS.Ename, SALESPERSONS.Salary
order by (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) desc;

-- Use TOP 1 WITH TIES

GO


PRINT '================================================================================' + CHAR(10)
PRINT '9. Who is our second-most profitable salesperson?' + CHAR(10)
    + 'The key is to take the best two, reverse, and take the best one'
/*
Columns to display: SALESPERSONS.EmpID, SALESPERSONS.Ename, (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)
A salesperson's profit (or loss) is the difference between what the person sold and what the person earns 
((SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary)).  If the value is positive then there is a profit, otherwise 
there is a loss.  The most profitable salesperson, therefore, is the person with the greatest profit or smallest loss.  
The second-most profitable salesperson is the person with the next greatest profit or next smallest loss.  
Display the second-most profitable salesperson (there can be more than one).  
Do not hard-code the results of #2 into this query - that simply creates a data-dependent query.
See if you can do this without using the SQL Server keyword TOP or TOP WITH TIES.
*/

select CAST(SALESPERSONS.EmpID AS CHAR(5)) AS "Salesperson ID", CAST(SALESPERSONS.Ename AS CHAR(18)) AS "Salesperson Name", SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary as "Profitability"
from SALESPERSONS join ORDERS ON SALESPERSONS.EmpID = ORDERS.EmpID
join ORDERITEMS on ORDERS.OrderID = ORDERITEMS.OrderID
join INVENTORY on ORDERITEMS.PartID = INVENTORY.PartID
group by SALESPERSONS.EmpID, SALESPERSONS.Ename, SALESPERSONS.Salary
order by (SUM(ORDERITEMS.Qty*INVENTORY.Price) - SALESPERSONS.Salary) desc
offset 1 rows fetch next 1 rows only;


-- Take number 8 and take the best two, reverse and take the best one.  Use Offset Fetch?

GO


PRINT '================================================================================' + CHAR(10)
PRINT'10.	What would be the discounts for each line item on orders of five or more units?' + CHAR(10)
/* Columns to display: Orderid, Partid, Description, Qty, UnitPrice, OriginalCost, QuantityDeduction, and FinalCost
 We have decided to give quantity discounts to encourage more sales.  If an order contains five or more units of a given 
 product we will give a 5% discount for that line item.  If an order contains ten or more units we will give a 10% discount 
 on that line item.   Produce an output that prints the OrderID, partid, description, Qty ordered, unit list Price, the total
 original Price(Qty ordered * list Price),  the total discount value (shown as money or percent), and the total final Price 
 of the product after the discount.   Display only those line items subject to the discount in ascending order by the OrderID 
 and partid.  Use the CASE statement.
 */

 select CAST(ORDERITEMS.OrderID AS CHAR(8)) AS "Order ID", 
		CAST(ORDERITEMS.Qty AS CHAR(8)) AS Quantity,
		CAST(INVENTORY.PartID AS CHAR(8)) AS "Part ID", 
		CAST(INVENTORY.Description AS CHAR(18)) AS Description, 
	CASE WHEN ORDERITEMS.Qty >=10 THEN ' 10%'
		ELSE ' 5%'					END	AS 'Discount',
	CASE WHEN ORDERITEMS.Qty >=10 THEN STR(.9,5,2)
		ELSE STR(.95,5,2)			END	AS 'Discount',
	CASE WHEN ORDERITEMS.Qty >=10 THEN STR((ORDERITEMS.Qty * INVENTORY.Price * .1),6,2)
		ELSE STR((ORDERITEMS.Qty * INVENTORY.Price * .05),6,2) 
									END AS 'Discount',
	CASE WHEN ORDERITEMS.Qty >=10 THEN STR((ORDERITEMS.Qty * INVENTORY.Price * .9),16,2)
		ELSE STR((ORDERITEMS.Qty * INVENTORY.Price * .95),16,2)
									END AS 'Final Multiplied',
	CASE WHEN ORDERITEMS.Qty >=10 THEN STR(((ORDERITEMS.Qty * INVENTORY.Price) - (ORDERITEMS.Qty * INVENTORY.Price * .1)),16,2)
		ELSE STR(((ORDERITEMS.Qty * INVENTORY.Price) - (ORDERITEMS.Qty * INVENTORY.Price * .05)),16,2)
									END AS 'Final Subtracted'
from ORDERITEMS join INVENTORY ON ORDERITEMS.PartID = INVENTORY.PartID
where ORDERITEMS.Qty >=5
ORDER BY ORDERITEMS.OrderID ASC, ORDERITEMS.PartID ASC;


GO


--------------------------------------------------------------------------------
-- Program block
--------------------------------------------------------------------------------
DECLARE @v_now DATETIME;
BEGIN
    SET @v_now = GETDATE();
    PRINT '================================================================================'
    PRINT 'End of CIS276 Lab1 answer file provided by Alan Miles, Instructor';
    PRINT @v_now;
    PRINT '================================================================================';
END;


