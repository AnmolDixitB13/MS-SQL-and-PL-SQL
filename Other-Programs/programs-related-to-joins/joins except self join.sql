use mydb

create table stud_name(
roll smallint not null primary key,
name varchar(30)) ;

create table stud_per(
roll smallint not null primary key,
per decimal(5, 2)) ;

insert into stud_name output inserted.* values(1, 'abc'), (2, 'def'), (3, 'ghi'), (4, 'jkl'), (101, 'mno'), (102, 'pqr'), (103, 'stu'), (104, 'vwx')

insert into stud_per output inserted.* values(1, 53.45), (2, 100), (3, 45.3), (4, 67.433), (5, 98), (10, 76.34), (12, 90), (11, 63)

select * from stud_name ; -- left table
select * from stud_per ; -- right table

-- left join

select * from stud_name ; -- left table
select * from stud_per ; -- right table

select t1.roll, t1.name, t2.per, t2.roll_no
from stud_name t1 left join stud_per t2
on t1.roll = t2.roll_no ;


-- right join

select * from stud_name ; -- left table
select * from stud_per ; -- right table

select t1.roll, t1.name, t2.per, t2.roll_no
from stud_name t1 right join stud_per t2
on t1.roll = t2.roll_no ;

-- inner join

select * from stud_name ; -- left table
select * from stud_per ; -- right table

select t1.roll, t1.name, t2.per, t2.roll_no
from stud_name t1 join stud_per t2
on t1.roll = t2.roll_no ;

-- full join

select * from stud_name ; -- left table
select * from stud_per ; -- right table

select t1.roll, t1.name, t2.per, t2.roll_no
from stud_name t1 full join stud_per t2
on t1.roll = t2.roll_no ;

-- left to right & vice versa

select t1.roll, t1.name, t2.per, t2.roll_no
from stud_name t1 left join stud_per t2
on t1.roll = t2.roll_no ;

select t1.roll, t1.name, t2.per, t2.roll_no
from stud_per t2 right join stud_name t1
on t1.roll = t2.roll_no ;

exec sp_rename 'stud_per.roll', 'roll_no', 'column' ;