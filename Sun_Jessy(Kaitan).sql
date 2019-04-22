/* Assignment 3 Sun Jessy(Kaitan) 
October 11th,2018 */

-- Query 1
select count(*)
from employee;

-- Query 2
select FIRST_NAME, LAST_NAME,TITLE,START_DATE
from employee;

-- Query 3 
select FIRST_NAME,LAST_NAME
from employee
where TITLE = "teller"
order by START_DATE;

-- Query 4
select count(*)
from employee e, branch b
where e.ASSIGNED_BRANCH_ID = b.BRANCH_ID and
	b.NAME="Headquarters";
	
-- Query 5 
select  FIRST_NAME,LAST_NAME,TITLE
from employee e, branch b
where e.ASSIGNED_BRANCH_ID = b.BRANCH_ID and
	b.NAME="Headquarters";

-- Query 6 
select  count(*)
from employee e, branch b
where e.ASSIGNED_BRANCH_ID = b.BRANCH_ID
group by b.name;	

-- Query 7 
select distinct PRODUCT_TYPE_CD
from product;

-- Query 8
select  NAME
from product
where name like "%account%";

-- Query 9 
select  FIRST_NAME,LAST_NAME,BIRTH_DATE
from individual
order by BIRTH_DATE asc;	

-- Query 10
select  avg(AVAIL_BALANCE), min(AVAIL_BALANCE),max(AVAIL_BALANCE)
from account;

-- Query 11 
-- Since I don't know what kind of type of account do you want me to do, I just simply use status to it.
select  status, avg(AVAIL_BALANCE), min(AVAIL_BALANCE),max(AVAIL_BALANCE)
from account
group by status;

-- Query 12 
select  a.CUST_ID,count(*)
from account a, customer c
where a.CUST_ID = c.CUST_ID and
	a.AVAIL_BALANCE>1000
group by a.cust_id;

-- Query 13
select  a.CUST_ID,count(*),avg(a.AVAIL_BALANCE)
from account a, customer c
where a.CUST_ID = c.CUST_ID and
	a.AVAIL_BALANCE>1000
group by a.cust_id;

-- Query 14
select  a.CUST_ID,count(*),avg(a.AVAIL_BALANCE)
from account a, customer c
where a.CUST_ID = c.CUST_ID 
group by a.cust_id
having avg(a.AVAIL_BALANCE)>1000;

-- Query 15
select  PRODUCT_CD, OPEN_BRANCH_ID, max(PENDING_BALANCE)
from account
group by OPEN_BRANCH_ID,PRODUCT_CD
having max(PENDING_BALANCE)>2000;

-- Query 16  
select  b.NAME branch_name,p.name product_name, max(a.PENDING_BALANCE)
from account a, product p,branch b
where a.PRODUCT_CD = p.PRODUCT_CD and
		b.BRANCH_ID=a.OPEN_BRANCH_ID
group by b.NAME,p.name
having max(a.PENDING_BALANCE)>2000;

-- Query 17
select  ACCOUNT_ID,CUST_ID,PRODUCT_CD,OPEN_BRANCH_ID
from account
where AVAIL_BALANCE < (select avg(AVAIL_BALANCE)
						from account);
                        
-- Query 18 
select a.ACCOUNT_ID,i.LAST_NAME,i.FIRST_NAME,p.name product_name,b.NAME branch_name
from product p, account a, individual i, branch b
where p. PRODUCT_CD=a.PRODUCT_CD and
	i.CUST_ID=a.CUST_ID and
	b.BRANCH_ID=a.OPEN_BRANCH_ID and
    a.AVAIL_BALANCE < (select avg(AVAIL_BALANCE)
						from account)
order by i.LAST_NAME;
                        
-- Query 19
select i.LAST_NAME,i.FIRST_NAME
from account a, individual i
where i.CUST_ID=a.CUST_ID
group by i.CUST_ID
having count(*)>2;

-- Query 20 
select e.LAST_NAME,e.FIRST_NAME,year(curdate())-year(e.START_DATE) years_with_company,  s.LAST_NAME supervisor
from employee s, employee e
where e.SUPERIOR_EMP_ID =s.EMP_ID
order by s.LAST_NAME;

-- Query 21
select s.LAST_NAME Supervisor_Last_Name,count(*) Number_of_employees
from employee s, employee e
where e.SUPERIOR_EMP_ID =s.EMP_ID
group by s.EMP_ID;

-- Query 22 
select *
from account
where CLOSE_DATE is null;

-- Query 23
select *
from account
where ACCOUNT_ID not in 
	(select a.ACCOUNT_ID
	from acc_transaction aa, account a
     where aa.ACCOUNT_ID =a.ACCOUNT_ID);

-- Query 24
create view ACTIVE_ACCOUNTS as
select *
from account
where ACCOUNT_ID  in 
	(select a.ACCOUNT_ID
	from acc_transaction aa, account a
     where aa.ACCOUNT_ID =a.ACCOUNT_ID);

-- Query 25 
-- there is also a account status, but in this case, I just use the view created by query 24 (since I don't know your definition of "active account")
select product_cd, avg(AVAIL_BALANCE), min(AVAIL_BALANCE),max(AVAIL_BALANCE)
from ACTIVE_ACCOUNTS
group by product_cd;
