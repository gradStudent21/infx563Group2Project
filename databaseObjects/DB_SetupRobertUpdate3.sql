--1. Review -  #Roles
--2. Generate Database diagram from SQL
--3. Notify Robert to add data - with all required information
--#4. call out artifacts 

--TODO FINISH COMMENT, MAKE SURE IDENTITY ALWAYS STARTS AT 1, ADD ALL THE POSSIBLE ROLES, 
--STAFF, TEST SCRIPTS

/*
 * Authors: Robert Marshall (database objects and data population), Anuj Joshi (Stored procedures 
 * and views), Ram(stored procedures and views), Pierre Augustamar(stored procedudres and views)
 * Purpose: INFX563 - Group 2 Final Project
 */

/*
This section of the script creates the Summer camp database and related tables
*/
USE master;
GO

CREATE DATABASE SUMMER_CAMP
GO

USE SUMMER_CAMP;
GO

/* 
Creating a schema to host all related objects. This will come in handy if this 
database is moved/integrated into any other larger enterprise system in the future.
*/

CREATE SCHEMA CAMP
GO

/*
   Role table contains info about the possible roles and their permissions
   Role_Id 1 is for administrator,  2 for instructor, 3 for work crews, 4 for parent, 5 for student
*/
CREATE TABLE CAMP.ROLES
	(
		ROLE_ID INT PRIMARY KEY,
		ROLE_NAME VARCHAR(40) NOT NULL
	);

	/*
	  This table is a mapping that allows to identify the autorization based on a role
	  Add a trigger to throw an error if someone tries to add a view that does not exist
	   - done
	*/

CREATE TABLE CAMP.ROLE_AUTHORIZATION
	(
	    ROLE_ID INT FOREIGN KEY REFERENCES CAMP.ROLES(ROLE_ID),
		VIEW_NAME VARCHAR(255) NULL
		);

/*
MASTER USER TABLE : Contains the unique list of users. This can be leveraged for user login purposes
*/
CREATE TABLE  CAMP.[USER]
	(
		[USER_ID]					   INT PRIMARY KEY,
		[PWD]						   VARCHAR(30) NOT NULL,
		[UID]						   UNIQUEIDENTIFIER NOT NULL,
		FIRST_NAME					   VARCHAR(40) NOT NULL,
		LAST_NAME                      VARCHAR(40) NOT NULL,
		IS_ACTIVE					   BIT NOT NULL,
		CREATED_DATE				   DATETIME NOT NULL,
		UPDATED_DATE				   DATETIME NULL
	);

CREATE TABLE CAMP.MAP_USER_ROLE
	(
	    [USER_ID]		 INT FOREIGN KEY REFERENCES CAMP.[USER]([USER_ID]),
	    [ROLE_ID]		 INT FOREIGN KEY REFERENCES CAMP.[ROLES]([ROLE_ID]),
		CREATED_DATE	 DATETIME NOT NULL
	);

		/*
   Parent table that contains parent's name, role and contact. This table can be scaled 
   to host attributes that are unique to parents.
*/
CREATE TABLE CAMP.PARENT
	(
		PARENT_ID					   INT PRIMARY KEY FOREIGN KEY REFERENCES CAMP.[USER]([USER_ID]),
		EMERGENCY_PHONE_NUMBER         VARCHAR(40) NOT NULL,
		CREATED_DATE				   DATETIME NOT NULL,
		UPDATED_DATE				   DATETIME NULL
	);

/*
   Student table that contains student's name, and date of birth. This table can be scaled to host attributes that are unique to students.
*/

CREATE TABLE CAMP.STUDENT
	(
		STUDENT_ID	INT PRIMARY KEY FOREIGN KEY REFERENCES CAMP.[USER]([USER_ID]),
		DATE_OF_BIRTH DATE NOT NULL,
		PARENT_ID1   INT FOREIGN KEY REFERENCES CAMP.PARENT(PARENT_ID),
		PARENT_ID2   INT NULL FOREIGN KEY REFERENCES CAMP.PARENT(PARENT_ID),
		CREATED_DATE DATETIME NOT NULL,
		UPDATED_DATE DATETIME NULL,
	);

/*
	Staff table contains demographic info for any members that are part of the school staff. 
	A staff can be an instructor, administrator, and work crew. The Role identified the
	permission level of each staff
*/

CREATE TABLE CAMP.STAFF
	(
		STAFF_ID		INT PRIMARY KEY FOREIGN KEY REFERENCES CAMP.[USER]([USER_ID]),
	    PHONE			VARCHAR(40) NOT NULL,
		[START_DATE]	DATE NOT NULL,
		[END_DATE]		DATE NULL,
		CREATED_DATE	DATETIME NOT NULL,
		UPDATED_DATE	DATETIME NULL
	);

--Table 7 dbo.Building
CREATE TABLE CAMP.BUILDING
	(
		BUILDING_ID		INT PRIMARY KEY,
		BUILDING_NAME	VARCHAR(40) NOT NULL,
		LATITUDE		VARCHAR(40) NOT NULL,
		LONGITUDE		VARCHAR(40) NOT NULL,
		IS_ACTIVE		BIT NOT NULL,
		CREATED_DATE	DATETIME NOT NULL,
		UPDATED_DATE	DATETIME NULL
	);

--Table 8 dbo.Room
CREATE TABLE CAMP.ROOM
	(
		ROOM_ID			INT PRIMARY KEY,
		ROOM_NAME		VARCHAR(40) NOT NULL,
		PHONE			VARCHAR(40) NULL,
		BUILDING_ID		INT FOREIGN KEY REFERENCES CAMP.BUILDING(BUILDING_ID),
		IS_ACTIVE		BIT NOT NULL,
		CREATED_DATE	DATETIME NOT NULL,
		UPDATED_DATE	DATETIME NULL
	);

/*
  Class table that contains class name and related room 
*/
CREATE TABLE CAMP.CLASS
	(
		CLASS_ID	INT PRIMARY KEY,
		CLASS_NAME  VARCHAR(40) NOT NULL,
		IS_ACTIVE		BIT NOT NULL
	);

/*
   Payment table contains possible payment's status. 
   Status: paid,  not paid
*/
CREATE TABLE CAMP.PAYMENT_STATUS
	(
	    PAYMENT_STATUS_ID  TINYINT PRIMARY KEY,
	    PAYMENT_STATUS     VARCHAR(40) NOT NULL
	);

	/*
      CAMP_YEAR HAS TO MATCH WITH PAYMENT DATE..NEED A CHECK
*/
	CREATE TABLE CAMP.MAP_STUDENT_PAYMENT
	(
	    STUDENT_ID	      INT FOREIGN KEY REFERENCES CAMP.STUDENT(STUDENT_ID),
	    PAYMENT_STATUS_ID TINYINT FOREIGN KEY REFERENCES CAMP.PAYMENT_STATUS(PAYMENT_STATUS_ID),
		PAYMENT_DATE	  DATE NULL,
		PAYMENT_DUE_DATE  DATE  NOT NULL,
		CAMP_YEAR		  CHAR(4) NOT NULL,
		PRIMARY KEY (STUDENT_ID, PAYMENT_STATUS_ID, CAMP_YEAR)
	);

/*
   Permission table contains possible permission status related to activities in the camp area
   Status: permission to leave camp early, permission to drive to and from camp, 
   permission to share photos on social media, permission to leave camp with other parents, 
   permission to go off camp areas
*/
CREATE TABLE CAMP.PERMISSION_TYPE
	(
	    PERMISSION_TYPE_ID	    INT PRIMARY KEY,
	    PERMISSION_TYPE         VARCHAR(40) NOT NULL,
		PERMISSION_TYPE_DESC    VARCHAR(255) NOT NULL,
		IS_ACTIVE				BIT NOT NULL,
	);

/*
   Release table contains possible release status that would allow 
   camp staffers to take actions in case of a medical emergency
   Status can be: consent to release, exception to release, non-consent to release
*/
CREATE TABLE CAMP.RELEASE_TYPE
	(
	    RELEASE_TYPE_ID		   INT PRIMARY KEY,
		RELEASE_TYPE           VARCHAR(40) NOT NULL,
	    RELEASE_TYPE_DESC      VARCHAR(255) NOT NULL,
		IS_ACTIVE			   BIT NOT NULL
	);

CREATE TABLE CAMP.MAP_STUDENT_PERMISSION
	(
	    STUDENT_ID		          INT FOREIGN KEY REFERENCES CAMP.STUDENT(STUDENT_ID),
	    PERMISSION_TYPE_ID		  INT FOREIGN KEY REFERENCES CAMP.PERMISSION_TYPE(PERMISSION_TYPE_ID),
		PERMISSION_START_DATE     DATE NOT NULL,
		PERMISSION_END_DATE       DATE NULL,
		CREATE_DATE				  DATETIME NOT NULL,
		PRIMARY KEY (STUDENT_ID, PERMISSION_TYPE_ID, PERMISSION_START_DATE)
	);

CREATE TABLE CAMP.MAP_STUDENT_RELEASE
	(
	    STUDENT_ID		          INT FOREIGN KEY REFERENCES CAMP.STUDENT(STUDENT_ID),
	    RELEASE_TYPE_ID			  INT FOREIGN KEY REFERENCES CAMP.RELEASE_TYPE(RELEASE_TYPE_ID),
		RELEASE_START_DATE        DATE NOT NULL,
		RELEASE_END_DATE          DATE NULL,
		CREATED_DATE			  DATETIME NOT NULL,
		PRIMARY KEY (STUDENT_ID, RELEASE_TYPE_ID, RELEASE_START_DATE)
	);

/*
	Schedule table is used to list out the weekly Summer schedule with a specifc date
*/

CREATE TABLE CAMP.SCHEDULE
	(
		SCHEDULE_ID INT PRIMARY KEY,
		CLASS_ID INT FOREIGN KEY REFERENCES CAMP.CLASS(CLASS_ID),
		ROOM_ID INT FOREIGN KEY REFERENCES CAMP.ROOM(ROOM_ID),
		STAFF_ID INT FOREIGN KEY REFERENCES CAMP.STAFF(STAFF_ID),
		CLASS_DATE DATE NOT NULL,
		START_TIME TIME NOT NULL,
		END_TIME TIME NOT NULL,
		UNIQUE (CLASS_ID, CLASS_DATE, START_TIME)
	);

/*
   Student_class table - an intermediary table for students that are assigned to one more classes
*/
CREATE TABLE CAMP.STUDENT_SCHEDULE
	(
		STUDENT_ID  INT FOREIGN KEY REFERENCES CAMP.STUDENT(STUDENT_ID),
		SCHEDULE_ID	INT FOREIGN KEY REFERENCES CAMP.SCHEDULE(SCHEDULE_ID),
		PRIMARY KEY (STUDENT_ID, SCHEDULE_ID)
	);

/*
-- To change DB before dropping the current one
USE Master;

--Drop Database
DROP DATABASE SUMMER_CAMP;
*/

/*
This section of the script populates all the related tables
*/

INSERT CAMP.ROLES VALUES 
	(1, 'administrator'),
	(2, 'instructor'),
	(3, 'work crews'),
	(4, 'parent'),
	(5, 'student');

INSERT CAMP.ROLE_AUTHORIZATION VALUES 
	(1, 'administrator'),
	(2, 'instructor'),
	(3, 'work crews'),
	(4, 'parent'),
	(5, 'student');

INSERT CAMP.[USER] VALUES 
	(1,'password1', '1F9619FF-8B86-D011-B42D-00C04FC964FF','Sam', 'Mae', 1, '2017-11-01 09:00:00', NULL),
	(2,'password2', '2F9619FF-8B86-D011-B42D-00C04FC964FF' ,'Jack', 'Paul', 1, '2017-11-01 09:00:00', NULL),
	(3,'password3', '3F9619FF-8B86-D011-B42D-00C04FC964FF','Matt', 'Joe', 1, '2017-11-01 09:00:00', NULL),
	(4,'password4', '4F9619FF-8B86-D011-B42D-00C04FC964FF','Anne', 'Anderson', 1, '2017-11-01 09:00:00', NULL),
	(5,'password5', '5F9619FF-8B86-D011-B42D-00C04FC964FF','Paul', 'Smith', 1, '2017-11-01 09:00:00', NULL),
	(6,'password6', '6F9619FF-8B86-D011-B42D-00C04FC964FF', 'Frank', 'Lynn', 1, '2017-11-01 09:00:00', NULL),
	(7,'password7', '7F9619FF-8B86-D011-B42D-00C04FC964FF','Hillary', 'Clinton', 1, '2017-11-01 09:00:00', NULL),
	(8,'password8', '8F9619FF-8B86-D011-B42D-00C04FC964FF','Joe', 'Coffee', 1, '2017-11-01 09:00:00', NULL),
	(9,'password9', '9F9619FF-8B86-D011-B42D-00C04FC964FF','Gladis', 'Night', 1, '2017-11-01 09:00:00', NULL),
	(10,'password10', '109619FF-8B86-D011-B42D-00C04FC964FF','Clay', 'Walker', 1, '2017-11-01 09:00:00', NULL),
	(11,'password11', '119619FF-8B86-D011-B42D-00C04FC964FF','Sal', 'Mae', 1, '2017-11-01 09:00:00', NULL),
	(21,'password21', '219619FF-8B86-D011-B42D-00C04FC964FF','Jeff', 'Mae', 1, '2017-11-01 09:00:00', NULL),
	(22,'password22', '229619FF-8B86-D011-B42D-00C04FC964FF','Rand', 'Paul', 1, '2017-11-01 09:00:00', NULL),
	(23,'password23', '239619FF-8B86-D011-B42D-00C04FC964FF','Cool', 'Joe', 1, '2017-11-01 09:00:00', NULL),
	(24,'password24', '249619FF-8B86-D011-B42D-00C04FC964FF','Mike', 'Anderson', 1, '2017-11-01 09:00:00', NULL),
	(25,'password25', '259619FF-8B86-D011-B42D-00C04FC964FF','Will', 'Smith', 1, '2017-11-01 09:00:00', NULL),
	(26,'password26', '269619FF-8B86-D011-B42D-00C04FC964FF','Sue', 'Lynn', 1, '2017-11-01 09:00:00', NULL),
	(27,'password27', '279619FF-8B86-D011-B42D-00C04FC964FF','Bernie', 'Trump', 1, '2017-11-01 09:00:00', NULL),
	(28,'password28', '289619FF-8B86-D011-B42D-00C04FC964FF','Chuck', 'Coffee', 1, '2017-11-01 09:00:00', NULL),
	(29,'password29', '299619FF-8B86-D011-B42D-00C04FC964FF','Fred', 'Night', 1, '2017-11-01 09:00:00', NULL),
	(30,'password30', '309619FF-8B86-D011-B42D-00C04FC964FF','Mary', 'Walker', 1, '2017-11-01 09:00:00', NULL),
	(41,'password41', '419619FF-8B86-D011-B42D-00C04FC964FF', 'Jefferson', 'King', 1, '2017-03-01 09:00:00', NULL),
	(42,'password42', '429619FF-8B86-D011-B42D-00C04FC964FF', 'Ray', 'Queen', 1, '2017-01-03 09:00:00', NULL),
	(43,'password43', '439619FF-8B86-D011-B42D-00C04FC964FF', 'Cory', 'Bishop', 1, '2017-03-01 09:00:00', NULL),
	(44,'password44', '449619FF-8B86-D011-B42D-00C04FC964FF', 'Mort', 'Knight', 0, '2017-03-01 09:00:00', '2017-11-01 09:00:00'),
	(45,'password45', '459619FF-8B86-D011-B42D-00C04FC964FF', 'Walter', 'Rook', 0, '2017-03-01 09:00:00', '2017-11-01 09:00:00'),
	(51,'password51', '519619FF-8B86-D011-B42D-00C04FC964FF', 'Susan', 'Castle', 1, '2017-03-01 09:00:00', NULL),
	(52,'password52', '529619FF-8B86-D011-B42D-00C04FC964FF', 'Betty', 'Pawn', 1, '2017-03-01 09:00:00', NULL),
	(53,'password53', '539619FF-8B86-D011-B42D-00C04FC964FF', 'Chance', 'Checker', 1, '2017-03-01 09:00:00', NULL),
	(54,'password54', '549619FF-8B86-D011-B42D-00C04FC964FF', 'Nate', 'Chess',  1, '2017-03-01 09:00:00', NULL),
	(55,'password55', '559619FF-8B86-D011-B42D-00C04FC964FF', 'Maple', 'Ladder', 1, '2017-03-01 09:00:00', NULL);

INSERT CAMP.MAP_USER_ROLE VALUES 
	(00001, 5, '2017-11-01 09:00:00'),
	(00002, 5, '2017-11-01 09:00:00'),
	(00003, 5, '2017-11-01 09:00:00'),
	(00004, 5, '2017-11-01 09:00:00'),
	(00005, 5, '2017-11-01 09:00:00'),
	(00006, 5, '2017-11-01 09:00:00'),
	(00007, 5, '2017-11-01 09:00:00'),
	(00008, 5, '2017-11-01 09:00:00'),
	(00009, 5, '2017-11-01 09:00:00'),
	(00010, 5, '2017-11-01 09:00:00'),
	(00011, 5, '2017-11-01 09:00:00'),
	(00021, 4, '2017-11-01 09:00:00'),
	(00022, 4, '2017-11-01 09:00:00'),
	(00023, 4, '2017-11-01 09:00:00'),
	(00024, 4, '2017-11-01 09:00:00'),
	(00025, 4, '2017-11-01 09:00:00'),
	(00026, 4, '2017-11-01 09:00:00'),
	(00027, 4, '2017-11-01 09:00:00'),
	(00028, 4, '2017-11-01 09:00:00'),
	(00029, 4, '2017-11-01 09:00:00'),
	(00030, 4, '2017-11-01 09:00:00'),
	(00041, 1, '2017-03-01 09:00:00'),
	(00042, 1, '2017-03-01 09:00:00'),
	(00043, 1, '2017-03-01 09:00:00'),
	(00044, 1, '2017-03-01 09:00:00'),
	(00045, 3, '2017-03-01 09:00:00'),
	(00051, 2, '2017-03-01 09:00:00'),
	(00052, 2, '2017-03-01 09:00:00'),
	(00053, 2, '2017-03-01 09:00:00'),
	(00054, 2, '2017-03-01 09:00:00'),
	(00055, 2, '2017-03-01 09:00:00');
	
INSERT CAMP.PARENT VALUES 
	(00021, '(123) 123-4999', '2017-11-01 09:00:00', NULL),
	(00022,'(123) 123-4000', '2017-11-01 09:00:00', NULL),
	(00023, '(123) 123-4001', '2017-11-01 09:00:00', NULL),
	(00024, '(123) 123-4522', '2017-11-01 09:00:00', NULL),
	(00025, '(123) 123-4533', '2017-11-01 09:00:00', NULL),
	(00026,'(123) 123-4588', '2017-11-01 09:00:00', NULL),
	(00027,'(123) 123-4776', '2017-11-01 09:00:00', NULL),
	(00028,'(123) 123-4912', '2017-11-01 09:00:00', NULL),
	(00029, '(123) 123-4639', '2017-11-01 09:00:00', NULL),
	(00030,'(123) 123-4555', '2017-11-01 09:00:00', NULL);

INSERT CAMP.STUDENT VALUES 
	(1, '2007-01-01', 21, NULL, '2017-11-01 09:00:00', NULL),
	(2, '2007-02-02', 22, NULL, '2017-11-01 09:00:00', NULL),
	(3, '2007-03-03', 23, NULL, '2017-11-01 09:00:00', NULL),
	(4, '2007-04-04', 24, NULL, '2017-11-01 09:00:00', NULL),
	(5, '2007-05-05', 25, NULL, '2017-11-01 09:00:00', NULL),
	(6, '2007-06-06', 26, NULL, '2017-11-01 09:00:00', NULL),
	(7, '2007-07-07', 27, NULL, '2017-11-01 09:00:00', NULL),
	(8, '2006-08-08', 28, NULL, '2017-11-01 09:00:00', NULL),
	(9, '2006-09-09', 29, NULL, '2017-11-01 09:00:00', NULL),
	(10, '2006-10-10', 30, NULL, '2017-11-01 09:00:00', NULL),
	(11,'2007-01-01', 21, NULL, '2017-11-01 09:00:00', NULL);

INSERT CAMP.STAFF VALUES 
	(00041, '(123) 123-4999', '2014-01-21', NULL, '2017-03-01 09:00:00', NULL),
	(00042, '(123) 123-4000', '2012-03-10', NULL, '2017-03-01 09:00:00', NULL),
	(00043, '(123) 123-4001', '2013-05-01', NULL, '2017-03-01 09:00:00', NULL),
	(00044, '(123) 123-4522', '2015-06-17', '2017-04-04', '2017-03-01 09:00:00', '2017-04-04 09:00:00'),
	(00045, '(123) 123-4533', '2016-11-11', '2017-04-05', '2017-03-01 09:00:00', '2015-04-05 09:00:00'),
	(00051, '(123) 123-4588', '2017-01-04', NULL, '2017-03-01 09:00:00', NULL),
	(00052, '(123) 123-4776', '2012-02-28', NULL, '2017-03-01 09:00:00', NULL),
	(00053, '(123) 123-4912', '2017-01-15', NULL, '2017-03-01 09:00:00', NULL),
	(00054, '(123) 123-4639', '2012-12-03', NULL, '2017-03-01 09:00:00', NULL),
	(00055, '(123) 123-4555', '2016-10-23', NULL, '2017-03-01 09:00:00', NULL);

INSERT CAMP.BUILDING VALUES
(100, 'Red Barn', 47.537500, -122.129441, 1,'2017-03-01 09:00:00', NULL),
(200, 'White Castle',47.537217, -122.129323, 1,'2017-03-01 09:00:00', NULL),
(300, 'Green House',47.537181, -122.129495, 1,'2017-03-01 09:00:00', NULL),
(400,'Blue Shed', 47.536652, -122.130214, 1,'2017-03-01 09:00:00', NULL),
(500,'Pink Tower', 47.536497, -122.130278, 1,'2017-03-01 09:00:00', NULL),
(600,'Brown Shrine', 47.536334, -122.129989, 0,'2017-03-01 09:00:00', '2017-11-01 09:00:00'),
(700,'Black Temple', 47.536377, -122.129828, 0,'2017-03-01 09:00:00', '2017-11-01 09:00:00'),
(800,'Purple Cellar', 47.536308, -122.129592, 0,'2017-03-01 09:00:00', '2017-11-01 09:00:00'),
(900,'Aqua Stable', 47.537109, -122.127435, 0,'2017-03-01 09:00:00', '2017-11-01 09:00:00'),
(1000,'Yellow Arcade', 47.537496, -122.127277, 0,'2017-03-01 09:00:00', '2017-11-01 09:00:00'),
(1001,'Violet Hall', 47.537940, -122.127196, 0,'2017-03-01 09:00:00', '2017-11-01 09:00:00');

INSERT CAMP.ROOM VALUES
(1, 'Red A', '(123) 123-4501', 100, 1,'2017-03-01 09:00:00', NULL),
(2, 'Red B', '(123) 123-4502', 100, 1,'2017-03-01 09:00:00', NULL),
(3, 'White A', '(123) 123-4503', 200, 1,'2017-03-01 09:00:00', NULL),
(4, 'White B', '(123) 123-4504', 200, 1,'2017-03-01 09:00:00', NULL),
(5, 'Green A', '(123) 123-4505', 300, 1,'2017-03-01 09:00:00', NULL),
(6, 'Green B', '(123) 123-4506', 300, 1,'2017-03-01 09:00:00', NULL),
(7, 'Blue A', '(123) 123-4507', 400, 1,'2017-03-01 09:00:00', NULL),
(8, 'Blue B', '(123) 123-4508', 400, 1,'2017-03-01 09:00:00', NULL),
(9, 'Pink A', '(123) 123-4509', 500, 1,'2017-03-01 09:00:00', NULL),
(10, 'Pink B', '(123) 123-4510', 500, 1,'2017-03-01 09:00:00', NULL);

INSERT CAMP.CLASS VALUES
(1, 'Animals', 1),
(2, 'Insects', 1),
(3, 'Plants', 1),
(4, 'Trees', 1),
(5, 'Survival', 1),
(6, 'Reptiles', 1),
(7, 'Canoe', 1),
(8, 'First Aid', 1),
(9, 'Shelter', 1),
(10, 'Basket Weaving', 1);

INSERT CAMP.PAYMENT_STATUS VALUES
(1, 'paid'),
(2, 'not paid');

INSERT CAMP.MAP_STUDENT_PAYMENT VALUES
(1, 1, '2017-01-11', '2017-12-01', 2018),
(2, 1, '2017-03-21', '2017-12-01', 2018),
(3, 1, '2017-09-13', '2017-12-01', 2018),
(4, 1, '2017-07-18', '2017-12-01', 2018),
(5, 1, '2017-02-19', '2017-12-01', 2018),
(6, 1, '2017-08-22', '2017-12-01', 2018),
(7, 1, '2017-11-19', '2017-12-01', 2018),
(8, 1, '2017-06-09', '2017-12-01', 2018),
(9, 2, NULL, '2017-12-01', 2018),
(10, 2, NULL, '2017-12-01', 2018),
(11, 1, '2017-07-01', '2017-12-01', 2018);

INSERT CAMP.PERMISSION_TYPE VALUES
(1, 'Leave Early', 'permission to leave camp early', 1),
(2, 'Drive', 'permission to drive to and from camp', 1),
(3, 'Media Share', 'permission to share photos on social media', 1),
(4, 'ALT Parents', 'permission to leave camp with other parents', 1),
(5, 'Off Camp', 'permission to go off camp areas', 1);

INSERT CAMP.RELEASE_TYPE VALUES
(1, 'Consent', 'consent to release', 1),
(2, 'Exception', 'exception to release', 1),
(3, 'Non-consent', 'non-consent to release', 1);

INSERT CAMP.MAP_STUDENT_PERMISSION VALUES
(1, 1, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(1, 2, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(1, 3, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(1, 4, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(1, 5, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(2, 5, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(3, 5, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(4, 5, '2010-01-01' , NULL,'2017-11-01 09:00:00'),
(5, 5, '2010-01-01' , NULL,'2017-11-01 09:00:00');

INSERT CAMP.MAP_STUDENT_RELEASE VALUES
(1, 2, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(2, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(3, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(4, 3, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(5, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(6, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(7, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(8, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(9, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(10, 1, '2018-06-11', '2018-06-15','2017-11-01 09:00:00'),
(11, 2, '2018-06-11', '2018-06-15', '2017-11-01 09:00:00');

INSERT CAMP.SCHEDULE VALUES
(1111, 1, 1, 51, '2018-06-11', '09:00:00','12:00:00'),
(1112, 2, 2, 52, '2018-06-11', '09:00:00','12:00:00'),
(1113, 3, 3, 53, '2018-06-11', '09:00:00','12:00:00'),
(1114, 4, 4, 54, '2018-06-11', '09:00:00','12:00:00'),
(1115, 5, 5, 55, '2018-06-11', '09:00:00','12:00:00'),
(1121, 2, 6, 55, '2018-06-11', '13:00:00','16:00:00'),
(1122, 3, 7, 54, '2018-06-11', '13:00:00','16:00:00'),
(1123, 4, 8, 53, '2018-06-11', '13:00:00','16:00:00'),
(1124, 5, 9, 52, '2018-06-11', '13:00:00','16:00:00'),
(1125, 1, 10, 51, '2018-06-11', '13:00:00','16:00:00'),
(1211, 3, 2, 51, '2018-06-12', '09:00:00','12:00:00'),
(1212, 4, 3, 52, '2018-06-12', '09:00:00','12:00:00'),
(1213, 5, 4, 53, '2018-06-12', '09:00:00','12:00:00'),
(1214, 1, 5, 54, '2018-06-12', '09:00:00','12:00:00'),
(1215, 2, 6, 55, '2018-06-12', '09:00:00','12:00:00'),
(1221, 4, 7, 55, '2018-06-12', '13:00:00','16:00:00'),
(1222, 5, 8, 54, '2018-06-12', '13:00:00','16:00:00'),
(1223, 1, 9, 53, '2018-06-12', '13:00:00','16:00:00'),
(1224, 2, 10, 52, '2018-06-12', '13:00:00','16:00:00'),
(1225, 3, 1, 51, '2018-06-12', '13:00:00','16:00:00'),
(1311, 5, 3, 51, '2018-06-13', '09:00:00','12:00:00'),
(1312, 1, 4, 52, '2018-06-13', '09:00:00','12:00:00'),
(1313, 2, 5, 53, '2018-06-13', '09:00:00','12:00:00'),
(1314, 3, 6, 54, '2018-06-13', '09:00:00','12:00:00'),
(1315, 4, 7, 55, '2018-06-13', '09:00:00','12:00:00'),
(1321, 6, 8, 55, '2018-06-13', '13:00:00','16:00:00'),
(1322, 7, 9, 54, '2018-06-13', '13:00:00','16:00:00'),
(1323, 8, 10, 53, '2018-06-13', '13:00:00','16:00:00'),
(1324, 9, 1, 52, '2018-06-13', '13:00:00','16:00:00'),
(1325, 10, 2, 51, '2018-06-13', '13:00:00','16:00:00'),
(1411, 7, 4, 51, '2018-06-14', '09:00:00','12:00:00'),
(1412, 8, 5, 52, '2018-06-14', '09:00:00','12:00:00'),
(1413, 9, 6, 53, '2018-06-14', '09:00:00','12:00:00'),
(1414, 10, 7, 54, '2018-06-14', '09:00:00','12:00:00'),
(1415, 6, 8, 55, '2018-06-14', '09:00:00','12:00:00'),
(1421, 8, 9, 55, '2018-06-14', '13:00:00','16:00:00'),
(1422, 9, 10, 54, '2018-06-14', '13:00:00','16:00:00'),
(1423, 10, 1, 53, '2018-06-14', '13:00:00','16:00:00'),
(1424, 6, 2, 52, '2018-06-14', '13:00:00','16:00:00'),
(1425, 7, 3, 51, '2018-06-14', '13:00:00','16:00:00'),
(1511, 9, 5, 51, '2018-06-15', '09:00:00','12:00:00'),
(1512, 10, 6, 52, '2018-06-15', '09:00:00','12:00:00'),
(1513, 6, 7, 53, '2018-06-15', '09:00:00','12:00:00'),
(1514, 7, 8, 54, '2018-06-15', '09:00:00','12:00:00'),
(1515, 8, 9, 55, '2018-06-15', '09:00:00','12:00:00'),
(1521, 10, 10, 55, '2018-06-15', '13:00:00','16:00:00'),
(1522, 6, 1, 54, '2018-06-15', '13:00:00','16:00:00'),
(1523, 7, 2, 53, '2018-06-15', '13:00:00','16:00:00'),
(1524, 8, 3, 52, '2018-06-15', '13:00:00','16:00:00'),
(1525, 9, 4, 51, '2018-06-15', '13:00:00','16:00:00');

INSERT CAMP.STUDENT_SCHEDULE VALUES
(1, 1111),
(1, 1121),
(1, 1211),
(1, 1221),
(1, 1311),
(1, 1321),
(1, 1411),
(1, 1421),
(1, 1511),
(1, 1521),
(2, 1112),
(2, 1122),
(2, 1212),
(2, 1222),
(2, 1312),
(2, 1322),
(2, 1412),
(2, 1422),
(2, 1512),
(2, 1522),
(3, 1113),
(3, 1123),
(3, 1213),
(3, 1223),
(3, 1313),
(3, 1323),
(3, 1413),
(3, 1423),
(3, 1513),
(3, 1523),
(4, 1114),
(4, 1124),
(4, 1214),
(4, 1224),
(4, 1314),
(4, 1324),
(4, 1414),
(4, 1424),
(4, 1514),
(4, 1524),
(5, 1115),
(5, 1125),
(5, 1215),
(5, 1225),
(5, 1315),
(5, 1325),
(5, 1415),
(5, 1425),
(5, 1515),
(5, 1525),
(6, 1111),
(6, 1121),
(6, 1211),
(6, 1221),
(6, 1311),
(6, 1321),
(6, 1411),
(6, 1421),
(6, 1511),
(6, 1521),
(7, 1112),
(7, 1122),
(7, 1212),
(7, 1222),
(7, 1312),
(7, 1322),
(7, 1412),
(7, 1422),
(7, 1512),
(7, 1522),
(8, 1113),
(8, 1123),
(8, 1213),
(8, 1223),
(8, 1313),
(8, 1323),
(8, 1413),
(8, 1423),
(8, 1513),
(8, 1523),
(9, 1114),
(9, 1124),
(9, 1214),
(9, 1224),
(9, 1314),
(9, 1324),
(9, 1414),
(9, 1424),
(9, 1514),
(9, 1524),
(10, 1115),
(10, 1125),
(10, 1215),
(10, 1225),
(10, 1315),
(10, 1325),
(10, 1415),
(10, 1425),
(10, 1515),
(10, 1525),
(11, 1111),
(11, 1121),
(11, 1211),
(11, 1221),
(11, 1311),
(11, 1321),
(11, 1411),
(11, 1421),
(11, 1511),
(11, 1521);
