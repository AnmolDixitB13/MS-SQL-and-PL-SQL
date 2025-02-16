-- cursor application when data from multiple tables have to be fetched
-- table 1 = customer points
-- table 2 = pending amount
-- table 3 = approval / eligibility
-- fetch data from tables 1 & 2, join based on unique id, check eligibility 
-- & write eligible or not eligible for new scheme in the table 3 
-- depending upon conditions using cursor & procedure

create database cursor_proj ;

use cursor_proj ;

truncate table customer_points ;
truncate table customer_pending_amount ;
truncate table customers_applied_for_new_scheme ;

create table customer_points(
cus_id smallint not null,
cus_points smallint
) ;

alter table customer_points
add constraint p_key primary key(cus_id) ;

insert into customer_points output inserted.*
values(1, 1000), (2, 230), (3, 0), (4, 0), (5, 110), (6, 618), 
(7, 52), (8, 79), (9, 1), (10, 36), (11, 865), (12, 12) ;

------------------------

create table customer_pending_amount(
cus_id smallint not null,
cus_pending_amt smallint
) ;

alter table customer_pending_amount
add constraint f_key foreign key(cus_id) references customer_points(cus_id) ;

alter table customer_pending_amount
drop constraint f_key ;

-- drop table customer_pending_amount ;

insert into customer_pending_amount output inserted.*
values(1, 0), (2, 0), (3, 0), (4, 0), (5, 10), (6, 120), 
(7, 45), (8, 90), (9, 1), (10, 2), (11, 7500), (12, 65) ;

------------------------

create table customers_applied_for_new_scheme(
cus_id smallint not null,
eligibility varchar(20)
) ;

alter table customers_applied_for_new_scheme
add constraint chk_eligibility check(eligibility in ('eligible', 'not eligible')) ;

insert into customers_applied_for_new_scheme(cus_id) output inserted.*
select cus_id from customer_points ;
------------------------

select * from customer_points ;
select * from customer_pending_amount ;
-- select * from temp ;
select * from customers_applied_for_new_scheme ;


------------------------

exec cursor_proc ;

create or alter procedure cursor_proc
as begin

create table #temp(
cus_id smallint,
cus_points smallint,
cus_pending_amt smallint
) ;

insert into #temp output inserted.*
select t1.cus_id, t1.cus_points, t2.cus_pending_amt
from customer_points t1
join customer_pending_amount t2
on t1.cus_id = t2.cus_id ;

declare cur cursor
for
select * from #temp ;

open cur ;

declare 
@c_id smallint,
@c_points smallint,
@cus_pend_amt smallint ;

fetch next from cur into @c_id, @c_points, @cus_pend_amt ;

while @@fetch_status = 0
begin
if @c_points >= 50 and @cus_pend_amt <= 10
	begin
	update customers_applied_for_new_scheme
	set eligibility = 'Eligible' where cus_id = @c_id ;
	end ;

else
	begin
	update customers_applied_for_new_scheme
	set eligibility = 'Not eligible' where cus_id = @c_id ;
	end ;

fetch next from cur into @c_id, @c_points, @cus_pend_amt ;
end ;	-- end of while loop

close cur ;
deallocate cur ;

select * from customers_applied_for_new_scheme ;
end ;	-- end of procedure

