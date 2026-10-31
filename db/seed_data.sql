-- seed_data.sql
-- Test data. Safe to re-run: clears the table and resets ids to start at 1.

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