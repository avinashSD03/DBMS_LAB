create database order_processing;
use order_processing;

create table Customers (
	cust_id int primary key,
	cname varchar(35) not null,
	city varchar(35) not null
);

create table Orders (
	order_id int primary key,
	odate date not null,
	cust_id int,
	order_amt int not null,
	foreign key (cust_id) references Customers(cust_id) on delete cascade
);

create table Items (
	item_id  int primary key,
	unitprice int not null
);

create table OrderItems (
	order_id int not null,
	item_id int not null,
	qty int not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (item_id) references Items(item_id) on delete cascade
);

create table Warehouses (
	warehouse_id int primary key,
	city varchar(35) not null
);

create table Shipments (
	order_id int not null,
	warehouse_id int not null,
	ship_date date not null,
	foreign key (order_id) references Orders(order_id) on delete cascade,
	foreign key (warehouse_id) references Warehouses(warehouse_id) on delete cascade
);

INSERT INTO Customers VALUES
(0001, "Customer_1", "Mysuru"),
(0002, "Customer_2", "Bengaluru"),
(0003, "Kumar", "Mumbai"),
(0004, "Customer_4", "Dehli"),
(0005, "Customer_5", "Bengaluru");

INSERT INTO Orders VALUES
(001, "2020-01-14", 0001, 2000),
(002, "2021-04-13", 0002, 500),
(003, "2019-10-02", 0003, 2500),
(004, "2019-05-12", 0005, 1000),
(005, "2020-12-23", 0004, 1200);

INSERT INTO Items VALUES
(0001, 400),
(0002, 200),
(0003, 1000),
(0004, 100),
(0005, 500);

INSERT INTO Warehouses VALUES
(0001, "Mysuru"),
(0002, "Bengaluru"),
(0003, "Mumbai"),
(0004, "Dehli"),
(0005, "Chennai");

INSERT INTO OrderItems VALUES 
(001, 0001, 5),
(002, 0005, 1),
(003, 0005, 5),
(004, 0003, 1),
(005, 0004, 12);

INSERT INTO Shipments VALUES
(001, 0002, "2020-01-16"),
(002, 0001, "2021-04-14"),
(003, 0004, "2019-10-07"),
(004, 0003, "2019-05-16"),
(005, 0005, "2020-12-23");


SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Items;
SELECT * FROM Shipments;
SELECT * FROM Warehouses;

-- List the Order# and Ship_date for all orders shipped from Warehouse# "0001".

select order_id,ship_date from orders
join shipments using(order_id)
join warehouses using(warehouse_id)
where warehouse_id=2;

-- -----------------------------------------------------

-- List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#

select warehouse_id,order_id from shipments
join orders using(order_id)
join customers using(cust_id) 
where cname like "%Kumar%";

--  OR

select warehouse_id,order_id
from shipments 
where order_id in (select order_id from orders where cust_id in (select cust_id from customers where cname="Kumar")); 

-- ---------------------------------------------------------

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total number of orders by the customer and the last column is the average order amount for that customer. (Use aggregate functions) 

select c.cname,COUNT(o.order_id) as "No Of Orders",AVG(o.order_amt) as "Average Amount"
from customers c
join orders o using(cust_id)
group by c.cname;

-- ----------------------------------------------------------

-- Find the item with the maximum unit price.

select * from items
order by unitprice desc limit 1;

-- ----------------------------------------------------------

-- A tigger that updates order_amount based on quantity and unit price of order_item

create trigger my_amt
after insert on orderitems
for each row update orders set order_amt=(select unitprice from items where item_id=NEW.item_id)*NEW.qty where order_id=NEW.order_id;

-- check trigger

INSERT INTO Orders VALUES
(006, "2020-12-23", 0003,1200);

INSERT INTO OrderItems VALUES 
(006,0003,9); 

SELECT * FROM Orders;

-- SET SQL_SAFE_UPDATES = 0; -- is used if insertion is not happening and error is "you are in safe mode..."

-- --------------------------------------------------------------

create view WareHouse5_Details as
select order_id,ship_date
from shipments
where warehouse_id=5;

select * from WareHouse5_Details;
