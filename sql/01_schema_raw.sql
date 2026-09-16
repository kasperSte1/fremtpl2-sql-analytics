-- raw landing zone for the freMTPL2 CSV files: no keys, no NOT NULL, no CHECK.

CREATE SCHEMA IF NOT EXISTS raw;

DROP TABLE IF EXISTS raw.freq;

CREATE TABLE raw.freq (
    id_pol      INTEGER,
    claim_nb    INTEGER, -- number of claims declared on the policy
    exposure    NUMERIC, -- fraction of a year the policy was active
    veh_power   SMALLINT,
    veh_age     SMALLINT,
    driv_age    SMALLINT,
    bonus_malus SMALLINT, -- <100 = discount, >100 = surcharge
    veh_brand   TEXT,
    veh_gas     TEXT,
    area        TEXT, -- density band from A to F
    density     INTEGER, -- inhabitants per km2
    region      TEXT
);

DROP TABLE IF EXISTS raw.sev;

CREATE TABLE raw.sev (
    id_pol       INTEGER,
    claim_amount NUMERIC(12,2)
);
