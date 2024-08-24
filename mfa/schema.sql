DROP TABLE IF EXISTS "artists";
DROP TABLE IF EXISTS "created";
DROP TABLE IF EXISTS "collections";

CREATE TABLE IF NOT EXISTS "artists" (
    "id" INTEGER,
    "name" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "collections" (
    "id" INTEGER, 
    "title" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE IF NOT EXISTS "created" (
    "artist_id" INTEGER,
    "collection_id" INTEGER,
    PRIMARY KEY("artist_id", "collection_id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE,
    FOREIGN KEY("collection_id") REFERENCES "collections"("id") ON DELETE CASCADE 
);

--insert artists
INSERT INTO "artists" ("name") VALUES
('Li Yin'),
('Qian Weicheng'),
('Unidentified artist'),
('Zhou Chen') RETURNING "id" AS "artist id";

--query artists
SELECT "name" AS "artist name" FROM "artists";

--insert collections
INSERT INTO "collections" ("title") VALUES 
('Farmers working at dawn'),
('Imaginative landscape'),
('Profusion of flowers'),
('Spring outing'),
('Peonies and bufferfly') RETURNING "id" AS "collection id";

--query collections
SELECT "title" AS "collection title" FROM "collections";

--add relations between artists and collections
INSERT INTO "created" ("artist_id", "collection_id") 
VALUES
((SELECT "id" FROM "artists" WHERE "name"  = 'Li Yin'), (SELECT "id" FROM "collections" WHERE "title" = 'Imaginative landscape')),
((SELECT "id" FROM "artists" WHERE "name" = 'Qian Weicheng'), (SELECT "id" FROM "collections" WHERE "title" = 'Profusion of flowers')),
((SELECT "id" FROM "artists" WHERE "name" = 'Unidentified artist'), (SELECT "id" FROM "collections" WHERE "title" = 'Farmers working at dawn')),
((SELECT "id" FROM "artists" WHERE "name" = 'Zhou Chen'), (SELECT "id" FROM "collections" WHERE "title" = 'Spring outing'));

--query created table
SELECT "artists"."name" AS "artist name", "collections"."title" AS "collection title" FROM "created"
JOIN "artists" ON "artist_id" = "artists"."id"
JOIN "collections" ON "collection_id" = "collections"."id";

--delete a single row where an artist is equal to 'Unidentified artist'
DELETE FROM "created" WHERE "artist_id" = (
    SELECT "id" FROM "artists" WHERE "name" = 'Unidentified artist' 
);

--select create ones again
SELECT "artists"."name" AS "artist name", "collections"."title" AS "collection title" FROM "created"
JOIN "artists" ON "artist_id" = "artists"."id"
JOIN "collections" ON "collection_id" = "collections"."id";

--updating the table
UPDATE "created" SET "artist_id" = (
    SELECT "id"
    FROM "artists"
    WHERE "name" = 'Li Yin'
)
WHERE "collection_id" = (
    SELECT "id"
    FROM "collections"
    WHERE "title" = 'Spring outing'
);

--query the updated `created` table
SELECT "name" AS "artist name", "title" AS "collection title" FROM "created"
JOIN "artists" ON "artist_id" = "artists"."id"
JOIN "collections" ON "collection_id" = "collections"."id";
