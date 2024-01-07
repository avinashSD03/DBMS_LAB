create database company; 
use company;

create table Employee(
	ssn varchar(35) primary key,
	name varchar(35) not null,
	address varchar(255) not null,
	sex varchar(7) not null,
	salary int not null,
	super_ssn varchar(35),
	d_no int,
	foreign key (super_ssn) references Employee(ssn) on delete set null
);

create table Department(
	d_no int primary key,
	dname varchar(100) not null,
	mgr_ssn varchar(35),
	mgr_start_date date,
	foreign key (mgr_ssn) references Employee(ssn) on delete cascade
);

create table DLocation(
	d_no int not null,
	d_loc varchar(100) not null,
	foreign key (d_no) references Department(d_no) on delete cascade
);

create table Project(
	p_no int primary key,
	p_name varchar(25) not null,
	p_loc varchar(25) not null,
	d_no int not null,
	foreign key (d_no) references Department(d_no) on delete cascade
);

create table WorksOn(
	ssn varchar(35) not null,
	p_no int not null,
	hours int not null default 0,
	foreign key (ssn) references Employee(ssn) on delete cascade,
	foreign key (p_no) references Project(p_no) on delete cascade
);

INSERT INTO Employee VALUES
("01NB235", "Chandan_Krishna","Siddartha Nagar, Mysuru", "Male", 1500000, "01NB235", 5),
("01NB354", "Employee_2", "Lakshmipuram, Mysuru", "Female", 1200000,"01NB235", 2),
("02NB254", "Employee_3", "Pune, Maharashtra", "Male", 1000000,"01NB235", 4),
("03NB653", "Employee_4", "Hyderabad, Telangana", "Male", 2500000, "01NB354", 5),
("04NB234", "Employee_5", "JP Nagar, Bengaluru", "Female", 1700000, "01NB354", 1);

INSERT INTO Department VALUES
(001, "Human Resources", "01NB235", "2020-10-21"),
(002, "Quality Assesment", "03NB653", "2020-10-19"),
(003,"System assesment","04NB234","2020-10-27"),
(005,"Production","02NB254","2020-08-16"),
(004,"Accounts","01NB354","2020-09-4");

alter table Employee add constraint foreign key (d_no) references Department(d_no) on delete cascade;

INSERT INTO DLocation VALUES
(001, "Jaynagar, Bengaluru"),
(002, "Vijaynagar, Mysuru"),
(003, "Chennai, Tamil Nadu"),
(004, "Mumbai, Maharashtra"),
(005, "Kuvempunagar, Mysuru");

INSERT INTO Project VALUES
(241563, "System Testing", "Mumbai, Maharashtra", 004),
(532678, "IOT", "JP Nagar, Bengaluru", 001),
(453723, "Product Optimization", "Hyderabad, Telangana", 005),
(278345, "Yeild Increase", "Kuvempunagar, Mysuru", 005),
(426784, "Product Refinement", "Saraswatipuram, Mysuru", 002);

INSERT INTO WorksOn VALUES
("01NB235", 278345, 5),
("01NB354", 426784, 6),
("04NB234", 532678, 3),
("02NB254", 241563, 3),
("03NB653", 453723, 6);

SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM DLocation;
SELECT * FROM Project;
SELECT * FROM WorksOn;

-- Make a list of all project numbers for projects that involve an employee whose last name is ‘Scott’, either as a worker or as a manager of the department that controls the project.

select p_no,p_name from project p
join department d using(d_no)
join workson w using (p_no)
join employee e using (ssn)
where mgr_ssn in (select ssn from employee where name like "%Krishna%") 
or w.ssn in (select ssn from employee where name like "%Krishna%");

-- or
 -- here only p_no comes not names above query gives names also
select p_no from project
where d_no in (select d_no from department where mgr_ssn in (select ssn from employee where name like "%Krishna%"))
union 
select p_no from workson
where ssn in (select ssn from employee where name like "%Krishna%");

-- -------------------------------------------------------

-- Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10 percent raise

select e.name,e.salary as "Old Salary",e.salary*1.1 as "New Salary" from employee e
where d_no in (select d_no from project where p_name="IOT"); 

--or

select e.name,e.salary as "Old Salary",e.salary*1.1 as "New Salary" from employee e
join project p using(d_no)
where p.p_name="IOT";

-- --------------------------------------------------------

-- Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the maximum salary, the minimum salary, and the average salary in this department

select SUM(salary) as "Total",MAX(salary) as "Maximum",MIN(salary) as "Minimum",AVG(salary) as "Average"
from employee
where d_no in ( select d_no from department where dname="Accounts");

-- or

select SUM(salary) as "Total",MAX(salary) as "Maximum",MIN(salary) as "Minimum",AVG(salary) as "Average"
from employee 
join department using(d_no)
where dname="Accounts";

-- -------------------------------------------------------

-- Retrieve the name of each employee who works on all the projects controlled by department number 1 (use NOT EXISTS operator).

select Employee.ssn,name,d_no from Employee where not exists
    (select p_no from Project p where p.d_no=1 and p_no not in
    	(select p_no from WorksOn w where w.ssn=Employee.ssn));

-- --------------------------------------------------------

-- For each department that has more than one employees, retrieve the department number and the number of its employees who are making more than Rs. 6,00,000.

select d.d_no,COUNT(e.ssn) from department d
join employee e using(d_no)
where e.salary>600000
group by d.d_no
having count(e.ssn)>=2;

-- ----------------------------------------------------------

-- Create a view that shows name, dept name and location of all employees

create view Employee_Details as
select e.name,d.dname,dl.d_loc
from employee e
join department d using(d_no)
join dlocation dl using(d_no); 

select * from Employee_Details;

-- ---------------------------------------------------------

-- Create a trigger that prevents a project from being deleted if it is currently being worked by any employee.

delimiter //
create trigger Prevent_deletion
before delete on project
for each row 
if(old.p_no in (select p_no from workson))then
	signal sqlstate '45000' set message_text='This project has an employee assigned';
end if;//
delimiter ;

-- check trigger 
delete from Project where p_no=241563; 
