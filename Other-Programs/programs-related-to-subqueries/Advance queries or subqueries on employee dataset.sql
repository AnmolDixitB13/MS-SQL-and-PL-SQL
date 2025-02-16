use mydb

create table emp(
emp_id smallint,
name varchar(20),
sal int,
dept tinyint,
job varchar(20) 
) ;

insert into emp output inserted.* values (1, 'aaa', 1000, 10, 'engineer'),
(12, 'bbb', 2000, 20, 'technician'),
(13, 'ccc', 3000, 20, 'manager'),
(14, 'ddd', 4000, 20, 'sr. manager'),
(15, 'eee', 100, 20, 'engineer'),
(61, 'fgf', 200000, 10, 'engineer'),
(7, 'ggg', 300, 20, 'manager'),
(8, 'hhh', 400, 20, 'sr. manager'),
(9, 'iii', 10000, 30, 'engineer'),
(10, 'jjj', 20000, 30, 'technician'),
(11, 'kkk', 30000, 30, 'manager'),
(12, 'lll', 40000, 30, 'sr. manager')

insert into emp output inserted.* values(66, 'emp', 200000, 30, 'manager') ;

-- all details of the highest paid emp of the company
select * from emp where sal = (select max(sal) from emp) ;


-- highest paid emp of dept 10
select * from emp where dept = 10 and sal = (select max(sal) from emp where dept = 10) ;



-- highest paid engineer in dept 10
select * from emp where dept = 10 and job = 'engineer' and sal = (select max(sal) from emp where dept = 10) ;



-- engineer of dept 10 who has sal > sal of all engg of dept 20
select * from emp where dept = 10 and job = 'engineer' and sal > all(select sal from emp where dept = 20 and job = 'engineer') ;

-- engineer of dept 10 who has sal > sal of all engg of the company
select * from emp where dept = 10 and job = 'engineer' and sal in (select sal from emp where job = 'engineer') ;


-- all details of the highest paid employees of their respective depts
select e.*
from emp e 
join  (select max(sal) as sall, dept from emp group by dept) as temp
on e.dept = temp.dept
and e.sal = temp.sall ;

select * from emp


-- budget that goes to dept 30
select sum(sal) as bud_30 from emp where dept = 30 ;


-- dept wise budget
select sum(sal) as budget, dept from emp 
group by dept
order by sum(sal) desc ;


-- find out the budget that goes to each job of each department in the company
select dept, job, sum(sal) as sal from emp
group by job, dept ;


select dept, job, sal from emp
group by dept, job ;
-- error
-- Column 'emp.sal' is invalid in the select list because it is not contained in either an aggregate 
-- function or the GROUP BY clause.


-- budget that goes to engineers and non engineers in each dept
select sum(sal) as deptwise_engg_budget, dept from emp
where job like 'engineer'
group by dept ;

select sum(sal) as deptwise_non_engg_budget, dept from emp
where job not like 'engineer'
group by dept ;


-- details of highest paid engineer and non engineer from each dept
select * from emp where job like 'engineer' and sal = (select max(sal) from emp where job like 'engineer') ;

select * from emp where job not like 'engineer' and sal = (select max(sal) from emp where job not like 'engineer') ;

select * from emp ;


-- extras
select dept, job, sal from emp
group by dept, job, sal with cube ;

select dept, job, sal from emp
group by dept, job, sal with rollup ;