
-- The company database consists of 2 tables - emp_official and emp_personal. Unless the official details
-- of the employee are not entered into emp_official, employee's personal details can't be entered into
-- the emp_personal table. This is achieved using a foreign key on emp_personal table, which references
-- the emp_id in the emp_official table.
-- 
-- Create suitable procedures to add, update, read & delete from the tables mentioned above.
-- 
-- Create suitable triggers that will fire when insert, update or delete operations will be performed
-- on the 2 tables talked above.
-- 
-- Add constraints at the suitable tables to ensure:
--
-- 1. 3 types of employment are offered by the company - internship, part time & full time
-- 2. Salary >= 0 i.e. non - negative
-- 3. Salary can't be 0 for part & full time employees, for interns it can be 0
-- 4. Default location is Mumbai


-- Major concepts used in this program:
-- Concept of procedures 
-- Concept of triggers
-- Concept of foreign key

------------------------------------------------------------------------------------------
use mydb

----------------	Creating 2 tables & connecting them via a Foreign Key	-----------------

create table emp_official(
emp_id varchar(20) primary key,
emp_name varchar(30) not null,
emp_location varchar(15),
emp_hiredate date not null,		--yyyy-mm-dd
emp_dob date not null,
emp_sal float not null,
emp_designation varchar(20),
emp_type varchar(15) not null
) ;
-- this table will store the official details of it's employees

create table emp_personal(
emp_id varchar(20),
emp_name varchar(30),
emp_age_years tinyint not null,
emp_dob date not null,
emp_res_add text,
emp_email_id varchar(20) unique not null,
emp_mot_name varchar(30),
emp_fat_name varchar(30),
emp_uid_no varchar(20) unique not null
) ;
-- this table will store the personal details of it's employees whose records are present
-- in the previous table


alter table emp_personal
add constraint f_k foreign key(emp_id) references emp_official(emp_id)
-- this constraint links the previous 2 tables


---------------		Adding suitable constraints		-----------------
-- add default location of Mumbai
alter table emp_official
add constraint def_emp_location default 'Mumbai' for emp_location ;

-- add sal const, sal >= 0
alter table emp_official
add constraint chk_sal check(emp_sal >= 0) ;

-- add check const for emp_type
alter table emp_official
add constraint chk_emp_type check(emp_type in ('Internship', 'Part time', 'Full time')) ;

------------------------------------------------------------------------------------------------
alter table emp_official
drop constraint chk_emp_type, chk_sal, f_k

------------------------------------------------------------------------------------------------


------------------		Creating procedure for emp_official table		--------------------

-- prefix off indicates data has to be sent to official table, emp_official

create or alter procedure readDelUp_op_emp_official
(@optionNo float, @off_id varchar(20) null, @off_data varchar(30), @proceed bit output)
as begin
declare @oldData varchar(30) 

if @optionNo between 1 and 4
	begin
	print 'Option no: Valid'

	if @off_id in (select emp_id from emp_official)
		begin
		set @proceed = 1 ;	
		end ;

	if @off_id not in (select emp_id from emp_official)
		begin
		set @proceed = 0 ;
		end ;

	if @optionNo = 1
		begin
			if @proceed = 1
				begin
				select * from emp_official where emp_id = @off_id ;
				print 'Read request execution: successful' ;
				print 'case 1 executed' ;
				end ;

			else
				begin
				print 'There is no employee with the Employee ID ' + cast(@off_id as varchar(20)) + '.'
				print 'Read request execution: unsuccessful'
				end

		end ;	-- end of optionNo 1

	if @optionNo = 2
		begin
			if @proceed = 1
				begin
				select * from emp_official where emp_id = @off_id ;
				-- This line is an alternative to the output clause, because since there are triggers
				-- associated with the emp_official table, output clause cannot be used directly.

				delete from emp_official where emp_id = @off_id
				print 'Delete request execution: successful'
				print 'case 2 executed'
				end

			else
				begin
				print 'There is no employee with the Employee ID ' + cast(@off_id as varchar(20)) + '.'
				print 'Delete request execution: unsuccessful'
				end
		end ;

			-- end of optionNo 2
-- emp_name, emp_location, emp_hiredate, emp_dob, emp_sal , emp_designation , emp_type varchar(15) 
	if @optionNo between 3 and 4
		begin
		if @proceed = 1
			begin

			if @optionNo = 3.1
				begin
					--oldData = select emp_name from emp_official where emp_id = @off_id ;

					update emp_official
					set emp_name = @off_data where emp_id = @off_id ;

					select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

					print 'case 3.1 executed'
					print 'Emplooyee Name updation successful.'
					--print 'Employee Name changed from ' + oldData + ' ' + @off_data + '.'
				end ;
					-- end of optionNo 3.1

			if @optionNo = 3.2
				begin
					update emp_official
					set emp_location = @off_data where emp_id = @off_id ;

					select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

					print 'case 3.2 executed'
					print 'Employee Location updation successful.'
				end ;
					-- end of optionNo 3.2

			if @optionNo = 3.3
				begin
					update emp_official
					set emp_hiredate = @off_data where emp_id = @off_id ;

					select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

					print 'case 3.3 executed'
					print 'Employee Hiredate updation successful.'
				end ;
					-- end of optionNo 3.3

			if @optionNo = 3.4
				begin
					update emp_official
					set emp_dob = @off_data where emp_id = @off_id ;

					select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

					print 'case 3.4 executed'
					print 'Employee DOB updation successful.'
				end ;
					-- end of optionNo 3.4

			if @optionNo = 3.5
				begin
					if @off_data < 0
						begin
						print 'Salary cannot be less than 0.'
						print 'Employee Salary updation failed.'
						end

					else if @off_data = 0
						begin
						declare @temp varchar(15)
						select @temp = emp_type from emp_official where emp_id = @off_id ;

						if @temp like 'Intern'
							begin
							update emp_official
							set emp_sal = @off_data where emp_id = @off_id ;
							select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

							end ;

						else
							begin
							print 'Part time and full time employees cannot have zero salary.'
							print 'Employee Salary updation failed.'
							end ;
						end ;
					else if @off_data > 0
						begin
						update emp_official
						set emp_sal = @off_data where emp_id = @off_id ;

						select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

						print 'case 3.5 executed'
						print 'Employee Salary updation successful.'
						end ;
				end ;
					-- end of optionNo 3.5

			if @optionNo = 3.6
				begin
					update emp_official
					set emp_designation = @off_data where emp_id = @off_id ;

					select * from emp_official where emp_id = @off_id ;
					-- This line is an alternative to the output clause, because since there are triggers
					-- associated with the emp_official table, output clause cannot be used directly.

					print 'case 3.6 executed'
					print 'Employee Designation updation successful.'
				end ;
					-- end of optionNo 3.6

			if @optionNo = 3.7
				begin
					update emp_official
					set emp_type = @off_data where emp_id = @off_id ;

					if @@ROWCOUNT > 0
						begin
						select * from emp_official where emp_id = @off_id ;
						-- This line is an alternative to the output clause, because since there are triggers
						-- associated with the emp_official table, output clause cannot be used directly.

						print 'case 3.7 executed'
						print 'Employement Type updation successful.'
						end ;
				end ;
					-- end of optionNo 3.7
			end ;	-- end of inner if 

		else
			begin
			print 'There is no employee with the Employee ID ' + cast(@off_id as varchar(20)) + '.'
			print 'Request execution: unsuccessful'
			end ;

			end ;	-- end of outer if, if @optionNo between 4 and 5...

	end ;		-- end of outermost if
else
	begin
	print 'Option number ' + cast(@optionNo as varchar(2)) + ' is invalid.'
	end ;


	
end ; -- end of procedure readDelUp_op_emp_official
-- option, id, data

declare @off_proceed bit ;

exec readDelUp_op_emp_official 
@optionNo = 3.7,
@off_id = '2223',
@off_data = 'meow',
@proceed =@off_proceed output ;
select * from emp_official ;


drop table emp_official, emp_personal

select * from emp_official

-- PK__emp_offi__1299A861F65D0FB5

create or alter procedure add_op_emp_official
(@param1_off varchar(20), @param2_off varchar(30), @param3_off varchar(15), @param4_off date,
@param5_off date, @param6_off float, @param7_off varchar(20), @param8_off varchar(15))
as begin

	if @param1_off in (select emp_id from emp_official)
		begin
		print 'The official details of the employee with the employee id ' + @param1_off + ' are already present in the company table for employee official data.' ;
		print 'Insert Request: Ignored' ;
		select * from emp_official where emp_id = @param1_off ;
		end

	else if @param8_off in ('Part time', 'Full time') and @param6_off = 0
		begin
		print 'Part time & full time employees cannot have 0 salary.'
		print 'Insert Request: Unsuccessful' ;
		end ;

	else
		begin
		insert into emp_official values(@param1_off, @param2_off, @param3_off, @param4_off, @param5_off, @param6_off, @param7_off, @param8_off) ;

		select * from emp_official where emp_id = @param1_off ;
		-- this line has been used/ written as an alternative to the output clause because 
		-- output clause cannot be used directly when trigger(s) is/are associated with the table

		select * from emp_official ;

		print 'Insert Request: Executed Successfully.'
		end ;
end ;


declare
@emp_id_off varchar(20) = '456' ,
@emp_name_off varchar(30) = 'www' ,
@emp_location_off varchar(15) ,
@emp_hiredate_off date = '2000-12-31' ,
@emp_dob_off date = '1983-03-19' ,
@emp_sal_off float = 10000,
@emp_desig_off varchar(20) = 'Jun. Engg' ,
@emp_type_off varchar(15) = 'part time' 

exec add_op_emp_official @emp_id_off, @emp_name_off, @emp_location_off, @emp_hiredate_off,
@emp_dob_off, @emp_sal_off, @emp_desig_off, @emp_type_off


------------------		Creating triggers for emp_official table		--------------------

create table Activity_emp_official(
emp_id varchar(20),
task nvarchar(max),
dattim date
) ;

-- trigInsertEmpOfficial
-- trigUpdateEmpOfficial
-- trigDeleteEmpOfficial

create or alter trigger trigInsertEmpOfficial
on emp_official
for insert
as begin
declare @id varchar(20) ;
declare @msg nvarchar(max) ;

select @id = emp_id from inserted ;
select @msg = 'Data of the employee with employee id ' + @id + ' entered into the company table for official data.' ;

insert into Activity_emp_official output inserted.* values(@id, @msg, getdate()) ;
print 'Trigger trigInsertEmpOfficial fired.'

end ;

create or alter trigger trigUpdateEmpOfficial
on emp_official
for update
as begin
declare @id varchar(20) ;
declare @msg nvarchar(max) ;

select @id = emp_id from inserted ;
select @msg = 'Data of the employee with employee id ' + @id + ' has been updated in the company table for official data.' ;

insert into Activity_emp_official output inserted.* values(@id, @msg, getdate()) ;
print 'Trigger trigUpdateEmpOfficial fired.'

end ;

create or alter trigger trigDeleteEmpOfficial
on emp_official
for delete
as begin
declare @id varchar(20) ;
declare @msg nvarchar(max) ;

select @id = emp_id from deleted ;
select @msg = 'Data of the employee with employee id ' + @id + ' has been deleted from the company table for official data.' ;

insert into Activity_emp_official output inserted.* values(@id, @msg, getdate()) ;
print 'Trigger trigDeleteEmpOfficial fired.'

end ;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


------------------		Creating procedure for emp_personal table		--------------------

-- prefix per indicates that the data has to be sent to the personal table, emp_personal
create or alter procedure readDelUp_op_emp_personal
(@optionNo float, @per_id varchar(20), @per_data varchar(30))
as begin
declare @oldData varchar(30) 

if @optionNo between 1 and 4
	begin
	print 'Option no: Valid'

	if @per_id not in (select emp_id from emp_personal)
		begin
		print 'There is no employee with the Employee ID ' + cast(@per_id as varchar(20)) + ' in this table of Employee Personal Details.'
		print 'Request execution: unsuccessful'
		end ;

	else --if @per_id in (select emp_id from emp_personal)
		begin
		if @optionNo = 1
				begin
				select * from emp_personal where emp_id = @per_id ;
				print 'Read request execution: successful' ;
				print 'case 1 executed' ;
				end ;

			-- end of optionNo 1

	if @optionNo = 2

				begin
				select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal

				delete from emp_personal where emp_id = @per_id ;
				print 'Delete request execution: successful'
				print 'case 2 executed'
				end

			-- end of optionNo 2
-- emp_name, emp_location, emp_hiredate, emp_dob, emp_sal , emp_designation , emp_type varchar(15) 
	if @optionNo between 3 and 4
		begin

			if @optionNo = 3.1
				begin
					--oldData = select emp_name from emp_official where emp_id = @off_id ;

					update emp_personal
					set emp_name = @per_data where emp_id = @per_id ;

					select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal
					print 'case 3.1 executed'
					print 'Emplooyee Name updation successful.'
					--print 'Employee Name changed from ' + oldData + ' ' + @off_data + '.'
				end ;
					-- end of optionNo 3.1

			if @optionNo = 3.2
				begin
					update emp_personal
					set emp_dob = @per_data where emp_id = @per_id ;

					update emp_personal
					set emp_age_years = datediff(year, @per_data, getdate()) ;
					
					print 'case 3.2 executed'
					print 'Employee DOB & Age updation successful.'
				end ;
					-- end of optionNo 3.2

			if @optionNo = 3.3
				begin
					update emp_personal
					set emp_res_add = @per_data where emp_id = @per_id ;

				select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal
					print 'case 3.3 executed'
					print 'Employee Residential Address updation successful.'
				end ;
					-- end of optionNo 3.3

			if @optionNo = 3.4
				begin
					update emp_personal
					set emp_email_id = @per_data where emp_id = @per_id ;

				select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal
					print 'case 3.4 executed'
					print 'Employee Personal Email ID updation successful.'
				end ;
					-- end of optionNo 3.4

			if @optionNo = 3.5
				begin
					update emp_personal
					set emp_mot_name = @per_data where emp_id = @per_id ;

					select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal
					print 'case 3.5 executed'
					print 'Employee Mother Name updation successful.'
				end ;
					-- end of optionNo 3.5

			if @optionNo = 3.6
				begin
					update emp_personal
					set emp_fat_name = @per_data where emp_id = @per_id ;

					select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal
					print 'case 3.6 executed'
					print 'Employee Father Name updation successful.'
				end ;
					-- end of optionNo 3.6 

			if @optionNo = 3.7
				begin
					update emp_personal
					set emp_uid_no = @per_data where emp_id = @per_id ;

					select * from emp_personal where emp_id = @per_id ;
				-- this line has been written as an alternative to the output clause, because output
				-- clause cannot be used directly here as there are triggers associated with  the 
				-- table emp_personal
					print 'case 3.7 executed'
					print 'Employee UID No. updation successful.'
				end ;
					-- end of optionNo 3.7
			end ;	-- end of inner if , 
			end
	end
		else
			begin
			print 'Invalid Option no entered.'
			end ;	
		end ;


exec readDelUp_op_emp_personal
@optionNo = 3.6,
@per_id = '223',
@per_data = 'eea' ;


-- PK__emp_offi__1299A861F65D0FB5

create or alter procedure add_op_emp_personal
(@param1_per varchar(20), @param2_per varchar(30), @param3_per tinyint, @param4_per date,
@param5_per text, @param6_per varchar(20), @param7_per varchar(30), @param8_per varchar(30), @param9_per varchar(20))
as begin

	if @param1_per in (select emp_id from emp_personal)
		begin
		print 'Personal Data of the employee with employee id ' + @param1_per + ' is already present in the company table for the employee personal data.'
		print 'Insert Request: Ignored'
		select * from emp_personal where emp_id = @param1_per ;
		end

	else
		begin

		select @param3_per = datediff(year, @param4_per, getdate()) ;
		
		insert into emp_personal values(@param1_per, @param2_per, @param3_per, @param4_per, @param5_per, @param6_per, @param7_per, @param8_per, @param9_per)
		
		if @@ROWCOUNT > 0
			begin

			select * from emp_personal where emp_id = @param1_per ; 
			-- this line has been used/written as an alternative to the output clause because
			-- output clause cannot be used directly when trigger(s) is/are associated with the table

			select * from emp_personal ;
			print 'Insert Request: Executed.'

			end ;
		end ;
end ;


declare
@emp_id_per varchar(20) = '456',
@emp_name_per varchar(30) = 'www',
@emp_age_years_per tinyint = null,
@emp_dob_per date = '1983-03-19',
@emp_res_add_per nvarchar(max) = 'dddd wwwwwww kkkkkkk jjjjjjj ',
@emp_email_id_per varchar(20) = 'www@domainName.com',
@emp_mot_name_per varchar(20) = ' mot',
@emp_fat_name_per varchar(15) = ' fat',
@emp_uid_no_per varchar(20) = 'ww ww' ;

exec add_op_emp_personal @emp_id_per, @emp_name_per, @emp_age_years_per, @emp_dob_per,
@emp_res_add_per, @emp_email_id_per, @emp_mot_name_per, @emp_fat_name_per, @emp_uid_no_per ;



------------------		Creating triggers for emp_personal table		--------------------

-- trigInsertEmpPersonal
-- trigUpdateEmpPersonal
-- trigDeleteEmpPersonal

create table Activity_emp_personal(
emp_id varchar(20),
task nvarchar(max),
dattim date
) ;


create or alter trigger trigInsertEmpPersonal
on emp_personal
for insert
as begin
declare @id varchar(20) ;
declare @msg nvarchar(max) ;

select @id = emp_id from inserted ;
select @msg = 'Data of the employee with employee id ' + @id + ' entered into the company table for personal data.' ;

insert into Activity_emp_personal output inserted.* values(@id, @msg, getdate()) ;
print 'Trigger trigInsertEmpPersonal fired.'

end ;

create or alter trigger trigUpdateEmpPersonal
on emp_personal
for update
as begin
declare @id varchar(20) ;
declare @msg nvarchar(max) ;

select @id = emp_id from inserted ;
select @msg = 'Data of the employee with employee id ' + @id + ' has been updated in the company table for personal data.' ;

insert into Activity_emp_personal output inserted.* values(@id, @msg, getdate()) ;
print 'Trigger trigUpdateEmpPersonal fired.'

end ;

create or alter trigger trigDeleteEmpPersonal
on emp_personal
for delete
as begin
declare @id varchar(20) ;
declare @msg nvarchar(max) ;

select @id = emp_id from deleted ;
select @msg = 'Data of the employee with employee id ' + @id + ' has been deleted from the company table for personal data.' ;

insert into Activity_emp_personal output inserted.* values(@id, @msg, getdate()) ;
print 'Trigger trigDeleteEmpPersonal fired.'

end ;


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


-- Constraints
-- If there are triggers associated with a table, then the output clause can't be used on such table.
-- Still, if one wants to use the output clause on such tables, that have triggers associated with
-- them, one has to use 
------------------------------------------------------------------------------------------
-- Future improvements possible in this code 

1. 
-- everywhere we are updating the details, it is better to use this
-- if @@rowcount > 0
-- print 'Employee detail updation successful'
-- else
-- print 'Employee detail updation unsuccessful'
 
-- this is recommemded because if in case, because of an error which is beyond the programmer's 
-- control, the detail was unable to be updated by SQL, so it should be highlighted to us. Only
-- when the updation is successful, it should print updation successful, and not otherwise

2.
-- more data fields can be included into the emp_official and emp_personal tables such as blood group,
-- medical history, handicap/specially abled status, PF/EPF to opt/not to opt, etc.

3.
-- Suitable try - catch constructs can be implemented at all the necessary places. This will make
-- the program more robust in terms of error / exception handling.

4.
-- Data validation at the time of record creation i.e. name, phone number, email id, etc are 
-- appropriate or not
