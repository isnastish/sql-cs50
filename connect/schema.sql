--drop users table
DROP TABLE IF EXISTS "users";

--create users table
CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL, 
    "last_name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE, --username has to be unique
    "password" TEXT NOT NULL, --hashing is disabled for simplicity CHECK(length("password") = 64)
    PRIMARY KEY("id")
);

--drop affiliations table
DROP TABLE IF EXISTS "schools";

--create affiliations table
CREATE TABLE IF NOT EXISTS "schools" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "location" TEXT NOT NULL,
    "founded_year" INTEGER NOT NULL, 
    PRIMARY KEY("id")
);

--drop companies table
DROP TABLE IF EXISTS "companies";

--create companies table
CREATE TABLE IF NOT EXISTS "companies" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "industry" VARCHAR(64) NOT NULL,
    "location" TEXT NOT NULL,
    PRIMARY KEY("id")
);

--drop connections table
DROP TABLE IF EXISTS "pupils_connections";

--create connections table
--NOTE: If user_a is following user_b, it means that user_b is following user_a as well, 
--they have mutual connection
CREATE TABLE IF NOT EXISTS "pupils_connections" (
    "connection_a_id" INTEGER,
    "connection_b_id" INTEGER,
    FOREIGN KEY("connection_a_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY("connection_b_id") REFERENCES "users"("id") ON DELETE CASCADE
);

--drop school connections table
DROP TABLE IF EXISTS "school_connections";

--create school connections table
--do we need a connection id? Probably not
CREATE TABLE IF NOT EXISTS "school_connections" (
    "user_id" INTEGER, --users can connections with 0 or more schools
    "school_id" INTEGER, --a school can have connection with 0 or more users
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC NOT NULL,
    "degree" TEXT NOT NULL,
    FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY("school_id") REFERENCES "schools"("id") ON DELETE CASCADE
);

--drop companies connection table
DROP TABLE IF EXISTS "company_connections";

--create company_connections table
CREATE TABLE IF NOT EXISTS "company_connections" (
    "user_id" INTEGER,
    "company_id" INTEGER,
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC NOT NULL,
    "title" TEXT NOT NULL,
    FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY("company_id") REFERENCES "companies"("id") ON DELETE CASCADE
);

/***********************************************************************************
*Testing the database
************************************************************************************/
--insert into users table
INSERT INTO "users" ("first_name", "last_name", "username", "password") 
VALUES 
('Alan', 'Garber', 'alan', 'alan@1234__'), 
('Reid', 'Hoffman', 'reid', 'reid1999@reid') RETURNING "id" AS "user id";

--query all users
SELECT "first_name", "last_name", "username", "password" 
FROM "users"; 

--insert into schools table
INSERT INTO "schools" ("name", "location", "founded_year")
VALUES ('Harvard University', 'Cambridge, Massachusetts', 1636) RETURNING "id" AS "schoold id";

--select all schools
SELECT "name" AS "school name", "location", "founded_year"
FROM "schools";

--insert a company
INSERT INTO "companies" ("name", "industry", "location")
VALUES ('LinkedIn', 'software company', 'Sunnyvale, California') RETURNING "id" AS "company id";

--query companies
SELECT "name", "industry", "location" FROM "companies";

--insert a connection (user attended a school, and a shool had an alumni in the past)
INSERT INTO "school_connections" ("user_id", "school_id", "start_date", "end_date", "degree")
VALUES 
(
    (SELECT "id" FROM "users" WHERE "first_name" = 'Alan' AND "last_name" = 'Garber'), 
    (SELECT "id" FROM "schools" WHERE "name" = 'Harvard University'),
    '1973-09-01',
    '1976-06-01',
    'undegraduate eduaction at Harvard'
);

--query school connections table
SELECT "first_name", "last_name", "username", "name" AS "school name", "location" AS "school location",
"degree", "start_date" AS "started", "end_date" AS "completed"
FROM "school_connections"
JOIN "schools" ON "school_id" = "schools"."id"
JOIN "users" ON "user_id" = "users"."id"
ORDER BY "start_date" ASC, "first_name" ASC, "last_name" ASC;

--add employment info
INSERT INTO "company_connections" ("user_id", "company_id", "start_date", "end_date", "title")
VALUES 
(
    (SELECT "id" FROM "users" WHERE "first_name" = 'Reid' AND "last_name" = 'Hoffman'),
    (SELECT "id" FROM "companies" WHERE "name" = 'LinkedIn'),
    '2003-01-01', 
    '2007-02-01', 
    'CEO and Chairman'
);

--query company connections
SELECT "name" AS "company name", "industry", "first_name", "last_name", 
"title", "start_date" AS "started", "end_date" AS "resigned" 
FROM "company_connections"
JOIN "users" ON "user_id" = "users"."id"
JOIN "companies" ON "company_id" = "companies"."id"
ORDER BY "start_date" ASC, "first_name" ASC, "last_name" ASC;
