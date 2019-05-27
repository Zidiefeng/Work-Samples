/* Kaitan Sun SQL query samples
October 11th,2018 */

-- Query 1
-- How many employees work for the bank?
select count(*)
from employee;

-- Query 2
-- List they First Name, Last name, Title, and Start Date for all employees.
select FIRST_NAME, LAST_NAME,TITLE,START_DATE
from employee;

-- Query 3 
-- Create a list of all employees that are tellers order by start date – list first name, last name.
select FIRST_NAME,LAST_NAME
from employee
where TITLE = "teller"
order by START_DATE;

-- Query 4
-- Write a query that counts how many employees work at headquarters.
select count(*)
from employee e, branch b
where e.ASSIGNED_BRANCH_ID = b.BRANCH_ID and
	b.NAME="Headquarters";
	
-- Query 5 
-- Create a list of all employees that work at Headquarters. List first name, last name, title.
select  FIRST_NAME,LAST_NAME,TITLE
from employee e, branch b
where e.ASSIGNED_BRANCH_ID = b.BRANCH_ID and
	b.NAME="Headquarters";

-- Query 6 
-- List branch name and number of total number of employees for each branch.
select  count(*)
from employee e, branch b
where e.ASSIGNED_BRANCH_ID = b.BRANCH_ID
group by b.name;	

-- Query 7 
-- Retrieve one instance of all the different product type codes from the product table.
select distinct PRODUCT_TYPE_CD
from product;

-- Query 8
-- List the product name for all the products that contain the word “account”.
select  NAME
from product
where name like "%account%";

-- Query 9 
-- List the first name, last name and birthdate of all individual customers. Order by birthdate ascending.
select  FIRST_NAME,LAST_NAME,BIRTH_DATE
from individual
order by BIRTH_DATE asc;	

-- Query 10
-- Retrieve the average, min and max available balance for all accounts.
select  avg(AVAIL_BALANCE), min(AVAIL_BALANCE),max(AVAIL_BALANCE)
from account;

-- Query 11 
-- Retrieve the account type, average, min and max available balance for each type of account.
select  status, avg(AVAIL_BALANCE), min(AVAIL_BALANCE),max(AVAIL_BALANCE)
from account
group by status;

-- Query 12 
-- List Customer ID, total number of accounts where the balance is greater than $1000.
select  a.CUST_ID,count(*)
from account a, customer c
where a.CUST_ID = c.CUST_ID and
	a.AVAIL_BALANCE>1000
group by a.cust_id;

-- Query 13
-- List Customer ID, total number of accounts, average balance where the balance is greater than $1000.
select  a.CUST_ID,count(*),avg(a.AVAIL_BALANCE)
from account a, customer c
where a.CUST_ID = c.CUST_ID and
	a.AVAIL_BALANCE>1000
group by a.cust_id;

-- Query 14
-- List Customer ID, total number of accounts, average balance for each customer where the average balance for a customer is greater than $1000.
select  a.CUST_ID,count(*),avg(a.AVAIL_BALANCE)
from account a, customer c
where a.CUST_ID = c.CUST_ID 
group by a.cust_id
having avg(a.AVAIL_BALANCE)>1000;

-- Query 15
-- List the maximum pending balance by Open Branch ID, Product Code where the max pending balance is greater than 2000
select  PRODUCT_CD, OPEN_BRANCH_ID, max(PENDING_BALANCE)
from account
group by OPEN_BRANCH_ID,PRODUCT_CD
having max(PENDING_BALANCE)>2000;

-- Query 16  
-- List the maximum pending balance by Open Branch Name, Product Name where the max pending balance is greater than 2000.
select  b.NAME branch_name,p.name product_name, max(a.PENDING_BALANCE)
from account a, product p,branch b
where a.PRODUCT_CD = p.PRODUCT_CD and
		b.BRANCH_ID=a.OPEN_BRANCH_ID
group by b.NAME,p.name
having max(a.PENDING_BALANCE)>2000;

-- Query 17
-- For each account whose available balance is below the average of all available balances, retrieve the account ID, customer ID, product code and opening branch id
select  ACCOUNT_ID,CUST_ID,PRODUCT_CD,OPEN_BRANCH_ID
from account
where AVAIL_BALANCE < (select avg(AVAIL_BALANCE)
						from account);
                        
-- Query 18 
-- For each account whose available balance is below the average of all available balances,
-- retrieve the account ID, customer Last Name, customer first name, product name and
-- opening branch name (use individual customer table). Order by customer Last Name.
select a.ACCOUNT_ID,i.LAST_NAME,i.FIRST_NAME,p.name product_name,b.NAME branch_name
from product p, account a, individual i, branch b
where p. PRODUCT_CD=a.PRODUCT_CD and
	i.CUST_ID=a.CUST_ID and
	b.BRANCH_ID=a.OPEN_BRANCH_ID and
    a.AVAIL_BALANCE < (select avg(AVAIL_BALANCE)
						from account)
order by i.LAST_NAME;
                        
-- Query 19
-- For each individual customer that has more than two accounts, retrieve the customer last name, first name.
select i.LAST_NAME,i.FIRST_NAME
from account a, individual i
where i.CUST_ID=a.CUST_ID
group by i.CUST_ID
having count(*)>2;

-- Query 20 
-- For each employee, list their last name, first name, number of years with company (using
-- today’s date and a column heading of ‘years with company’) and their supervisor’s last
-- name. Order by supervisor last name.
select e.LAST_NAME,e.FIRST_NAME,year(curdate())-year(e.START_DATE) years_with_company,  s.LAST_NAME supervisor
from employee s, employee e
where e.SUPERIOR_EMP_ID =s.EMP_ID
order by s.LAST_NAME;

-- Query 21
-- For each supervisor, list their last name (use the column heading ‘Supervisor Last Name’) and the number of employees supervised (use the column heading ‘Number of employees’)
select s.LAST_NAME Supervisor_Last_Name,count(*) Number_of_employees
from employee s, employee e
where e.SUPERIOR_EMP_ID =s.EMP_ID
group by s.EMP_ID;

-- Query 22 
-- Retrieve all records for open back accounts
select *
from account
where CLOSE_DATE is null;

-- Query 23
-- Return all records from the account table where there are no records in the ACC_TRANSACTION table for the given account_id.
select *
from account
where ACCOUNT_ID not in 
	(select a.ACCOUNT_ID
	from acc_transaction aa, account a
     where aa.ACCOUNT_ID =a.ACCOUNT_ID);

-- Query 24
-- Create a View, ‘ACTIVE_ACCOUNTS’, for all records from the account table where there are records in the ACC_TRANSACTION table for the given account_id.
create view ACTIVE_ACCOUNTS as
select *
from account
where ACCOUNT_ID  in 
	(select a.ACCOUNT_ID
	from acc_transaction aa, account a
     where aa.ACCOUNT_ID =a.ACCOUNT_ID);

-- Query 25 
-- For all active accounts, list the product_cd (possible values are cd, chk, mm, sav), and the average, min and max available balance.
select product_cd, avg(AVAIL_BALANCE), min(AVAIL_BALANCE),max(AVAIL_BALANCE)
from ACTIVE_ACCOUNTS
group by product_cd;
