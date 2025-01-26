
use mydb

create table emp_records(
emp_id tinyint primary key,
product_sales smallint,
monthly_bonus_percent float,
monthly_emp_sal float
) ;

alter table emp_records
add monthly_sal_with_bonus float ;

insert into emp_records values(1, 10, 0, 50), (2, 23, 0, 89), 
(3, 9, 0, 50), (4, 45, 0, 90), (5, 76, 0, 100), (6, 41, 0, 100), 
(7, 32, 0, 65), (8, 45, 0, 87), (9, 42, 0, 78), (10, 2, 0, 67), 
(11, 1, 0, 54), (12, 80, 0, 79), (13, 96, 0, 96) ;

-- a cursor to read all the records from the given table

declare read_emp_records cursor
for
select * from emp_records ;

open read_emp_records ;

while @@FETCH_STATUS = 0
begin
	declare 
	@var1 tinyint,
	@var2 smallint,
	@var3 float,
	@var4 float,
	@var5 float ;

	fetch next from read_emp_records into @var1, @var2, @var3, @var4, @var5 ;
	print @var1 ;
	print @var2 ;
	print @var3 ;
	print @var4 ;
	print @var5 ;
	print '____________' ;
end ;

close read_emp_records ;

deallocate read_emp_records ;

--------------------------------------------------------------
-- cursor to give bonus to employees based on their product sales
-- product sales > 80, 200% bonus
-- product sales in range 50 - 80, 100% bonus, 30 - 50, 50%bonus, 
-- otherwise 20% bonus

declare emp_bonus_cursor cursor
for
select emp_id, product_sales from emp_records ;

declare
@e_id tinyint,
@prod_sales smallint ;

open emp_bonus_cursor ;

fetch next from emp_bonus_cursor into @e_id, @prod_sales ;

while @@fetch_status = 0
begin
	if @prod_sales > 80
	begin
		update emp_records
		set monthly_bonus_percent = 200 where emp_id = @e_id ;

		update emp_records
		set monthly_sal_with_bonus = monthly_emp_sal + 2 * monthly_emp_sal where emp_id = @e_id ;
	end ;

	else if @prod_sales > 50 and @prod_sales <= 80
	begin
		update emp_records
		set monthly_bonus_percent = 100 where emp_id = @e_id ;

		update emp_records
		set monthly_sal_with_bonus = monthly_emp_sal + 1 * monthly_emp_sal where emp_id = @e_id ;
	end ;

	else if @prod_sales > 30 and @prod_sales <= 50
	begin
		update emp_records
		set monthly_bonus_percent = 50 where emp_id = @e_id ;

		update emp_records
		set monthly_sal_with_bonus = monthly_emp_sal + 0.5 * monthly_emp_sal where emp_id = @e_id ;
	end ;

	else
	begin
		update emp_records
		set monthly_bonus_percent = 20 where emp_id = @e_id ;

		update emp_records
		set monthly_sal_with_bonus = monthly_emp_sal + 0.2 * monthly_emp_sal where emp_id = @e_id ;
	end ;


	fetch next from emp_bonus_cursor into @e_id, @prod_sales ;
end ;

close emp_bonus_cursor ;

deallocate emp_bonus_cursor ;

select * from emp_records ;
