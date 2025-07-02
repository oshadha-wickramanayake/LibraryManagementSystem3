-- Create Table: Category
CREATE TABLE BookCategory (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL
);
-- Create Table: Book
CREATE TABLE Book (
    book_id NUMBER PRIMARY KEY,
    title VARCHAR2(100) NOT NULL,
    author VARCHAR2(100),
    publisher VARCHAR2(100),
    year NUMBER,
    category_id NUMBER,
    available_copies NUMBER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES BookCategory(category_id)
);

-- Create Table: Member
CREATE TABLE Member (
    member_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    address VARCHAR2(200),
    phone VARCHAR2(15),
    email VARCHAR2(100)
);

-- Create Table: Borrowing
CREATE TABLE Borrowing (
    borrowing_id NUMBER PRIMARY KEY,
    member_id NUMBER,
    book_id NUMBER,
    borrow_date DATE DEFAULT SYSDATE,
    return_date DATE,
    status VARCHAR2(20) CHECK (status IN ('Borrowed', 'Returned')),
    FOREIGN KEY (member_id) REFERENCES Member(member_id),
    FOREIGN KEY (book_id) REFERENCES Book(book_id)
);

-- Insert data into BookCategory
INSERT INTO BookCategory (category_id, category_name) VALUES (1, 'Science Fiction');
INSERT INTO BookCategory (category_id, category_name) VALUES (2, 'History');
INSERT INTO BookCategory (category_id, category_name) VALUES (3, 'Technology');

-- Insert data into Book
INSERT INTO Book (book_id, title, author, publisher, year, category_id, available_copies)
VALUES (101, 'The Time Machine', 'H.G. Wells', 'Penguin', 1895, 1, 5);

INSERT INTO Book (book_id, title, author, publisher, year, category_id, available_copies)
VALUES (102, 'Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', 'Harper', 2015, 2, 3);

INSERT INTO Book (book_id, title, author, publisher, year, category_id, available_copies)
VALUES (103, 'Introduction to Algorithms', 'Thomas H. Cormen', 'MIT Press', 2009, 3, 4);

-- Insert data into Member
INSERT INTO Member (member_id, name, address, phone, email)
VALUES (1, 'Alice Johnson', '123 Main St', '123-456-7890', 'alice@example.com');

INSERT INTO Member (member_id, name, address, phone, email)
VALUES (2, 'Bob Smith', '456 Elm St', '987-654-3210', 'bob@example.com');

-- Insert data into Borrowing
INSERT INTO Borrowing (borrowing_id, member_id, book_id, borrow_date, status)
VALUES (1, 1, 101, SYSDATE, 'Borrowed');

INSERT INTO Borrowing (borrowing_id, member_id, book_id, borrow_date, status)
VALUES (2, 2, 102, SYSDATE, 'Borrowed');
SELECT * FROM Book;
-- **CRUD Operations**

-- Insert Operation: Add a new Book
SET SERVEROUTPUT ON;
DECLARE
    v_book_id NUMBER := 104;
    v_title VARCHAR2(100) := 'Clean Code';
    v_author VARCHAR2(100) := 'Robert C. Martin';
    v_publisher VARCHAR2(100) := 'Prentice Hall';
    v_year NUMBER := 2008;
    v_category_id NUMBER := 3;
    v_available_copies NUMBER := 6;
BEGIN
    INSERT INTO Book (book_id, title, author, publisher, year, category_id, available_copies)
    VALUES (v_book_id, v_title, v_author, v_publisher, v_year, v_category_id, v_available_copies);
    DBMS_OUTPUT.PUT_LINE('Book added successfully.');
END;

-- Update Operation: Update Available Copies
SET SERVEROUTPUT ON;
DECLARE
    v_book_id NUMBER := 101;
    v_copies NUMBER := 3;
BEGIN
    UPDATE Book
    SET available_copies = available_copies + v_copies
    WHERE book_id = v_book_id;
    DBMS_OUTPUT.PUT_LINE('Available copies updated successfully.');
END;


-- Delete borrowing records first
SET SERVEROUTPUT ON;
DECLARE
    v_member_id NUMBER := 2;
BEGIN
    DELETE FROM Borrowing
    WHERE member_id = v_member_id;

    DELETE FROM Member
    WHERE member_id = v_member_id;

    DBMS_OUTPUT.PUT_LINE('Member and related borrowings removed successfully.');
END;

-- Read Operation: Fetch Book Details
SET SERVEROUTPUT ON;
DECLARE
    v_book_id NUMBER := 101;
    v_title VARCHAR2(100);
    v_author VARCHAR2(100);
    v_available_copies NUMBER;
BEGIN
    SELECT title, author, available_copies
    INTO v_title, v_author, v_available_copies
    FROM Book
    WHERE book_id = v_book_id;
    DBMS_OUTPUT.PUT_LINE('Title: ' || v_title || ', Author: ' || v_author || ', Available Copies: ' || v_available_copies);
END;



-- Report: Borrowed Books
SET SERVEROUTPUT ON;
BEGIN
    FOR rec IN (SELECT Member.name, Book.title, Borrowing.borrow_date, Borrowing.return_date
                FROM Borrowing
                JOIN Member ON Borrowing.member_id = Member.member_id
                JOIN Book ON Borrowing.book_id = Book.book_id
                WHERE Borrowing.status = 'Borrowed') LOOP
        DBMS_OUTPUT.PUT_LINE('Member: ' || rec.name || ', Book: ' || rec.title || ', Borrow Date: ' || rec.borrow_date);
    END LOOP;
END;

-- Report: Available Books
SET SERVEROUTPUT ON;
BEGIN
    FOR rec IN (SELECT title, author, available_copies
                FROM Book
                WHERE available_copies > 0) LOOP
        DBMS_OUTPUT.PUT_LINE('Book: ' || rec.title || ', Author: ' || rec.author || ', Available Copies: ' || rec.available_copies);
    END LOOP;
END;

-- **Data Security**

-- Create Roles and Grant Privileges
-- Create Role: Librarian
CREATE ROLE C##Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO C##Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Member TO C##Librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Borrowing TO C##Librarian;

-- Create Role: LibraryAssistant
CREATE ROLE C##LibraryAssistant;
GRANT SELECT, INSERT, UPDATE ON Borrowing TO C##LibraryAssistant;
GRANT SELECT ON Book TO C##LibraryAssistant;
GRANT SELECT ON Member TO C##LibraryAssistant;

-- Create User: Akalanka (Librarian)
CREATE USER C##akalanka IDENTIFIED BY password;
GRANT C##Librarian TO C##akalanka ;

-- Create User: Bimsara (Library Assistant)
CREATE USER C##bimsara IDENTIFIED BY password;
GRANT C##LibraryAssistant TO C##bimsara;