--drop ingredients table
DROP TABLE IF EXISTS "ingredients";

--create ingredients table
CREATE TABLE IF NOT EXISTS "ingredients" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "price_per_pound" REAL NOT NULL CHECK("price_per_pound" > 0.0),
    PRIMARY KEY("id")
);

--drop donuts table
DROP TABLE IF EXISTS "donuts";

--create donuts table
CREATE TABLE IF NOT EXISTS "donuts" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    "gluten_free" BOOLEAN NOT NULL CHECK("gluten_free" IN (0, 1)),
    "price" REAL NOT NULL CHECK("price" > 0.0),
    PRIMARY KEY("id")
);

--drop donut ingredients table
DROP TABLE IF EXISTS "donut_ingredients";

--create table donut ingredients
CREATE TABLE IF NOT EXISTS "donut_ingredients" (
    "id" INTEGER, --do we really need an id?
    "donut_id" INTEGER,
    "ingredient_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("donut_id") REFERENCES "donuts"("id") ON DELETE CASCADE,
    FOREIGN KEY("ingredient_id") REFERENCES "ingredients"("id") ON DELETE CASCADE
);

--drop orders table
DROP TABLE IF EXISTS "orders";

--NOTE: Orders table could be broken down into separate, smaller sub-tables
--create orders table
CREATE TABLE IF NOT EXISTS "orders" (
    "id" INTEGER,
    "number" INTEGER NOT NULL, --we could GROUP BY number to get the number of donuts in the order
    "donut_id" INTEGER,
    "count" INTEGER NOT NULL CHECK("count" > 0), --number of donuts of the same name that a customer ordered
    "customer_id" INTEGER, --customer who placed an order
    FOREIGN KEY("donut_id") REFERENCES "donuts"("id") ON DELETE CASCADE, 
    FOREIGN KEY("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE
);

--drop customers table
DROP TABLE IF EXISTS "customers";

--create customers table
CREATE TABLE IF NOT EXISTS "customers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

--drop customer orders table
DROP TABLE IF EXISTS "customer_orders";

--create customer orders table
CREATE TABLE IF NOT EXISTS "customer_orders" (
    "customer_id" INTEGER,
    "order_id" INTEGER, --each customer could have 0 or more orders, each order could have only one customer
    FOREIGN KEY("customer_id") REFERENCES "customers"("id") ON DELETE CASCADE,
    FOREIGN KEY("order_id") REFERENCES "orders"("id") ON DELETE CASCADE
);

/**********************************************************************************
*Populate database with a sample data
***********************************************************************************/
--insert ingredients
INSERT INTO "ingredients" ("name", "price_per_pound")
VALUES
('Cocoa', 5.0),
('Sugar', 2.0),
('Flour', 1.0),
('Buttermilk', 3.5),
('Sugar', 0.75),
('Sprinkles', 0.25)
RETURNING "id" AS "ingredient id";

--query ingredients table
SELECT "name" AS "ingredient", "price_per_pound" FROM "ingredients";

--insert donut into donuts table
INSERT INTO "donuts" ("name", "gluten_free", "price")
VALUES 
('Belgian Dark Chocolate', 0, 4.0), 
('Back-To-School Sprinkles', 0, 4.0) RETURNING "id" AS "donut id";

--insert into donut ingredients table all the ingredients
INSERT INTO "donut_ingredients" ("donut_id", "ingredient_id")
VALUES 
(1, 1), --Cocoa
(1, 3), --Flour
(1, 4), --Buttermilk
(1, 5), --Sugar
(2, 3),
(2, 4), 
(2, 5), 
(2, 6); --sprinkles 

--query ingredients from donut ingredients table for 'Belgian Dark Chocolate' donut
SELECT "ingredients"."name" AS "ingredient name", "donuts"."name" AS "donut name", "price_per_pound" AS "price per pound"
FROM "donut_ingredients"
JOIN "ingredients" ON "ingredient_id" = "ingredients"."id"
JOIN "donuts" ON "donut_id" = "donuts"."id"
WHERE "donuts"."name" = 'Belgian Dark Chocolate'
ORDER BY "price per pound" DESC;

--add a customer without order history
INSERT INTO "customers" ("first_name", "last_name") 
VALUES ('Luis', 'Singh');

--select all customers
SELECT * FROM "customers";

--insert an order into orders table, and insert an order into customer_orders
INSERT INTO "orders" ("number", "donut_id", "count", "customer_id")
VALUES
(1, 1, 3, 1), -- 3 Belgian Dark Chocolate, Luis Singh
(1, 2, 2, 1); -- 2 Back-To-School Sprinkles

INSERT INTO "customer_orders" ("customer_id", "order_id") VALUES (1, 1);

--select from orders, who ordered, how many donuts and what kind
SELECT "first_name", "last_name", "number", "donuts"."name" AS "donut name", 
"price", "count" AS "donut count", 
"gluten_free" 
FROM "orders"
JOIN "donuts" ON "donut_id" = "donuts"."id"
JOIN "customers" ON "customer_id" = "customers"."id";

--select total price payed for the order, and the total amount of donuts, and who made the order
SELECT "number" AS "order number", "first_name", "last_name", SUM("count") AS "total donats", 
SUM("count" * "price") AS "total price" 
FROM "orders"
JOIN "donuts" ON "donut_id" = "donuts"."id"
JOIN "customers" ON "customer_id" = "customers"."id"
GROUP BY "number";

--select all the orders that Luis Singh made
SELECT "first_name", "last_name", "order_id" FROM "customer_orders"
JOIN "customers" ON "customer_orders"."customer_id" = "customers"."id"
JOIN "orders" ON "order_id" = "orders"."number"
GROUP BY "number";
