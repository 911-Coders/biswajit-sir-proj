# Library Management System

A dynamic web application developed using Java Servlets, JSP, JDBC, and Oracle Database.

## Features
- **Book Registration**: Register new books into the Oracle database.
- **Stock Management**: Update and revise available stock copies.
- **Lend & Return**: Issue books to students (-1 quantity) and mark returned (+1 quantity).
- **Tabular Display**: View all books and active borrowed loans in real time.

## Tech Stack
- Frontend: JSP, HTML5, CSS
- Backend: Java Servlet (Jakarta EE 11 / Servlet 6.0)
- Database: Oracle Database (JDBC via `ojdbc11.jar`)
- Server: Apache Tomcat 11
- IDE: Eclipse IDE for Enterprise Java

## Database Setup

```sql
CREATE TABLE BOOK (
    BOOK_ID NUMBER(5) PRIMARY KEY,
    BOOK_TITLE VARCHAR2(150) NOT NULL,
    AUTHOR_NAME VARCHAR2(100),
    PUBLISHER_NAME VARCHAR2(100),
    CATEGORY VARCHAR2(50),
    EDITION VARCHAR2(20),
    PUBLICATION_YEAR NUMBER(4),
    PRICE NUMBER(10,2),
    QUANTITY NUMBER(5)
);

CREATE TABLE BOOK_ISSUE (
    ISSUE_ID NUMBER(6) PRIMARY KEY,
    BOOK_ID NUMBER(5) NOT NULL,
    STUDENT_NAME VARCHAR2(100) NOT NULL,
    ISSUE_DATE VARCHAR2(30),
    STATUS VARCHAR2(20) DEFAULT 'ISSUED'
);
```

## Running the Project
1. Import into Eclipse: **File > Import > Existing Projects into Workspace**.
2. Configure Apache Tomcat 11 runtime.
3. Right-click project > **Run As > Run on Server**.
