create database mytest ;

use mytest ;

create table table1(
id1 tinyint not null,
gid1 tinyint not null
) ;

create table table2(
id2 tinyint,
gid2 tinyint
) ;

alter table table1
add constraint p_key primary key (id1, gid1) ;

alter table table2
add constraint f_key foreign key (id2, gid2) references table1(id1, gid1) ;

insert into table1 output inserted.* values(1, 101), (2, 102), (3, 103), (4, 104) ; 
-- both the id's - id & gid are different and unique i.e. all set of values are unique
-- no errors while inserting these set of values into the table table1

insert into table1 output inserted.* values(1, 105), (2, 106), (7, 101), (8, 102) ;
-- either of the id, either id or gid is already present in some or the other records in the table table1
-- no errors while inserting these set of values into the table table1

insert into table1 output inserted.* values(1, 101) ;
-- both the id's - the id combination is already present in the table table1
-- error while inserting this set of value into the table table1
-- Violation of PRIMARY KEY constraint 'p_key'. Cannot insert duplicate key in object 'dbo.table1'. 
-- The duplicate key value is (1, 101).

-- SUMMARY: 
-- If (X, Y) are 2 columns that together constitute primary key or unique key in the table, atleast one of
-- values must be different for the key to be a unique key as a whole.


-- inserting records in the table table2 where where id & gid of table1 will be used as foreign keys

insert into table2 output inserted.* values(1, 101), (2, 102) ;
-- no error was thrown while inserting these set of pairs in the table table2, because these pairs
-- are present in the table table1

insert into table2 output inserted.* values(1, 222) ;
insert into table2 output inserted.* values(100, 101) ;
-- these pairs of values are partially different, error was thrown while executing the above lines
-- The INSERT statement conflicted with the FOREIGN KEY constraint "f_key". The conflict occurred
-- in database "mytest", table "dbo.table1".

insert into table2 output inserted.* values(76, 89) ;
-- the set of value is completely different than the one present in the table table1, so identical
-- error, as occurred in the previous 2 lines, also occurred here


select * from table1 ;
select * from table2 ;