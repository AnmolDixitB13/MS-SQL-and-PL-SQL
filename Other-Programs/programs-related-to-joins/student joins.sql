use mydb

create table Students(
roll tinyint primary key,
name varchar(20)
) ;

create table Program1_Participants(
roll tinyint primary key,
name varchar(20)
) ;

create table Program2_Participants(
roll tinyint primary key,
name varchar(20)
) ;

alter table Program1_Participants
add constraint fkey1 foreign key(roll) references Students(roll) ;

alter table Program2_Participants
add constraint fkey2 foreign key(roll) references Students(roll) ;

insert into Students output inserted.* values(1, 'aaa'), (2, 'bbb'), (3, 'ccc'), (4, 'ddd'), 
(5, 'eee'), (6, 'fff'), (7, 'ggg'), (8, 'hhh'), (9, 'iii'), (10, 'jjj')

insert into Program1_Participants output inserted.* values(1, 'aaa'), (2, 'bbb'), (3, 'ccc')

insert into Program2_Participants output inserted.* values(3, 'ccc'), (4, 'ddd'), (5, 'eee')

create or alter proc select_tables
as begin
select * from Program1_Participants ;
select * from Program2_Participants ;
end ;

-- students who participated in both the programs using joins

select *
from Program1_Participants p1
join Program2_Participants p2
on p1.roll = p2.roll ;

exec select_tables ;

-- this approach also works fine
select *
from Students s
join Program1_Participants p1
on s.roll = p1.roll
join Program2_Participants p2
on p1.roll = p2.roll ;

exec select_tables ;

-- students who participated in none of the programs using joins
select s.*
from Students s
left join Program1_Participants p1
  on s.roll = p1.roll
left join Program2_Participants p2
  on s.roll = p2.roll
where (p1.roll is null and p2.roll is null);  -- Participated in none of the programs


-- students who participated only in program2 using joins
select s.*
from Students s
left join Program1_Participants p1
  on s.roll = p1.roll
left join Program2_Participants p2
  on s.roll = p2.roll
where (p1.roll is null and p2.roll is not null);  -- Participated only in Program 2

exec select_tables ;

-- find out using joins all the students who participated in program 2
select *
from Students s
join Program2_Participants p2
on s.roll = p2.roll ;

-- students who participated in either of the programs, but not in both, using joins
select s.*
from Students s
left join Program1_Participants p1
  on s.roll = p1.roll
left join Program2_Participants p2
  on s.roll = p2.roll
where (p1.roll is not null and p2.roll is null)   -- Participated only in Program 1
   or (p1.roll is null and p2.roll is not null);  -- Participated only in Program 2



-- try same thing using sub queries also