CREATE DATABASE insurance;
USE insurance;

CREATE TABLE person (
driver_id VARCHAR(255) NOT NULL,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
PRIMARY KEY (driver_id)
);

CREATE TABLE car (
reg_no VARCHAR(255) NOT NULL,
model TEXT NOT NULL,
c_year INTEGER,
PRIMARY KEY (reg_no)
);

CREATE TABLE accident (
report_no INTEGER NOT NULL,
accident_date DATE,
location TEXT,
PRIMARY KEY (report_no)
);

CREATE TABLE owns (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE participated (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);


-- Find the total number of people who owned cars that were involved in accidents in 2021.  

select COUNT(driver_id) from participated 
join accident using(report_no) 
where year(accident_date)="2021";

-- --------------------------------------------------

-- Find the number of accidents in which the cars belonging to “Smith” were involved.  
 
SELECT COUNT(p.driver_id) FROM participated p 
JOIN person USING(driver_id) 
WHERE person.driver_name='Smith';

-- --------------------------------------------------

-- Add a new accident to the database; assume any values for required attributes.   
	-- insertion command

-- --------------------------------------------------

-- Delete the Mazda belonging to “Smith”.   

DELETE FROM CAR WHERE
model='Mazda' 
AND reg_no in (SELECT reg_no FROM OWNS 
				JOIN PERSON USING(driver_id) 
                WHERE driver_name='Smith');

select * from Car;

-- ---------------------------------------------------

-- Update the damage amount for the car with reg_no of KA-09-MA-1234 in the accident with report_no 65738

UPDATE participated 
SET damage_amount=2000 
WHERE reg_no="KA-09-MA-1234"
AND report_no=65738;

-- ----------------------------------------------------

-- A view that shows models and year of cars that are involved in accident.  

create view Accident_Cars as
select model,c_year from car
where reg_no in (select reg_no from participated);

select * from Accident_Cars;

-- ------------------------------------------------------

-- A trigger that prevents a driver from participating in more than 3 accidents in a given year.

delimiter //
create trigger Prevent_Accident
before insert on participated
for each row 
begin
if ( (select count(driver_id) from participated join accident using(report_no) 
		where driver_id=NEW.driver_id and year(accident_date) in 
			(select year(accident_date) from accident 
				where report_no=NEW.report_no) ) =2) then
	SIGNAL SQLSTATE '45000' 
	SET MESSAGE_TEXT='Driver in 2 accidents';
end if;
end;//
delimiter ;

-- checking trigger
INSERT INTO participated VALUES
("D222", "KA-20-AB-4223", 66666, 20000);

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 63744, 20000);

INSERT INTO participated VALUES
("D333", "KA-20-AB-4223", 63744, 20000);

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 54634, 20000);

-- select p.driver_id,year(a.accident_date),count(driver_id) from participated p
-- join accident a using(report_no)
-- group by p.driver_id,year(a.accident_date);

