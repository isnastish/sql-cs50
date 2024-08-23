--drop passangers table
DROP TABLE IF EXISTS "passangers";

--create passangers table
CREATE TABLE IF NOT EXISTS "passangers" (
    "id" INTEGER, 
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "age" INTEGER,
    PRIMARY KEY("id")
);

--drop table check-ins
DROP TABLE IF EXISTS "checkins";

--create check-ins table
CREATE TABLE IF NOT EXISTS "checkins" (
    "id" INTEGER,
    "passanger_id" INTEGER,
    "flight_id" INTEGER, 
    "datetime" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("flight_id") REFERENCES "flights"("id") ON DELETE CASCADE,
    FOREIGN KEY("passanger_id") REFERENCES "passangers"("id") ON DELETE CASCADE
);

--drop airline names table
DROP TABLE IF EXISTS "airline_names";

--create a table for airline names to remove duplications
CREATE TABLE IF NOT EXISTS "airline_names" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

--drop airlines table
DROP TABLE IF EXISTS "airlines";

--create airlines table
CREATE TABLE IF NOT EXISTS "airlines" (
    "id" INTEGER,
    "name_id" INTEGER,
    "concourse" TEXT NOT NULL CHECK("concourse" IN ('A', 'B', 'C', 'D', 'E', 'F', 'T')),
    PRIMARY KEY("id"),
    FOREIGN KEY("name_id") REFERENCES "airline_names"("id") ON DELETE CASCADE
);

--drop flights table
DROP TABLE IF EXISTS "flights";

--create flights table
CREATE TABLE IF NOT EXISTS "flights" (
    "id" INTEGER,
    "number" INTEGER NOT NULL UNIQUE,
    "airline_id" INTEGER,
    "src_airport" VARCHAR(16) NOT NULL,
    "dest_airport" VARCHAR(16) NOT NULL,
    "departure_time" NUMERIC NOT NULL,
    "arrival_time" NUMERIC NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("airline_id") REFERENCES "airlines"("id") ON DELETE CASCADE 
);

--insert passanger
INSERT INTO "passangers" ("first_name", "last_name", "age") VALUES ('Amelia', 'Earhart', 39);

--select all passangers
SELECT * FROM "passangers";

--add an airline, Delta, which operates out of concourses A, B, C, D, and T
--there is definitely a redundancy here, we duplicate Delta airline name multiple times
--we should normalize the table
INSERT INTO "airline_names" ("name") VALUES ('Delta') RETURNING "id" as "Delta airline id";
INSERT INTO "airlines" ("name_id", "concourse") 
VALUES (1, 'A'), (1, 'B'), (1, 'C'), (1, 'D'), (1, 'T');

--select all data from airlines
SELECT * FROM "airlines";

--add a flight
INSERT INTO "flights" ("number", "airline_id", "src_airport", "dest_airport", "departure_time", "arrival_time")
VALUES
(300, 1, 'ATL', 'BOS', '2023-08-03 06:46 PM', '2023-08-03 09:09 PM');

--select from table
SELECT "number", "name" AS "airline name", "src_airport", "dest_airport", "departure_time" AS "depart time", "arrival_time" FROM "flights"
JOIN "airlines" ON "airline_id" = "airlines"."id"
JOIN "airline_names" ON "airlines"."name_id" = "airline_names"."id"
GROUP BY "airline name";

--add a check-in info
INSERT INTO "checkins" ("passanger_id", "flight_id", "datetime") 
VALUES (1, 1, '2023-08-03 03:03 PM');

--select checkins by joining two tables
SELECT "datetime", "first_name", "last_name", "src_airport", "dest_airport" FROM "checkins" 
JOIN "passangers" ON "checkins"."passanger_id" = "passangers"."id"
JOIN "flights" ON "checkins"."flight_id" =  "flights"."id";
