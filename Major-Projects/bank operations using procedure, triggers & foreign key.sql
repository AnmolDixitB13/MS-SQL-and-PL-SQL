
-- Write a program in SQL to perform banking operations - debit/credit an account update an account,
-- delete an account and read/fetch details such as balance of an account. All these operations as 
-- mentioned should be written as a procedure. Use option no. to select which action has to be 
-- performed among the options/tasks listed above, eg 1 will be for debitting an account, 2 will be 
-- crediting money into an account... and so on. If the user enters wrong option no, it should display
-- invalid option no. The tasks/options mentioned above, I have implemented all of them in 1 procedure
-- itself. Anyways, one can use more than 1 procedure i.e. 1 procedure for 1 task method also for 
-- implementing it.
--
-- Include triggers which will be triggered when 
-- 1. an account is created
-- 2. an account is debited
-- 3. an account is credited
-- 4. an account is updated
-- 5. an account is deleted
--
--
-- Include 2 tables in this code: 
-- 1. AccountsRecord which stores the account details such as acc. holder's name, opening balance,
-- credit, debit amounts, final balance along with account no, which is the primary key.
-- 2. TransactionList - every time a transaction like debiting or crediting of an account, updation
-- and/or deletion of an account occurs, it will be stored in this table, via suitable triggers. Acc. 
-- no. of the previous table will act as foreign key in this table.
-- 
-- Whenever bank procedure is called to perform operation like debit/credit/update/read/delete an 
-- account, 1st verify whether the option no. entered is valid or not, then find whether the account
-- no. provided is in AccountsRecord or not i.e. account exist or not. If the account exists, then
-- verify that the name provided matches the name present in the AccountsRecord table at that account
-- no. If yes, then proceed to execute the task via the procedure.
-- 

use mydb

-- drop table  TransactionList, 

create table AccountsRecord(dattim datetime,	-- ' yyyy-mm-dd' -- ' hh : mm : ss '
Acc_no smallint not null,
name varchar(20),
openingBalance float,
debit float default 0,
credit float default 0,
finalBalance float) ;


alter table AccountsRecord
add constraint p_key primary key(Acc_no) ;

create table TransactionList(
Acc_no smallint not null,
details text,
dattim datetime) ;

alter table TransactionList
add constraint f_key foreign key(Acc_no) references AccountsRecord(Acc_no) ;

-- insert, update, delete trig for AccountsRecord
-- transaction trigger (before/instead of) for Transaction record
-- procedure to update total_balance in AccountsRecord

create or alter trigger insertAccountsRecord
on AccountsRecord for insert
as begin

declare @id smallint
select @id = inserted.Acc_no from inserted

print 'Account ' + cast(@id as varchar(8)) + ' has been successfully created in the bank at ' + 
cast(getdate() as varchar(30)) + '.' ;

--insert into AccountsRecord(dattim)  values(getdate()) ;
update AccountsRecord
set dattim = getdate() where @id = Acc_no ;

update AccountsRecord
--set finalBalance = (select openingBalance from AccountsRecord where @id = Acc_no) 
set finalBalance = openingBalance
where @id = Acc_no;

select * from AccountsRecord ;

end

insert into AccountsRecord(Acc_no, name, openingBalance)  values(6666, 'iii', 9000) ;
-- creating a new record


--update AccountsRecord
--set name = 'ghi' where Acc_no = 3333 ;

create or alter trigger updateAccountsRecord
on AccountsRecord for update
as begin

declare @id smallint
select @id = inserted.Acc_no from inserted

print 'Account ' + cast(@id as varchar(8)) + ' has been successfully updated in the bank at ' + 
cast(getdate() as varchar(30)) + '.'

insert into TransactionList(Acc_no, details, dattim) values(@id, ('Account ' +
cast(@id as varchar(8)) + ' has been successfully updated in the bank at ' + 
cast(getdate() as varchar(30)) + '.'), getdate()) ;

select * from AccountsRecord ;

end

select * from TransactionList ;

create or alter trigger deleteAccountsRecord
on AccountsRecord for delete
as begin

declare @id smallint
select @id = deleted.Acc_no from deleted

print 'Account ' + cast(@id as varchar(8)) + ' has been successfully deleted in the bank at ' + 
cast(getdate() as varchar(30)) + '.'

insert into TransactionList(Acc_no, details, dattim) values(@id, ('Account ' +
cast(@id as varchar(8)) + ' has been successfully deleted in the bank at ' + 
cast(getdate() as varchar(30)) + '.'), getdate()) ;

select * from AccountsRecord ;

end

/*
create or alter trigger updateDebitActivity
on AccountsRecord for update
as begin

declare @Acc_no smallint, @debit float, @details varchar(60)
select @Acc_no from inserted
select @debit from inserted where @Acc_no = inserted.Acc_no ;

select @details = 'Amount ' + cast(@debit as varchar(8)) + ' has been successfully debited from 
the account ' + cast(@Acc_no as varchar(8)) + '.' ;

insert into TransactionList(Acc_no, details, dattim) 
values(@Acc_no, @details, getdate()) ;
-- acc_no, details, dattim

end


create or alter trigger updateCreditActivity
on AccountsRecord for update
as begin

declare @Acc_no smallint, @details varchar(60), @credit float
select @Acc_no from inserted
select @credit from inserted where @Acc_no = inserted.Acc_no ;

select @details = 'Amount ' + cast(@credit as varchar(8)) + ' has been successfully credited to 
the account ' + cast(@Acc_no as varchar(8)) + '.' ;

insert into TransactionList(Acc_no, details, dattim) 
values(@Acc_no, @details, getdate()) ;
-- acc_no, details, dattim
end
*/

drop trigger updateDebitActivity, updateCreditActivity

-- acc_no, name, openingBalance, debit, credit, finalBalance  -- acc_no, details, dattime

select * from AccountsRecord

create or alter procedure bank_operations
(@option_no tinyint, @id smallint, @name varchar(20), @data varchar(30))
as begin
/*
1st verify name & acc no, then proceed to options
option		task
1			debit
2			credit
3			update details
4			delete
5			fetch account details
*/
if @option_no not between 1 and 5
begin
	print 'Incorrect option no. entered.' ;
end

else
begin
	if @id not in (select Acc_no from AccountsRecord)
	begin
		print 'There is no account with this account number ' + cast(@id as varchar(8)) ;
	end

	else if @name = (select name from AccountsRecord where Acc_no = @id)
	begin
		print 'The bank account holder with name ' + cast(@name as varchar(20)) + ' and account no. '
		+ cast(@id as varchar(8)) + ' is an account holder... Identity Verified.';
		print 'The account holder can proceed to do the transaction(s)/operation(s).'

		-- xxx, debit, credit, update, delete, fetch
		-- @option_no tinyint, @id smallint, @name varchar(20), @data varchar(20)
		-- code here
		if @option_no = 1
			begin
			if @data <= 0
				begin
					print 'The amount to be debited should be more than 0.' ;
					print 'Debit transaction failed.'
				end
			
			else
				begin
				update AccountsRecord
				-- set debit = debit + cast(@data as float) where Acc_no = @id ;
				set debit = debit + @data where Acc_no = @id ;
				print @data

				update AccountsRecord
				-- set finalBalance = (openingBalance + credit - debit) where Acc_no = @id ; 
				set finalBalance = finalBalance - @data where Acc_no = @id ; 
				
				print 'Debit Transaction successful.' ;
				print 'Account no. ' + cast(@id as varchar(8)) + ' was debited by amount ' + 
				cast(@data as varchar(8)) + ' on ' + cast(getdate() as varchar(30)) ;
				end -- end of else
			end -- end of if for option 1
		-------------------------------------------------
		if @option_no = 2
			begin
			if @data <= 0
				begin
				print 'The amount to be credited should be more than 0.' ;
				print 'Credit transaction failed.'
				end
			
			else
				begin
				update AccountsRecord
				-- set credit = credit + cast(@data as float) where Acc_no = @id ;
				set credit = credit + @data where Acc_no = @id ;

				update AccountsRecord
				set finalBalance = finalBalance + @data where Acc_no = @id ; 

				print 'Credit Transaction successful.' ;
				print 'Account no. ' + cast(@id as varchar(8)) + ' was credited to by the amount ' + 
				cast(@data as varchar(8)) + ' on ' + cast(getdate() as varchar(30)) ;
				end
			end
		-------------------------------------------
		if @option_no = 3
			begin
				update AccountsRecord
				set name = @data where Acc_no = @id ; 

				print 'Account Updation successful.' ;
				print 'Account no. ' + cast(@id as varchar(8)) + ' was updated successfully on ' + 
					+ cast(getdate() as varchar(30)) ;
			end
		-------------------------------------------

		if @option_no = 4
			begin
				alter table TransactionList
				nocheck constraint f_key ;
				
				delete from AccountsRecord
				where Acc_no = @id ;

				alter table TransactionList
				check constraint f_key ;

				print 'Account Deletion successful.'
				print 'Account no. ' + cast(@id as varchar(8)) + ' was successfully deleted from the 
				system on ' + cast(getdate() as varchar(30)) ;
			end

		-------------------------------------------

		if @option_no = 5
			begin
				select * from AccountsRecord where Acc_no = @id ;
				select * from TransactionList where Acc_no = @id ;
			end
	end

	else
	begin
		print 'There is some name mismatch... The entered name ' + cast(@name as varchar(20)) +
		' does not match the name which is linked to the account no ' + cast(@id as varchar(8)) + '.' ;
	end
end -- end of 1st else of procedure
end ; -- end of procedure

declare @option tinyint = 5,
@Acc_no smallint = 6666,
@nam varchar(20) = '200',   
@datum varchar(20) = '200' ;
exec bank_operations @option , @Acc_no, @nam, @datum ;

select * from AccountsRecord ;
select * from TransactionList ;

-- Future Scope / Improvements:
-- 
-- 1. Suitable try - catch constructs can be implemented at all the necessary places. This will ensure
-- that the program becomes more robust in terms of error / exception handling.
-- 
-- 2. More functionalities can be added such as:
-- i. automatically crediting interest after a suitable period, say quaterly/half yearly...
-- ii. provision for account holders to invest money in other deposits, such as term deposits, 
-- recurrent deposits, other deposits / investment schemes.
-- iii. money can't be debitted if the balance is below the threshold
-- iv. sending mail to the registered mail id after every transaction & phone text message for the same
-- v. sending monthly account statement to the account holder on his / her registered mail id
-- 
-- 3. Data validation at the time of account creation i.e. name, phone number, email id, etc are 
-- appropriate or not
