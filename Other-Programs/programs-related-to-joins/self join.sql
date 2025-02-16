use mydb

create table emp(
emp_id smallint primary key,
emp_name varchar(20),
mgr_id smallint,
mgr_name varchar(20),
) ;

insert into emp values(1, 'abc', 9, 'm_abc'), (2, 'def', 109, 'm_def'), (3, 'ghi', 5, 'm_ghi'), 
(4, 'jkl', 105, 'm_jkl'), (5, 'mno', 7, 'm_mno'), (6, 'pqr', 107, 'm_pqr'), 
(7, 'stu', 10, 'm_stu'), (8, 'vwx', 100, 'm_vwx'), (9, 'yza', 1000, 'm_yza'), 
(10, 'bcd', 2000, 'm_bcd') ;

select * from emp ;

-- self join

select e1.emp_id, e1.emp_name, e1.mgr_id, e1.mgr_name
from emp e1 join emp e2
--on e1.mgr_id = e2.mgr_id ;
-- on e1.emp_id = e2.mgr_id ;
on e1.mgr_id = e2.emp_id ;

-- aliases are needed while doing self join
-- no need to use keyword self, using keyword self throws error