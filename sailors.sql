create database sailors;
use sailors;

create table Sailors(
	sid int primary key,
	sname varchar(35) not null,
	rating float not null,
	age int not null
);

create table Boat(
	bid int primary key,
	bname varchar(35) not null,
	color varchar(25) not null
);

create table reserves(
	sid int not null,
	bid int not null,
	sdate date not null,
	foreign key (sid) references Sailors(sid) on delete cascade,
	foreign key (bid) references Boat(bid) on delete cascade
);

insert into Sailors values
(1,"Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);


insert into Boat values
(1,"Boat_1", "Green"),
(2,"Boat_2", "Red"),
(103,"Boat_3", "Blue");

insert into reserves values
(1,103,"2023-01-01"),
(1,2,"2023-02-01"),
(2,1,"2023-02-05"),
(3,2,"2023-03-06"),
(5,103,"2023-03-06"),
(1,1,"2023-03-06");

select * from Sailors;
select * from Boat;
select * from reserves;


-- Find the colours of the boats reserved by Albert

select color from boat
join reserves r using(bid)
join sailors s using(sid)
where s.sname="Albert";

-- --------------------------------------------------

-- Find all the sailor sids who have rating atleast 8 or reserved boat 103

select s.sid from sailors s 
join reserves r using(sid)
where rating>=8 or r.bid=103;

-- --------------------------------------------------

-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order

select sid from sailors 
where sid not in (select distinct sid from reserves) 
and sname like "%storm%"
order by sname;

-- --------------------------------------------------

-- Find the name of the sailors who have reserved all boats

select sname from Sailors s where not exists
	(select * from Boat b where not exists
		(select * from reserves r where r.sid=s.sid and b.bid=r.bid));
        
-- ----------------------------------------------------

-- Find the name and age of the oldest sailor

select sname,age from sailors
order by age desc limit 1;

-- ------------------------------------------------------

-- For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and average age of such sailors

select b.bid,AVG(s.age)
from sailors s
join reserves r using(sid)
join boat b using(bid)
where s.age>=40
group by bid
having count(s.sid)>=2;

-- ------------------------------------------------------

-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.

create view Boat_Color as
select b.bname,b.color
from boat b
join reserves r using(bid)
join sailors s using(sid)
where s.rating=7;   -- use "like" instead of "=" , for eg: "s.rating like 6.5" etc... 

select* from Boat_Color;

-- ----------------------------------------------------

-- Trigger that prevents boats from being deleted if they have active reservation

delimiter //
create trigger Prevent_Deletion
before delete on boat
for each row 
begin
if ( old.bid in (select distinct bid from boat) )then
	SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
end if;
end//
delimiter ;

-- check trigger

delete from Boat where bid=103;

