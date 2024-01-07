-- 
-- ORACLE application database and associated users creation script for CST2355
--
-- Created by:  Group12
--
-- should be run while connected as 'sys as sysdba'
--

-- Create STORAGE
CREATE TABLESPACE group12
  DATAFILE 'group12.dat' SIZE 40M 
  ONLINE; 
  
-- Create Users
CREATE USER group12 IDENTIFIED BY group12 ACCOUNT UNLOCK
	DEFAULT TABLESPACE group12
	QUOTA 20M ON group12;
	
	
-- Create ROLES
CREATE ROLE group12Admin;

-- Grant PRIVILEGES
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE TRIGGER, CREATE PROCEDURE TO group12Admin;
GRANT group12Admin TO group12;

-- NOW we can connect as the applicationAdmin and create the stored procedures, tables, and triggers

CONNECT group12/group12;

--
-- Stored procedures for use by triggers ignore here
--
-- Create tables in Oracle
-- 
CREATE TABLE Order_status (
  statusID NUMBER PRIMARY KEY,
  status_name VARCHAR2(10) -- Use VARCHAR2 in Oracle
);

CREATE TABLE ToolCategories (
  categoryID NUMBER PRIMARY KEY,
  category_name VARCHAR2(30)
);

CREATE TABLE Tools (
  toolID NUMBER PRIMARY KEY,
  tool_name VARCHAR2(50),
  model VARCHAR2(30),
  manufacture VARCHAR2(50),
  categoryID NUMBER NOT NULL,
  purchase_price NUMBER, -- Use NUMBER for DECIMAL in Oracle
  rental_fee_per_day NUMBER NOT NULL,
  inventory NUMBER, -- Use NUMBER for INT in Oracle
  FOREIGN KEY (categoryID) REFERENCES ToolCategories(categoryID)
);

CREATE TABLE Customers (
  customerID NUMBER PRIMARY KEY,
  customer_name VARCHAR2(50),
  address VARCHAR2(50),
  phone_number VARCHAR2(15) NOT NULL,
  profession VARCHAR2(20)
);

CREATE TABLE Employees (
  employeeID NUMBER PRIMARY KEY,
  firstName VARCHAR2(50) NOT NULL,
  lastName VARCHAR2(50) NOT NULL,
  username VARCHAR2(50) NOT NULL,
  password VARCHAR2(50),
  role VARCHAR2(20),
  department VARCHAR2(20)
);

CREATE TABLE Orders (
  orderID NUMBER PRIMARY KEY,
  order_date DATE,
  end_date DATE,
  customerID NUMBER,
  employeeID NUMBER,
  description VARCHAR2(200),
  statusID NUMBER,
  deposit NUMBER, -- Use NUMBER for DECIMAL in Oracle
  total_price NUMBER NOT NULL, -- Use NUMBER for DECIMAL in Oracle
  FOREIGN KEY (customerID) REFERENCES Customers(customerID),
  FOREIGN KEY (employeeID) REFERENCES Employees(employeeID),
  FOREIGN KEY (statusID) REFERENCES Order_status(statusID)
);

CREATE TABLE OrderItems (
  orderToolID NUMBER PRIMARY KEY,
  orderID NUMBER,
  toolID NUMBER,
  qty NUMBER NOT NULL, -- Use NUMBER for INT in Oracle
  FOREIGN KEY (orderID) REFERENCES Orders(orderID),
  FOREIGN KEY (toolID) REFERENCES Tools(toolID)
);

-- Insert DATA

INSERT INTO Order_status VALUES (1, 'Pending');
INSERT INTO Order_status VALUES (2, 'Returned');
INSERT INTO Order_status VALUES (3, 'Overdued');

INSERT INTO ToolCategories VALUES (101, 'Power Tools');
INSERT INTO ToolCategories VALUES (102, 'Hand Tools');
INSERT INTO ToolCategories VALUES (103, 'Gardening');

INSERT INTO Tools VALUES (1001, 'Drill', 'X120', 'Bosch', 101, 150, 10, 5);
INSERT INTO Tools VALUES (1002, 'Hammer', 'H5', 'Stanley', 102, 30, 5, 10);
INSERT INTO Tools VALUES (1003, 'Lawn Mower', 'LM300', 'Honda', 103, 300, 25, 3);

INSERT INTO Customers VALUES (201, 'John Doe', '123 Main St', '555-0101', 'Carpenter');
INSERT INTO Customers VALUES (202, 'Jane Smith', '456 Elm St', '555-0202', 'Gardener');

INSERT INTO Employees VALUES (301, 'Alice', 'Brown', 'aliceb', 'pass123', 'Manager', 'Sales');
INSERT INTO Employees VALUES (302, 'Bob', 'White', 'bobw', 'pass456', 'Clerk', 'Customer Service');

INSERT INTO Orders VALUES (401, SYSDATE, NULL, 201, 301, 'Drill rental', 1, 50, 100);
INSERT INTO Orders VALUES (402, SYSDATE, NULL, 202, 302, 'Garden tools rental', 1, 75, 150);

INSERT INTO OrderItems VALUES (501, 401, 1001, 1);
INSERT INTO OrderItems VALUES (502, 402, 1003, 2);


----
--  is-a relationship
----
-- Create New SEQUENCE
CREATE SEQUENCE Roles _seq START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE EmployeeRoles _seq START WITH 100 INCREMENT BY 1;
CREATE SEQUENCE Employees_seq START WITH 100 INCREMENT BY 1;


-- CREATE VIEW EMPLOYEE_VIEW
CREATE VIEW EMPLOYEE_VIEW AS
SELECT E.employeeID, E.firstName, E.lastName, E.username, E.password, R.roleName
FROM Employees E
LEFT JOIN EmployeeRoles ER 
ON E.employeeID = ER.ER_employeeID
LEFT JOIN Roles R
ON ER.roleID = R.roleID
WHERE ER.ENDTIME IS NULL;

-- Create New tables
CREATE TABLE EMPLOYEEROLES
   (	"EMPLOYEEROLEID" NUMBER, 
	"EMPLOYEEID" NUMBER, 
	"ROLEID" NUMBER, 
	"STARTTIME" TIMESTAMP (6), 
	"ENDTIME" TIMESTAMP (6), 
	"ROLENAME" VARCHAR2(20 BYTE), 
	"USERNAME" VARCHAR2(50 BYTE), 
	"EMPLOYEENAME" VARCHAR2(20 BYTE), 
	"ACTION" VARCHAR2(20 BYTE), 
	 PRIMARY KEY ("EMPLOYEEROLEID")
    );


-- 3 types Trigger creation 
create or replace TRIGGER Employee_View_Insert
INSTEAD OF INSERT ON Employee_View
FOR EACH ROW
DECLARE
    v_roleID NUMBER;
BEGIN
    BEGIN
        SELECT roleID INTO v_roleID FROM Roles WHERE roleName = :NEW.roleName;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO Roles (roleID, roleName) VALUES (roles_seq.NEXTVAL, :NEW.roleName);
            v_roleID := roles_seq.CURRVAL;
    END;

    INSERT INTO Employees (employeeID, firstName, lastName, username, password)
    VALUES (:NEW.employeeID, :NEW.firstName, :NEW.lastName, :NEW.username, :NEW.password);

    INSERT INTO EmployeeRoles (employeeRoleID, employeeID, roleID,roleName, STARTTIME,action,employeename)
    VALUES (EmployeeRoles_seq.NEXTVAL, :NEW.employeeID, v_roleID,:NEW.roleName,TO_TIMESTAMP(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),
    'inserted',:NEW.username);
END;


create or replace TRIGGER Employee_View_Update
INSTEAD OF UPDATE ON Employee_View
FOR EACH ROW
DECLARE
    v_roleID NUMBER;
BEGIN
    BEGIN
        SELECT roleID INTO v_roleID FROM Roles WHERE roleName = :NEW.roleName;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO Roles (roleID, roleName) VALUES (roles_seq.NEXTVAL, :NEW.roleName);
            v_roleID := roles_seq.CURRVAL;
    END;

    UPDATE Employees
    SET firstName = :NEW.firstName,
        lastName = :NEW.lastName,
        username = :NEW.username,
        password = :NEW.password
    WHERE employeeID = :OLD.employeeID;

    UPDATE EmployeeRoles
    SET ENDTIME = SYSDATE
    WHERE employeeID = :OLD.employeeID AND ENDTIME IS NULL;

    INSERT INTO EmployeeRoles (employeeRoleID, employeeID, roleID,rolename, STARTTIME,action,employeename)
    VALUES (EmployeeRoles_seq.NEXTVAL, :OLD.employeeID, v_roleID,:NEW.roleName, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'),'Update',:NEW.username);
END;


create or replace TRIGGER Employee_View_Delete
INSTEAD OF DELETE ON Employee_View
FOR EACH ROW

BEGIN

   -- Check if v_roleID is null and handle the situation accordingly
      INSERT INTO EmployeeRoles (employeeRoleID, employeeID, rolename, STARTTIME, action,employeename)
      VALUES (EmployeeRoles_seq.NEXTVAL, :OLD.employeeID, :OLD.rolename, TO_TIMESTAMP(TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS'), 'Deleted',:OLD.username);

    UPDATE Employees
    SET isDeleted = 'Y'
    WHERE employeeID = :OLD.employeeID;
END;


---
-- contain relationship
---
-- change orerItems table
ALTER TABLE OrderItems
ADD (
  STARTTIME DATE,
  ENDTIME DATE
);

-- Create View
CREATE VIEW ORDER_ITEMS_VIEW AS 
SELECT O.orderID, O.order_date, O.end_date, O.customerID, O.employeeID, O.description, O.statusID, O.deposit, O.total_price,
       I.orderToolID, I.toolID, I.qty, I.STARTTIME
FROM Orders O
LEFT JOIN OrderItems I ON O.orderID = I.orderID
WHERE I.ENDTIME IS NULL;


-- Create Trigger
CREATE OR REPLACE TRIGGER ORDER_ITEMS_VIEW_INSERT
INSTEAD OF INSERT ON ORDER_ITEMS_VIEW
FOR EACH ROW
BEGIN
  -- Insert into Orders if not exists
  IF NOT EXISTS (SELECT 1 FROM Orders WHERE orderID = :NEW.orderID) THEN
    INSERT INTO Orders (orderID, order_date, end_date, customerID, employeeID, description, statusID, deposit, total_price)
    VALUES (:NEW.orderID, :NEW.order_date, :NEW.end_date, :NEW.customerID, :NEW.employeeID, :NEW.description, :NEW.statusID, :NEW.deposit, :NEW.total_price);
  END IF;

  -- Insert into OrderItems
  INSERT INTO OrderItems (orderToolID, orderID, toolID, qty, STARTTIME)
  VALUES (OrderItems_seq.NEXTVAL, :NEW.orderID, :NEW.toolID, :NEW.qty, SYSDATE);
END;

CREATE OR REPLACE TRIGGER ORDER_ITEMS_VIEW_UPDATE
INSTEAD OF UPDATE ON ORDER_ITEMS_VIEW
FOR EACH ROW
BEGIN
  -- Update Orders
  UPDATE Orders
  SET order_date = :NEW.order_date, 
      end_date = :NEW.end_date, 
      customerID = :NEW.customerID, 
      employeeID = :NEW.employeeID, 
      description = :NEW.description, 
      statusID = :NEW.statusID, 
      deposit = :NEW.deposit, 
      total_price = :NEW.total_price
  WHERE orderID = :OLD.orderID;

  -- Close current OrderItem and create a new one if it has changed
  IF :NEW.toolID != :OLD.toolID OR :NEW.qty != :OLD.qty THEN
    UPDATE OrderItems
    SET ENDTIME = SYSDATE
    WHERE orderToolID = :OLD.orderToolID AND ENDTIME IS NULL;

    INSERT INTO OrderItems (orderToolID, orderID, toolID, qty, STARTTIME)
    VALUES (OrderItems_seq.NEXTVAL, :OLD.orderID, :NEW.toolID, :NEW.qty, SYSDATE);
  END IF;
END;

CREATE OR REPLACE TRIGGER ORDER_ITEMS_VIEW_DELETE
INSTEAD OF DELETE ON ORDER_ITEMS_VIEW
FOR EACH ROW
BEGIN
  -- Mark OrderItems as ended
  UPDATE OrderItems
  SET ENDTIME = SYSDATE
  WHERE orderToolID = :OLD.orderToolID AND ENDTIME IS NULL;

  -- Optional: Delete Orders if no more items
  -- DELETE FROM Orders WHERE orderID = :OLD.orderID AND NOT EXISTS (SELECT 1 FROM OrderItems WHERE orderID = :OLD.orderID AND ENDTIME IS NULL);
END;



----
--is-related-to relationship
---

-- create new table
CREATE TABLE CustomerOrderHistory (
  historyID NUMBER PRIMARY KEY,
  customerID NUMBER,
  orderID NUMBER,
  STARTTIME DATE,
  ENDTIME DATE,
  FOREIGN KEY (customerID) REFERENCES Customers(customerID),
  FOREIGN KEY (orderID) REFERENCES Orders(orderID)
);


-- create view
CREATE VIEW CUSTOMER_ORDER_VIEW AS 
SELECT C.customerID, C.customer_name, H.orderID, H.STARTTIME, H.ENDTIME
FROM Customers C
LEFT JOIN CustomerOrderHistory H
ON C.customerID = H.customerID
WHERE H.ENDTIME IS NULL;


-- create trigger
CREATE OR REPLACE TRIGGER CUSTOMER_ORDER_VIEW_INSERT
INSTEAD OF INSERT ON CUSTOMER_ORDER_VIEW
FOR EACH ROW
BEGIN
  INSERT INTO CustomerOrderHistory (historyID, customerID, orderID, STARTTIME, ENDTIME)
  VALUES (CustomerOrderHistory_seq.NEXTVAL, :NEW.customerID, :NEW.orderID, SYSDATE, NULL);
END;

CREATE OR REPLACE TRIGGER CUSTOMER_ORDER_VIEW_UPDATE
INSTEAD OF UPDATE ON CUSTOMER_ORDER_VIEW
FOR EACH ROW
BEGIN
  UPDATE CustomerOrderHistory
  SET ENDTIME = SYSDATE
  WHERE customerID = :OLD.customerID AND orderID = :OLD.orderID AND ENDTIME IS NULL;

  INSERT INTO CustomerOrderHistory (historyID, customerID, orderID, STARTTIME, ENDTIME)
  VALUES (CustomerOrderHistory_seq.NEXTVAL, :NEW.customerID, :NEW.orderID, SYSDATE, NULL);
END;

CREATE OR REPLACE TRIGGER CUSTOMER_ORDER_VIEW_DELETE
INSTEAD OF DELETE ON CUSTOMER_ORDER_VIEW
FOR EACH ROW
BEGIN
  UPDATE CustomerOrderHistory
  SET ENDTIME = SYSDATE
  WHERE customerID = :OLD.customerID AND orderID = :OLD.orderID AND ENDTIME IS NULL;
END;

