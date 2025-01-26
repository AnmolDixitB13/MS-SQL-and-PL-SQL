/*

An sql backend for a B. Tech college library. 

The following tasks are to be performed:


space for question

constraints, like max books that can be borrowed

basic proc for lending, returning...
*/

----------------------------------------------------------------------------

create database book_library
use book_library

-----------------------------------

create table Books(
b_id varchar(10) not null,
b_name varchar(20) not null,
b_author varchar(20) not null,
b_quantity_shelf smallint not null ) ;

alter table Books
add constraint pkey_b_id primary key(b_id) ;

insert into Books output inserted.* values ('b1', 'java for beginners', 'author 1', 10), ('b2', 'advanced java', 'author 2', 20), 
('b3', 'advanced python', 'author 3', 30), ('b4', 'basics of c', 'author 3', 40), ('b5', 'basic of os', 'author 1', 50) ;

-----------------------------------

create table Members(
m_id varchar(10) not null,
m_name varchar(20) not null,
m_year tinyint not null,
m_fine smallint not null
) ;

alter table Members
add constraint chk_year check(m_year between 1 and 4) ;

alter table Members
add constraint pkey_m_id primary key(m_id) ;

-- alter table Members
-- add m_books_issued tinyint default 0 ;

alter table Members
alter column m_books_issued tinyint ;

insert into Members output inserted.* values ('m1', 'member 1',1 , 0, 0),
('m2', 'member 2',1 , 0, 0) ;

-----------------------------------

create table BooksIssuedToStudent(
b_id varchar(10) not null,
b_name varchar(20) not null,
m_id varchar(10) not null,
m_name varchar(20) not null,
date_issued date not null,
reissued_status varchar(5) not null) ;

-- fkeys, status

alter table BooksIssuedToStudent
add constraint fkey_b_id foreign key (b_id) references Books(b_id)

alter table BooksIssuedToStudent
add constraint fkey_m_id foreign key (m_id) references Members(m_id)

alter table BooksIssuedToStudent
add constraint book_status default 'No' for reissued_status ;

-----------------------------------

create table BookIssueHistory(
b_id varchar(10) not null,
b_name varchar(20) not null,
date_issued date not null,
date_returned date not null,	-- should not be null
m_id varchar(10) not null,
m_name varchar(20) not null,
book_status varchar(10) not null,
comments varchar(50)) ;

alter table BookIssueHistory
alter column date_returned date null ;
-- if in case, the member loses or misplaces book, then the date_returned 
-- column will be empty till the time book is not found and returned back 
-- to the library, so this column should support null values also

alter table BookIssueHistory
alter column date_returned date ;

alter table BookIssueHistory
alter column book_status varchar(20) ;

alter table BookIssueHistory
add constraint fkey_b_id_hist foreign key (b_id) references Books(b_id)

alter table BookIssueHistory
add constraint fkey_m_id_hist foreign key (m_id) references Members(m_id)

-----------------------------------

create table BooksLostByStudent(
report_date date not null,
b_id varchar(10) not null,
b_name varchar(20) not null,
m_id varchar(10) not null,
m_name varchar(20) not null,
book_status varchar(10) not null,
comments varchar(50)
) ;

alter table BooksLostByStudent
add constraint fkey_b_id_lost_stud foreign key (b_id) references Books(b_id)

alter table BooksLostByStudent
add constraint fkey_m_id_lost_stud foreign key (m_id) references Members(m_id)

alter table BooksLostByStudent
alter column book_status varchar(20) not null ;

alter table BooksLostByStudent
add date_issued date ;

alter table BooksLostByStudent
alter column report_date date ;

alter table BooksLostByStudent
alter column book_status varchar(20) ;

alter table BooksLostByStudent
add date_found date null ;
-----------------------------------

create table LibraryFundCollection(
m_id varchar(10) not null,
m_name varchar(20) not null,
reason varchar(20) not null,
other_comments varchar(50)
) ;

alter table LibraryFundCollection
add constraint fkey_m_id_fund foreign key (m_id) references Members(m_id) ;

alter table LibraryFundCollection
add amt_collected float ;

alter table LibraryFundCollection
add amt_returned_after_returning_book float ;

alter table LibraryFundCollection
add b_id varchar(10) ;

exec sp_rename 'LibraryFundCollection.amt_collected', 'fine_amt', 'column' ;

alter table LibraryFundCollection
alter column fine_amt float null ;

alter table LibraryFundCollection
add fine_received varchar(5) ;

--alter table LibraryFundCollection
--add fine_refunded varchar(5) ;

-----------------------------------

select * from Books
select * from Members
select * from BooksIssuedToStudent
select * from BookIssueHistory
select * from BooksLostByStudent
select * from LibraryFundCollection

-----------------------------------------------------------
-- Procedures

-- read, delete books related info
-- proc 1

create or alter procedure RD_Books
--(@inp tinyint , @b_id varchar(10) null, @m_id varchar(10) null, @sub varchar(10) null)
(@inp tinyint, @data varchar(20) null)
as begin
	if @inp = 1
		begin
		if not exists (select 1 from Books where b_id = @data)
			begin
			print 'There is no book with the book id ' +@data+ ' in the library.' ;
			end ;

		else
			begin
			select * from Books where b_id = @data ;
			end ;
		end ;
		-- read book details by b_id

	else if @inp = 2
		begin
		if not exists (select 1 from BooksIssuedToStudent where m_id = @data)
			begin
			print 'Member with member id ' +@data+ ' has not borrowed any book from the library.' ;
			end ;

		else
			begin
			select * from BooksIssuedToStudent where m_id = @data ;
			end ;
		end ;
		-- books currently issued to a member

	else if @inp = 3
		begin
		if not exists (select 1 from BookIssueHistory where m_id = @data)
			begin
			print 'The member with the member id ' +@data+ ' has no records of previously borrowed books, that were returned later back to library.' ;
			end ;

		else
			begin
			select * from BookIssueHistory where m_id = @data ;
			end ;
		end ;
		-- books that were issued to a member previously, that were later returned back to library

	else if @inp = 4
		begin
		if not exists (select 1 from Books where b_name like '%' + @data+ '%')
			begin
			print 'There are no books on this subject.' ;
			print 'Try changing the subject spelling / ensure that the spelling / part of the spelling entered matches the spelling / part of the spelling in the name of the subject or try using the subject synonyms.' ;
			end ;

		else
			begin
			select * from Books where b_name like '%' + @data+ '%' ;
			end ;

		end ;
		-- search books on a particular subject or by title

	else if @inp = 5
		begin
		if not exists (select 1 from Books where b_author like '%' + @data+ '%')
			begin
			print 'There are no books authored by author ' +@data+ ' in the library.' ;
			print 'Try changing the author spelling / ensure that the spelling / part of the spelling entered matches the spelling / part of the spelling in the name of the author.' ;
			end ;

		else
			begin
			select * from Books where b_author like '%' + @data+ '%' ;
			end ;
		end ;
		-- search books by author name
		
	else if @inp = 6
		begin
		if not exists (select 1 from Books where b_quantity_shelf > 0) 
			begin
			print 'There are no books available for issuing.' ;
			end ;

		else
			begin
			select * from Books where b_quantity_shelf > 0 ;
			end ;
		end ;
		-- get the list of books which are present on the shelf / library
		-- and can be issued

	else if @inp = 7
		begin
		-- select count(*) from BooksIssuedToStudent group by m_id ;
		select b1.b_id, b1.b_name, b2.m_id, b2.m_name
		from Books b1
		join BooksIssuedToStudent b2
		on b1.b_id = b2.b_id ;
		end ;  
		-- all the members who have taken / borrowed atleast 1 book from library

	else if @inp = 8
		begin

		if not exists (select 1 from Books where b_id = @data)
			begin
			print 'There is no book with the book id ' +@data+ '.' ;
			end ;

		else
			begin
			delete from Books
			where b_id = @data ;

			print cast(@@rowcount as varchar(5)) + ' rows were deleted.'
			end ;

		/*if @@rowcount = 0
			begin
			print 'There is no book with the book id ' +@data+ '.' ;
			end ;*/
		end ;

	else print 'Invalid option entered' ;
end ;

declare
@inp1 tinyint = 7,
@data1 varchar(20) = '' ;

exec RD_Books @inp1, @data1 ;

------------------------------
-- add books into the library shelf
-- proc 2
-- id, name, author, qty

create or alter procedure Add_Books
(@param1 varchar(10), @param2 varchar(20), @param3 varchar(20), @param4 smallint)
as begin
	
	if exists (select 1 from Books where b_id = @param1)
		begin
		print 'Book with book id ' + @param1 + ' already exists in the Books table.' ;
		end ;

	else
		begin
		insert into Books output inserted.* values(@param1, @param2, @param3, @param4) ;
		print 'Book with book id ' + @param1 + ', bearing name ' +@param2+ ', has been added successfully in the library records.' ;
		end ;
end ;

declare
@b_id2 varchar(10) = 'b7' ,
@b_name2 varchar(20) = 'ruby' ,
@b_author2 varchar(20) = 'author rub' ,
@b_quantity_shelf2 smallint = 0 ;

exec Add_Books @b_id2, @b_name2, @b_author2, @b_quantity_shelf2 ;

-----------------------------
-- update book details (book name, author name, book qty in library)
-- proc 3
-- inp = operation no & b_id

create or alter procedure UPD_Books
(@inp tinyint, @b_id varchar(10), @data varchar(20))
as begin
	if not exists (select 1 from Books where b_id = @b_id)
		begin
		print 'There is no book with this book id ' +@b_id+ '.';
		end ;

	else
		begin

		if @inp = 1
			begin
			update Books
			set b_name = @data output inserted.* where b_id = @b_id ;
			print 'Book name updation successful.' ;
			end ;
			-- update book name

		else if @inp = 2
			begin
			update Books
			set b_author = @data output inserted.* where b_id = @b_id ;
			print 'Book author name updation successful.' ;
			end ;

		else if @inp = 3
			begin
			update Books
			set b_quantity_shelf = cast(@data as smallint) output inserted.* where b_id = @b_id ;
			print 'Book quantity updation successful.' ;
			end ;

		else
			begin
			print 'Invalid option number entered.' ;
			end ;

		end ; --  end of outer else
end ; -- end of procedure

declare 
@inp3 tinyint = 3,
@b_id3 varchar(10) = 'b1' ,
@data3 varchar(20) = '1' ;

exec UPD_Books @inp3, @b_id3, @data3 ;
------------------------------
-- read library members' details
-- proc 4

create or alter procedure Read_Members
(@inp tinyint, @data varchar(10) null)
as begin

	if @inp = 1
		begin
		select * from Members ;
		end ;
		-- all registered members

	else if @inp = 2
		begin
		if not exists (select 1 from Members where m_id = @data)
			begin
			print 'There is no member with this member id ' +@data+ '.' ;
			end ;

		else
			begin
			select * from Members where m_id = @data ;
			end ;
		end ;
		-- details of a particular member

	else if @inp = 3
		begin
		select * from Members where m_year = @data ;
		end ;
		-- details of all members / students of a particular academic year (1 - 4)

	else if @inp = 4
		begin
		select * from Members where m_id in (select m_id from BooksIssuedToStudent) 
		end ;
		-- all members who have taken atleast 1 book

	else if @inp = 5
		begin
		select * from Members where m_id not in (select m_id from BookIssueHistory union select m_id from BooksIssuedToStudent)
		end ;
		-- all members who never took / borrowed any book from library

	else if @inp = 6
		begin
		if not exists (select 1 from Members where m_fine <> 0)
			begin
			print 'There are no library members with pending fines.' ;
			end ;

		else
			begin
			select * from Members where m_fine <> 0 ;
			end ;
		end ;
		-- all members with pending fines

	else if @inp = 7
		begin
			if not exists (select 1 from BooksLostByStudent)
				begin
				print 'There are no records.' ;
				end ;
				
			else 
				begin
				--select * from Members where m_id in (select m_id from BooksLostByStudent)
				select * from BooksLostByStudent ;
				end ;
		end ;
		-- members who have / had lost / misplaced book(s)

		else 
		begin
			print 'Invalid option number entered.' ;
		end ;
end ;

declare
@inp4 tinyint = 4,
@data4 varchar(10) = 'm9' ;

exec Read_Members @inp4, @data4 ;

------------------------------
-- add new member, delete existing library members
-- proc 5
-- id, name, year, fine

create or alter procedure Add_Del_Members
(@inp tinyint, @m_id varchar(10) null, @m_name varchar(20) null, @m_year tinyint null, @m_fine smallint null output, @m_books_issued tinyint null output)
as begin
	if @inp = 1
		begin
		if exists (select 1 from Members where m_id = @m_id)
			begin
			-- search id, initialize fine to 0, insert with out inserted
			print 'A member with this member id ' +@m_id+ ' already exists in the library records.' ;
			select * from Members where m_id = @m_id ;
			print 'So, the member with the above mentioned member id could not be added into the records.' ;
			end ;

		else
			begin
			set @m_fine = 0 ;
			set @m_books_issued = 0
			insert into Members output inserted.* values(@m_id, @m_name, @m_year, @m_fine, @m_books_issued) ;

			if @@rowcount <> 0
				begin
				print 'New record created successfully with the membership id ' +@m_id+ '.' ;
				end ;

			else
				begin
				print 'The record could not be created...' ;
				end ;
			end ;
		end ;

		-- add member

	else if @inp = 2
		begin
		
		if not exists (select 1 from Members where m_id = @m_id)
			begin
			print 'There is no member with the member id ' +@m_id+ ' in the library records.' ;
			end ;
		else
			begin
			delete from Members output deleted.* where m_id = @m_id ;

			if @@rowcount <> 0
				begin
				print 'Library membership corresponding to the member with the member id ' +@m_id+ ' has been removed successfully from the library records.' ;
				end ;

			else
				begin
				print 'The record could not be deleted...' ;
				end ;
			end ;
		end ;
		-- delete member

	else print 'Invalid option number entered.' ;
end ;

declare
@inp5 tinyint = 1,
@m_id5 varchar(10) = 'm4' ,
@m_name5 varchar(20) = 'member 4',
@m_year5 tinyint = 3,
@m_fine5 smallint,
@m_books_issued5 tinyint ;

exec Add_Del_Members @inp5, @m_id5, @m_name5, @m_year5, @m_fine5, @m_books_issued5 ;

-- m_fine, m_books_issued, have been declared as output variables because 
-- whenever a new record is created, m_fine and m_books_issued will be 0,
-- which means that we will not be passing the values explicitly while
-- calling / executing the procedure, instead they will be initialized
-- automatically in the procedure before pushing them into the respective 
-- table. Hence, writing the word 'output' was needed.

------------------------------
-- update member details
-- proc 6
-- name, year, fine

create or alter procedure UPD_Members
(@inp tinyint, @m_id varchar(10), @data varchar(20))
as begin

	if not exists (select 1 from Members where m_id = @m_id)
		begin
		print 'There is no member with this member id ' +@m_id+ ' in the library records.' ;
		end ;

	else
		begin
		if @inp = 1
			begin
			update Members
			set m_name = @data output inserted.* where m_id = @m_id ;

			if @@rowcount <> 0
				begin
				print 'Name updation successful.' ;
				end ;

			else
				begin
				print 'Could not update name...' ;
				end ;
			end ;

		else if @inp = 2
			begin
			update Members
			set m_year = cast(@data as tinyint) output inserted.* where m_id = @m_id ;

			if @@rowcount <> 0
				begin
				print 'Academic year updation successful.' ;
				end ;

			else
				begin
				print 'Could not update the academic year...' ;
				end ;
			end ;

		else if @inp = 3
			begin
			update Members
			set m_fine = cast(@data as smallint) output inserted.* where m_id = @m_id ;

			if @@rowcount <> 0
				begin
				print 'Fine updation successful.' ;
				end ;

			else
				begin
				print 'Could not update fine...' ;
				end ;
			end ;

		else if @inp = 4
			begin
			update Members
			set m_books_issued = cast(@data as tinyint) output inserted.* where m_id = @m_id ;

			if @@rowcount <> 0
				begin
				print 'Books issued updation successful.' ;
				end ;

			else
				begin
				print 'Could not update books issued record...' ;
				end ;
			end ;

		else print 'Invalid option number entered.' ;

		end ; -- end of outer else
end ;
-- name, year, fine, books

declare 
@inp6 tinyint = 4,
@m_id6 varchar(10) = 'm3' ,
@data6 varchar(20) = '0' ;

exec UPD_Members @inp6, @m_id6, @data6 ;

------------------------------
-- proc 7
-- book issue

create or alter procedure Book_Issue
(@dat date, @b_id varchar(10), @m_id varchar(10), 
@b_name varchar(20) output, @m_name varchar(20) output, 
@m_year tinyint output, @m_books_issued tinyint output)
as begin
-- verify b_id, m_id, member details, then proceed

	if not exists (select 1 from Books where b_id = @b_id)
		begin
		print 'There is no book with this book id ' +@b_id+ '.' ;
		-- set @flag_condition = 0 ;
		end ;

	else if(select b_quantity_shelf from Books where b_id = @b_id) = 0
			begin
			print 'There are no copies of this book available for lending / issuing.' ;
			-- set @flag_condition = 0 ;
			end ;

	else if not exists (select 1 from Members where m_id = @m_id)
		begin
		print 'There is no member with this member id ' +@m_id+ '.' ;
		-- set @flag_condition = 0 ;
		end ;

	-- else if (select 1 from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id) = 1
	else if exists (select 1 from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id)
		begin
		print 'The member with member id ' +@m_id+ ' has already been issued the book bearing book id ' +@b_id+ '.' ;
		-- set @flag_condition = 0 ;
		end ;

	else -- if @flag_condition <> 0
		begin
		-- print @flag_condition ;
		set @m_year = (select m_year from Members where m_id = @m_id) ;
		set @m_books_issued = (select m_books_issued from Members where m_id = @m_id) ;

		if (@m_year in (1, 2)) and (@m_books_issued = 3)
			begin
			print '1st & 2nd year students can borrow atmost 3 books at a time.' ;
			-- set @flag_condition = 0 ;
			print @m_year ;
			print @m_books_issued ;
			end ;

		else if (@m_year in (3, 4)) and (@m_books_issued = 5)
			begin
			print '3rd & 4th year students can borrow atmost 5 books at a time.' ;
			-- set @flag_condition = 0 ;
			print @m_year ;
			print @m_books_issued ;
			end ;
			--print @flag_condition ; -- error here
		else -- if @flag_condition != 0
			begin
				-- update Members table, update books table, add record to BooksIssuedTable
				update Books
				set b_quantity_shelf = b_quantity_shelf - 1 where b_id = @b_id ;

				update Members 
				set m_books_issued = m_books_issued + 1 where m_id = @m_id ;

				set @b_name = (select b_name from Books where b_id = @b_id) ;
				set @m_name = (select m_name from Members where m_id = @m_id) ;
				
				insert into BooksIssuedToStudent 
				(b_id, b_name, m_id, m_name, date_issued) output inserted.* 
				values(@b_id, @b_name, @m_id, @m_name, @dat) ;
			end ;
		end ; -- end of outer else
			-- issue book
end ;

declare
@dat7 date = '2024-12-25',
@b_id7 varchar(10) = 'b5',
@m_id7 varchar(10) = 'm2', 
@b_name7 varchar(20),
@m_name7 varchar(20), 
@m_year7 tinyint,
@m_books_issued7 tinyint ;

exec Book_Issue @dat7, @b_id7 , @m_id7, @b_name7 output, @m_name7 output, 
@m_year7 output, @m_books_issued7 output ;


------------------------------
-- proc 8
-- re - issue book

create or alter procedure Book_Reissue
(@b_id varchar(10), @m_id varchar(10), @dat_issued date output, @date_diff_days smallint null output, @delay smallint null output, @fine_pay_option bit null output, @fine_amt smallint null output)
-- @b_name varchar(20) output
as begin
	-- 1st check whether the book specified has been issued to the member or not,
	-- then execute the remaining steps, match date, apply fines - either 
	-- pay now or it will be added in the records, update book
	-- re - issue status in BooksIssuedToStudent table
	
	if not exists (select 1 from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id)
		begin
		print 'No record found...' ;
		print 'Either: ' ;
		print 'The member with member id ' +@m_id+ ' has not been issued the book bearing the book id ' +@b_id+ '.' ;
		print 'Or the book id or the member id or both are incorrect and / or do not exist.' ;
		end ;

	else
		begin
		set @dat_issued = (select date_issued from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id) ;

		set @date_diff_days = datediff(day, @dat_issued, cast(getdate() as date)) ;

		set @delay = abs(15 - @date_diff_days) ;

		if @date_diff_days > 15
			begin
			print 'The delay in re - issuing book is more than 15 days, so a fine will be charged.' ;
			-- calculate fine and update the details to the student table
			-- if the student will pay later

			if @delay <= 10
				begin
				set @fine_amt = 1*@delay ;
				end ;

			else if @delay > 10 and @delay <= 20
				begin
				set @fine_amt = 10 + 2*(@delay - 10) ;
				end ;

			else
				begin
				set @fine_amt = 10 + 20 + 5*(@delay - 20) ;
				end ;
			end ; -- end of if

		else
			begin
			print 'No fine to be charged.' ;
			set @fine_amt = 0 ;
			end ;

			-- use a flag if needed
			-- process fine program - 0 or 1...
			-- re issue program here i.e. update suitably in table

		if @fine_pay_option = 0
			begin
			print 'Fine to be paid: ' +cast(@fine_amt as varchar(5))+ ' Rupees' ;
			end ;

		else if @fine_pay_option = 1
			begin
			print 'Fine of Rupees ' +cast(@fine_amt as varchar(5))+ ' will be added in the library records for the member with the member id ' +@m_id+'.' ;
			
			update Members
			set m_fine = m_fine + @fine_amt where m_id = @m_id ;
			end ;

		update BooksIssuedToStudent
		set date_issued = cast(getdate() as date) where m_id = @m_id and b_id = @b_id ;

		update BooksIssuedToStudent
		set reissued_status = 'Yes' where m_id = @m_id and b_id = @b_id ;

		print 'Book bearing book id ' +@b_id+ ' has been successfully re - issued to the member with member id '+@m_id+ '.' ;

		end ; -- end of outer else (main if else at the beginning of the procedure)

end ; -- end of procedure

-- 0 = pay fine now, 1 = pay later, will be added to records

declare
@b_id8 varchar(10) = 'b5',
@m_id8 varchar(10) = 'm3',
@dat_issued8 date,		-- output variable
@date_diff_days8 smallint,		-- output variable
@delay8 smallint,		-- output variable
@fine_pay_option8 bit = 0,		-- output variable, 0 or 1
@fine_amt8 smallint ;		-- output variable

exec Book_Reissue @b_id8, @m_id8, @dat_issued8 output, @date_diff_days8 output, @delay8 output, @fine_pay_option8 output, @fine_amt8 output ;

------------------------------
-- proc 9
-- return book

create or alter procedure Book_Return
(@b_id varchar(10), @m_id varchar(10), @book_status varchar(20), @comments varchar(50) null, @dat_issued date output, @date_diff_days smallint null output, @delay smallint null output, @fine_pay_option bit null output, @fine_amt smallint null output)

as begin
	-- 1st check whether the book specified has been issued to the member or not,
	-- then execute the remaining steps, match date, apply fines - either 
	-- pay now or it will be added in the records, update book
	-- re - issue status in BooksIssuedToStudent table

	if not exists (select 1 from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id)
		begin
		print 'No record found...' ;
		print 'Either: ' ;
		print 'The member with member id ' +@m_id+ ' has not been issued the book bearing the book id ' +@b_id+ '.' ;
		print 'Or the book id or the member id or both are incorrect and / or do not exist.' ;
		end ;

	else
		begin
		set @dat_issued = (select date_issued from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id) ;

		set @date_diff_days = datediff(day, @dat_issued, cast(getdate() as date)) ;

		set @delay = abs(15 - @date_diff_days) ;

		if @date_diff_days > 15
			begin
			print 'The delay in returning book is more than 15 days, so a fine will be charged.' ;
			-- calculate fine and update the details to the student table
			-- if the student will pay later

			if @delay <= 10
				begin
				set @fine_amt = 1*@delay ;
				end ;

			else if @delay > 10 and @delay <= 20
				begin
				set @fine_amt = 10 + 2*(@delay - 10) ;
				end ;

			else
				begin
				set @fine_amt = 10 + 20 + 5*(@delay - 20) ;
				end ;
			end ; -- end of if

		else
			begin
			print 'No fine to be charged.' ;
			set @fine_amt = 0 ;
			end ;

			-- use a flag if needed

		if @fine_pay_option = 0
			begin
			print 'Fine to be paid: ' +cast(@fine_amt as varchar(5))+ ' Rupees.' ;
			end ;

		else if @fine_pay_option = 1
			begin
			print 'Fine of Rupees ' +cast(@fine_amt as varchar(5))+ ' will be added in the library records for the member with the member id ' +@m_id+'.' ;
			
			update Members
			set m_fine = m_fine + @fine_amt where m_id = @m_id ;
			end ;
			-- change from here
			-- shift record from BooksIssuedToStudent to BookIssueHistory table, update Members table - dec book count of member,
			-- inc countof book by 1 in main shelf

			insert into BookIssueHistory (b_id, b_name, date_issued, m_id, m_name)
			output inserted.*
			select b_id, b_name, date_issued, m_id, m_name from BooksIssuedToStudent 
			where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set date_returned = cast(getdate() as date) where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set book_status = @book_status where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set comments = @comments where b_id = @b_id and m_id = @m_id ;

			delete from BooksIssuedToStudent
			where b_id = @b_id and m_id = @m_id ;

			update Books
			set b_quantity_shelf = b_quantity_shelf + 1 where b_id = @b_id ;

			update Members
			set m_books_issued = m_books_issued - 1 where m_id = @m_id ;

		end ; -- end of else 

end ; -- end of procedure

declare
@b_id9 varchar(10) = 'b5',
@m_id9 varchar(10) = 'm3',
@book_status9 varchar(20) = 'returned',		-- returned or lost
@comments9 varchar(50),
@dat_issued9 date,		-- output variable
@date_diff_days9 smallint,		-- output variable
@delay9 smallint,		-- output variable
@fine_pay_option9 bit = 0,		-- output variable, 0 or 1
@fine_amt9 smallint ;		-- output variable

exec Book_Return @b_id9, @m_id9, @book_status9, @comments9, @dat_issued9 output, @date_diff_days9 output, @delay9 output, @fine_pay_option9 output, @fine_amt9 output ;

------------------------------
-- proc 10
-- book lost & found

create or alter procedure Book_Lost_Found
(@inp tinyint, @b_id varchar(10), @m_id varchar(10), @reason varchar(20) null, @comments varchar(50) null, @amt_collected float null, @fine_paid_status varchar(5), @amt_returned float null output, @dat_reported date output)
as begin
	if @inp = 1
		begin

		if not exists (select 1 from BooksIssuedToStudent where b_id = @b_id and m_id = @m_id)
			begin
			print 'This book with book id ' +@b_id+ ' was not issued to the member with member id ' +@m_id+ '.' ;
			print 'Possibly, b_id and / or m_id entered may be incorrect.' ;
			end ;

		else
			begin
			begin transaction

		insert into BookIssueHistory (b_id, b_name, date_issued, m_id, m_name)
			output inserted.*
			select b_id, b_name, date_issued, m_id, m_name from BooksIssuedToStudent 
			where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set date_returned = null ;

			update BookIssueHistory
			set book_status = 'lost / misplaced' where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set comments = @comments where b_id = @b_id and m_id = @m_id ;

			-- set @dat_reported = 

			insert into BooksLostByStudent (b_id, b_name, m_id, m_name, date_issued)
			output inserted.*
			select b_id, b_name, m_id, m_name, date_issued from BooksIssuedToStudent 
			where b_id = @b_id and m_id = @m_id ; 
			
			update BooksLostByStudent
			set report_date = cast(getdate() as date) where b_id = @b_id and m_id = @m_id ;

			update BooksLostByStudent
			set comments = @comments where b_id = @b_id and m_id = @m_id ;

			update BooksLostByStudent
			set book_status = 'lost / misplaced' where b_id = @b_id and m_id = @m_id ;

			delete from BooksIssuedToStudent
			where b_id = @b_id and m_id = @m_id ;

			update Members
			set m_books_issued = m_books_issued - 1 where m_id = @m_id ;

			if @amt_collected != null
				begin
				--update LibraryFundCollection
				--set fine_received = 'yes' where b_id = @b_id and m_id = @m_id ;
				set @fine_paid_status = 'yes' ;
				end ;

			else
				begin
				--update LibraryFundCollection
				--set fine_received = null where b_id = @b_id and m_id = @m_id ;
				set @fine_paid_status = 'no' ;
				end ;

			set @amt_returned = null ;
			insert into LibraryFundCollection 
			output inserted.*
			values (@m_id, (select m_name from Members where m_id = @m_id), @reason, @comments, @amt_collected, @amt_returned, @b_id, @fine_paid_status) ;
			

			commit ;
			end ;

		end ;
		-- book lost

	else if @inp = 2
		begin
		if not exists (select 1 from BooksLostByStudent where b_id = @b_id and m_id = @m_id and book_status like '%' + 'lost' + '%')
			begin
			print 'There are no records that this book was lost.' ;
			print 'Possibly, the b_id and / or the m_id are incorrect.' ;
			end ;
		-- inc count in books
		-- update date_returned, book_status, comments in BookIssueHistory
		-- update book_status in lostbooks, 
		-- update amt_returned in LibraryFundCollection
		else
			begin
			begin transaction

			update Books
			set b_quantity_shelf = b_quantity_shelf + 1 where b_id = @b_id ;

			update BookIssueHistory
			set date_returned = cast(getdate() as date) where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set book_status = 'found & returned' where b_id = @b_id and m_id = @m_id ;

			update BookIssueHistory
			set comments = @comments where b_id = @b_id and m_id = @m_id ;

			update BooksLostByStudent
			set date_found = cast(getdate() as date) where b_id = @b_id and m_id = @m_id ;

			update BooksLostByStudent
			set book_status = 'found & returned' where b_id = @b_id and m_id = @m_id ;

			update BooksLostByStudent
			set comments = @comments where b_id = @b_id and m_id = @m_id ;

			update LibraryFundCollection
			set reason = 'lost book returned' where b_id = @b_id and m_id = @m_id ;

			update LibraryFundCollection
			set other_comments = @comments where b_id = @b_id and m_id = @m_id ;

			if (select fine_received from LibraryFundCollection where b_id = @b_id and m_id = @m_id) = 'yes'
				begin
				update LibraryFundCollection
				set amt_returned_after_returning_book = 0.9*(select fine_amt from LibraryFundCollection where b_id = @b_id and m_id = @m_id) where b_id = @b_id and m_id = @m_id ;
				end ;

			else
				begin
				print 'Refund cannot be initiated because the member with member id ' +@m_id+ ' has not yet paid his / her fine.' ;
				end ;
			commit ;
			end ;
			-- book found & has to be returned back
		end ;

	else if @inp = 3
	-- pay fine for losing book if it was not paid previously while reporting the incident
		begin

		if not exists (select 1 from LibraryFundCollection where b_id = @b_id and m_id = @m_id)
		-- and (fine_received like 'no' or fine_amt = null)
			begin
			print 'Either there are no records that this book was lost or the fine has been paid by the member.' ;
			print 'Possibly, the b_id and / or the m_id are incorrect.' ;
			end ;

		else if (select fine_received from LibraryFundCollection where b_id = @b_id and m_id = @m_id) != null
			begin
			print 'The member with member id ' +@m_id+ ' has already paid his/ her fine.' ; 
			end ;

		else
			begin
			begin transaction
			update LibraryFundCollection
			set fine_received = 'yes' where b_id = @b_id and m_id = @m_id ;

			update LibraryFundCollection
			set fine_amt = @amt_collected where b_id = @b_id and m_id = @m_id ;

			if (select book_status from BooksLostByStudent where b_id = @b_id and m_id = @m_id) like 'found & returned'
				begin
				update LibraryFundCollection
				set amt_returned_after_returning_book = 0.9*(select fine_amt from LibraryFundCollection where b_id = @b_id and m_id = @m_id) where b_id = @b_id and m_id = @m_id ; 
				end ;

			else
				begin
				print 'Refund cannot be initiated because the book has not been returned back to library.' ;
				end ;
			-- if the book has been found & returned, amount should be deducted 
			-- and returned automatically, and all records should be updated suitably
			commit ;
			end ;
		end ;
	
	else print 'Invalid option number entered.' ;

end ;

declare
@inp10 tinyint = 2,
@b_id10 varchar(10) = 'b5',
@m_id10 varchar(10) = 'm2',
@reason10 varchar(20) = 'found & returned',
@comments10  varchar(50),
@amt_collected10 float = 100, -- null if fine has to be paid later by the member
@fine_paid_status10 varchar(5) = 'yes', -- yes / no
@amt_returned10 float,
@dat_returned10 date ;

exec Book_Lost_Found @inp10, @b_id10, @m_id10, @reason10, @comments10, @amt_collected10, @fine_paid_status10, @amt_returned10 output, @dat_returned10 output;

-- book lost ? insert record from bookissue to lost table, and also to
-- to the book issue history with book_status as lost 
-- dec m_books_issued count in Members table,
-- do not disturb book count on shelf in Books table, fine library member &
-- insert fine details in the LibraryFundCollection table

-- books found ? update record to the lost table, inc book count on shelf 
-- by 1 in books table, return 90% of the lost book fine back to the member
-- update details in the LibraryFundCollection table
-- update bookissuehistory table, set book_status as found and returned,
-- update date_returned col with date when the book was returned to the 
-- library where b_id = @b_id & m_id = @m_id

-----------------------------------------------------------


/*
Caution: 

1. In procedures, if select statements have to be used, use if - else instead of 
case - when - then because select cannot be used with case - when - then directly.

2. use = instead of == while comparing values, as in if else statement.
*/


/*
Future scope / improvements in this program:

1. Mail and / or message students / member 2 days before book issue period is about to expire

2. Implement try catch blocks if needed

3. Include commit rollback as and where needed
*/
