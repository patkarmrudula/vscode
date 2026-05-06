CREATE TABLE test_table (
    RecordNumber INTEGER,
    CurrentDate DATE
);

CREATE OR REPLACE PROCEDURE insert_test_table()
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO test_table VALUES (i, CURRENT_DATE);
    END LOOP;
END;
$$;

CALL insert_test_table();

SELECT * FROM test_table;


CREATE TABLE products (
    productid INTEGER,
    category CHAR(3),
    detail VARCHAR(30),
    price NUMERIC(10,2),
    stock INTEGER
);

INSERT INTO products VALUES
(1001, 'ELC', 'Mobile Phone', 15000, 10),
(1002, 'ELC', 'Laptop', 50000, 5),
(1003, 'FUR', 'Chair', 3000, 20),
(1004, 'FUR', 'Table', 7000, 15);

CREATE OR REPLACE PROCEDURE update_price(x NUMERIC, y CHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products
    SET price = price + (price * x / 100)
    WHERE category = y;
END;
$$;

CALL update_price(10, 'ELC');

SELECT * FROM products;

CREATE TYPE name_type AS (
    name VARCHAR(50)
);

CREATE OR REPLACE FUNCTION countNoOfWords(n TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN length(trim(n)) - length(replace(trim(n), ' ', '')) + 1;
END;
$$;

CREATE TABLE name_table (
    data name_type
);
INSERT INTO name_table VALUES (ROW('Advanced Database System'));
INSERT INTO name_table VALUES (ROW('Computer Algorithms'));

SELECT 
    (data).name,
    countNoOfWords((data).name) AS word_count
FROM name_table;



CREATE TYPE address_type AS (
    address VARCHAR,
    city VARCHAR,
    state VARCHAR,
    pincode INTEGER
);

CREATE TABLE address_table (
    addr address_type
);

INSERT INTO address_table VALUES
(ROW('MG Road Near Central Mall', 'Pune', 'Maharashtra', 411001)),
(ROW('Station Road', 'Mumbai', 'Maharashtra', 400001)),
(ROW('Ring Road Sector 5', 'Delhi', 'Delhi', 110001));


CREATE OR REPLACE FUNCTION extract_address_by_keyword(k TEXT)
RETURNS TABLE(address VARCHAR, city VARCHAR, state VARCHAR, pincode INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        (addr).address,
        (addr).city,
        (addr).state,
        (addr).pincode
    FROM address_table
    WHERE (addr).address ILIKE '%' || k || '%';
END;
$$;


SELECT * FROM extract_address_by_keyword('Road');


CREATE OR REPLACE FUNCTION count_words_in_field(
    a address_type,
    field_name TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    txt TEXT;
BEGIN
    IF field_name = 'address' THEN
        txt := a.address;
    ELSIF field_name = 'city' THEN
        txt := a.city;
    ELSIF field_name = 'state' THEN
        txt := a.state;
    ELSE
        RETURN 0;
    END IF;

    RETURN length(trim(txt)) - length(replace(trim(txt), ' ', '')) + 1;
END;
$$;

SELECT
    (addr).address,
    count_words_in_field(addr, 'address') AS address_words,
    count_words_in_field(addr, 'city') AS city_words
FROM address_table;

CREATE TYPE course_type AS (
    course_id INTEGER,
    description VARCHAR(50)
);

CREATE TABLE course_table (
    course course_type
);

INSERT INTO course_table VALUES
(ROW(1, 'Computer Networks')),
(ROW(2, 'Advanced Database System')),
(ROW(3, 'Artificial Intelligence')),
(ROW(4, 'Machine Learning'));

SELECT * FROM course_table;


SELECT
    (course).course_id,
    (course).description
FROM course_table;








