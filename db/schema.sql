-- schema.sql
-- Table name is quoted ("Plant") to match the queries in the API,
-- which reference it with a capital P.

CREATE TABLE IF NOT EXISTS "Plant" (
    id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    height_cm INTEGER      NOT NULL,

    CONSTRAINT plant_name_not_empty CHECK (char_length(name) >= 1),
    CONSTRAINT plant_height_range   CHECK (height_cm BETWEEN 0 AND 1000000)
);

TRUNCATE TABLE "Plant" RESTART IDENTITY;

INSERT INTO "Plant" (name, height_cm) VALUES
    ('Monstera Deliciosa',   150),
    ('Snake Plant',           90),
    ('Fiddle Leaf Fig',      180),
    ('Aloe Vera',             40),
    ('Spider Plant',          30),
    ('Peace Lily',            60),
    ('Rubber Plant',         200),
    ('Pothos',               120),
    ('Jade Plant',            50),
    ('ZZ Plant',              75),
    ('Cactus (Saguaro)',     600),
    ('Giant Sequoia',     8000000 / 100),  -- 80,000 cm
    ('Seedling',               0),         -- boundary: min height
    ('Redwood',          1000000);         -- boundary: max height