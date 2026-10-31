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