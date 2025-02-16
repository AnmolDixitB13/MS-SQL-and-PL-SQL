/*
A database for a gym, which offers 3 programs - CardioOnly, WeightsOnly and Both. There is a table
called gym that stores member id, name, date of joining, program opted for, fees, discount if any,
fees after discount. 

Write 4 procedures, one to perform each task - adding a member into the table gym, 
updating details of members present in gym table, reading list of records from the table gym and
deleting a record from the table gym.

Add suitable constraints to ensure
1. only the programs from CardioOnly, WeightsOnly or Both are only selected.
2. discount value can't be negative or greater than 50%.

*/

use mydb

create table gym(
m_id smallint primary key identity(1, 1),
m_name varchar(30) not null,
JoinDate date not null,
Program varchar(20) not null
) ;
-- date = 'yyyy-mm-dd'

alter table gym
add Fees float, Disc_Per float, Fees_After_Disc float ;
-- m_id, m_name, joinDate, Program, Fees, Disc_Per, Fees_After_Disc


alter table gym
add constraint chk_disc_per check(Disc_Per between 0 and 50) ;
-- fees discount percent can't be negative or too high


alter table gym
add constraint chk_prg check(Program in ('WeightsOnly', 'CardioOnly', 'Both')) ;


select * from gym ;

create procedure addMember
(@name varchar(30), @date date, @program varchar(20), @fees float output, @disc_per float, @feesToBePaid float output)
-- m_id, m_name, JoinDate, Program, Fees , Disc_Per, Fees_After_Disc
as
begin

if (@program = 'CardioOnly')
	begin
		select @fees = 5000 ;
		select str(@fees);
	end

else if (@program = 'WeightsOnly')
	begin
		select @fees = 5000 ;
		select str(@fees);
	end

else if (@program = 'Both')
	begin
		select @fees = 8000 ;
		select str(@fees);
	end

else
	begin
	select 'Invalid program selected.'
	end


select @feesToBePaid = (@fees - @fees*@disc_per/100) ;

insert into gym(m_name, JoinDate, Program, Fees, Disc_Per, Fees_After_Disc) output inserted.* values(@name, @date, @program, @fees, @disc_per ,@feesToBePaid) ;
-- @name varchar(30), @date date, @program varchar(10), @feesToBePaid float output
-- m_id, m_name, JoinDate, Program, Fees , Disc_Per, Fees_After_Disc

select * from gym ;
-- to display entire table O/P automatically everytime the procedure is executed

end ;

declare @nam varchar(30) = 'moo moo',
@dat date = '1997-7-3',
@prog varchar(20) = 'WeightsOnly',
@fee float,
@discPer float = 2,
@final_fee float ;
exec addMember @nam, @dat, @prog, @fee output, @discPer, @final_fee output ;
-- case insensitive @prog

----------------------------------------

create procedure deleteMember
(@rem_id smallint)
as
begin

if @rem_id not in (select m_id from gym)
print 'There is no member with this member id. Please recheck the member id and enter the correct member id.'

else
--begin
delete from gym
output deleted.*
where m_id = @rem_id ;
--end

select * from gym
end ;

declare @r_id smallint = 2;
exec deleteMember @r_id;

---------------------------------------------

create procedure readMembers
as
begin

select * from gym ;

end ;

exec readMembers ;

------------------------------------------

select * from gym
create procedure updateMember
(@u_id smallint, @optionNo tinyint, @newData varchar(30), @Fees float output, @Disc_Per float output,
@Fees_After_Disc float output)
as 
begin

if @u_id not in (select m_id from gym)
print 'There is no member with this member id. Please recheck the member id and enter the correct member id.'

if @optionNo = 1
update gym
set m_name = @newData where m_id = @u_id ;

else if @optionNo = 2
update gym
set JoinDate = @newData where m_id = @u_id ;

else if @optionNo = 3
begin
update gym
set Program = @newData where m_id = @u_id ;

if ((select Program from gym where m_id = @u_id) = 'CardioOnly')
	begin
		update gym
		set Fees = 5000 where m_id = @u_id 

		update gym
		set Fees_After_Disc = Fees - Disc_Per*Fees/100 where m_id = @u_id ;
		
		select @fees = 5000 ;
		select str(@fees);
	end

else if ((select Program from gym where m_id = @u_id) = 'WeightsOnly')
	begin

		update gym
		set Fees = 5000 where m_id = @u_id

		update gym
		set Fees_After_Disc = Fees - Disc_Per*Fees/100 where m_id = @u_id ;

		select @fees = 5000 ;
		select str(@fees);
	end

else if ((select Program from gym where m_id = @u_id) = 'Both')
	begin

		update gym
		set Fees = 8000 where m_id = @u_id ;

		update gym
		set Fees_After_Disc = Fees - Disc_Per*Fees/100 where m_id = @u_id ;

		select @fees = 8000 ;
		select str(@fees);
	end

else
	select 'Invalid program selected.'

select * from gym
end

/*else if @optionNo = 4
update gym
set Fees_Paid = @newData where m_id = @u_id ;*/

else if @optionNo = 4
begin
	update gym
	set Disc_Per = @newData where m_id = @u_id ;

	update gym	
	set Fees_After_Disc = Fees - Fees*disc_per/100 where m_id = @u_id ;
end
else
print 'Invalid option entered.'

end ;

declare @ud_id smallint = 7, 
@updateOptionNo tinyint = 2,
@updateNewData varchar(30) = '1998-12-23',
@updateFees int,
@updateDisc_Per float,
@updateFees_After_Disc float;

exec updateMember @ud_id, @updateOptionNo, @updateNewData, @updateFees output,
@updateDisc_Per output, @updateFees_After_Disc output;

select * from gym ;


-- Future scope / improvements in this program:
-- 
-- 1. If the memnbership of a member is about to end, say a week before the membership expires,
-- the user and the gym authorities should be prompted. Eg, user should be prompted by a mail on his / her
-- registered email id and the gym owner / gym branch staff should be notified using suitable notifications.
-- 
-- 2. Suitable try - catch constructs can be implemented at all the necessary places. This will ensure
-- that the program becomes more robust in terms of error / exception handling.
-- 
-- 3. Data validation at the time of account creation i.e. name, phone number, email id, etc are 
-- appropriate or not
