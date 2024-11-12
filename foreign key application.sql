/*
Create 2 tables - 1st table - Beneficiaries will contain the list of people i.e. their names with a
unique identification number. The unique identification number will act as primary key. Other table
ServicesApplied will contain services/government schemes for people have applied for. Only those whose names 
& unique identification no. are linked & registered in the previous table i.e. Beneficiaries can avail services.
*/

```sql

use mydb

create table Beneficiaries(
name varchar(30) not null,
id smallint primary key not null) ;

/* Assumptions made:
1.	Assuming that ids will be purely numerical and not alphanumeric, for alpha numeric ids, one
should prefer varchar(n) datatype and not numerical datatype(s).

2.	This program is only for testing the concept of foreign keys and won't be deployed as a full
fledge application or part of any full - fledge application. So, smallint would be sufficient to
store the values of the unique identification no (id). For real life applications, prefer int or 
bigint for the same. */

create table ServicesApplied(
name varchar(30) not null,
id2 smallint not null,
serviceApplied varchar(10) not null) ;

alter table ServicesApplied
add constraint fkey_id foreign key(id2) references Beneficiaries(id) ;

alter table ServicesApplied
add constraint chk_serviceApplied check(serviceApplied in ('scheme1', 'scheme2', 'scheme3', 
'scheme4', 'scheme5')) ;
-- Registered Benificiaries can select only from these services/schemes.

-- Register beneficiaries into the Beneficiaries table

insert into Beneficiaries values('aaa bbb', 1111) ; -- name, id
insert into Beneficiaries values('ccc ddd', 2222) ;
insert into Beneficiaries values('eee fff', 3333) ;
insert into Beneficiaries values('ggg', 4444) ;
insert into Beneficiaries values('hhh', 5555) ;
insert into Beneficiaries values('iii', 6666) ;

select * from Beneficiaries ;
select * from ServicesApplied ;

---------------------------------

create procedure EnterRecords
(@id smallint, @name varchar(30), @program varchar(10))
as 
begin

	if @id not in (select id from Beneficiaries)
		print 'User not registered, so cannot avail/apply for services.'
		-- double quotes throw error here
		-- verify whether the user is registered or not

	else if @name = (select name from Beneficiaries where id = @id)
			if @program in (select serviceApplied from ServicesApplied where id2=@id and name=@name)
				print 'The person with id '+str(@id) + ' and name ' + @name + ' has already applied
				for this scheme '+ @program + ' .' ;
			else
				begin
				insert into ServicesApplied output inserted.* values(@name,@id,@program) ;
				-- verify whether the name matches the id as in table Beneficiaries, then this person can
				-- avail/apply for schemes, else no
				end

	else
		print 'Invalid name/name mismatch.'

end

exec EnterRecords 1111, 'aaa bbb', 'scheme5'

select * from Beneficiaries
select * from ServicesApplied

/*
this is a relatively simpler version of the procedure that I had initially developed, but later modified
it & used the modified one as the final procedure for my code.

alter procedure EnterRecords
(@id smallint, @name varchar(30), @program varchar(50))
as 
begin

	if @id not in (select id from Beneficiaries)
		print 'User not registered, so cannot avail/apply for services'
		-- double quotes throw error here
		-- verify whether the user is registered or not

	else if @name = (select name from Beneficiaries where id = @id)
	begin
		insert into ServicesApplied output inserted.* values(@name,@id,@program) ;
		-- verify whether the name matches the id as in table Beneficiaries, then this person can
		-- avail/apply for schemes, else no
	end
else
print 'Invalid name/name mismatch.'

end

*/

```
