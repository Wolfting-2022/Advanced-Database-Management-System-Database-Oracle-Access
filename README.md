# Database-Application-and-Front-end-Design
1.
Transfer SQL code from（SQL server）to (Oracle server)
USE  Lab5b_link6a_create/cleanup to create similar tables Assign1_create_tables/cleanup
	!!!Attention: change tablespace,username/password,role
cmd(Admin) -- cd ../directory -- sqlplus / as sysdba -- SQL> @Assign1_create_tables.sql(no space) -- if NOK, exit and enter avoid under curret user

in Oracle developer -- new connection -- newName:Assigh2/group12/SID:orcl2355,test then connect

Insert data -- code style is differnt from SQL server which has 4 method:
1) 
INSERT INTO Order_status VALUES (1, 'Pending');
INSERT INTO Order_status VALUES (2, 'Completed');
INSERT INTO Order_status VALUES (3, 'Cancelled');

2) 
INSERT ALL
  INTO table_name (column1, column2) VALUES (value1_1, value1_2)
  INTO table_name (column1, column2) VALUES (value2_1, value2_2)
  ...
SELECT * FROM dual;
3)
INSERT INTO table_name (column1, column2)
SELECT value1_1, value1_2 FROM dual
UNION ALL
SELECT value2_1, value2_2 FROM dual
...
4)~~6)
******************************
2.
create ER Diagram

https://www.youtube.com/watch?v=2fPP_u_Nzyw

File -- Data modeler -- import -- data dictionary -- select Lab5b -- select Schema/Database: TINGUSER -- select all tables -- created ER
File -- Data modeler -- import -- print diagram -- pdf/png
change from "Lab5b" to "Assign2"	"TINGUSER" to "GROUP12"
SELECT OBJECTS TO IMPORT!!! --- recheck in Tables/Users/tablespace.. to provide just 7 tables/1 tablespace/1 User	
NOK Untill select Schema/Database . Import to : New Relational Model!!!

******************************
3.
three of your original tables each of which has a multi-valued fields
Create View:
	when DML(Insert/Update/Delete), Remember COMMIT; 

Create Trigger:
	

*******************************
4. 
ODBC config(64bits and 32bits both need config??)
localhost:1521/orcl2355		group12/group12

ACCESS connection 
create BLANK Database -- external Data/import/ODBC -- link -- machine data source/Assign1 -- group12.XXX 

***************************
5. check commit for DML?
HTML is a markup language.

C:\Windows\System32>sqlplus / as sysdba
SQL> connect group12/group12
Connected.
SQL> show autocommit
autocommit OFF
SQL> set autocommit on;

SQL> show autocommit;
autocommit IMMEDIATE;
----------------------
https://www.youtube.com/watch?v=ZVBGlWmYUy0 	HOW TO Oracle Database Backup Using SQL Developer and Restore Using Oracle Work Space??

**************************
To CREATE is-a trigger, Need alter/add tables
modify on DB
