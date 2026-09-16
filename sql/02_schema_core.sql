-- core layer: validated data with keys, types and CHECK constraints enforced.

CREATE SCHEMA IF NOT EXISTS core;

DROP TABLE IF EXISTS core.claim;
DROP TABLE IF EXISTS core.policy;
DROP TABLE IF EXISTS core.claim_quarantine;

CREATE TABLE core.policy (
    id_pol INTEGER PRIMARY KEY,
    claim_nb INTEGER NOT NULL CHECK (claim_nb >= 0),
    exposure NUMERIC NOT NULL CHECK (exposure > 0),
    veh_power SMALLINT NOT NULL,
    veh_age SMALLINT NOT NULL,
    driv_age SMALLINT NOT NULL CHECK (driv_age >= 18),
    bonus_malus SMALLINT NOT NULL,
    veh_brand TEXT NOT NULL,
    veh_gas TEXT NOT NULL CHECK (veh_gas IN ('Regular', 'Diesel')),
    area TEXT NOT NULL CHECK (area IN ('A', 'B', 'C', 'D', 'E', 'F')),
    density INTEGER NOT NULL,
    region TEXT NOT NULL
);

CREATE TABLE core.claim (
    claim_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pol INTEGER NOT NULL REFERENCES core.policy(id_pol),
    claim_amount NUMERIC(12,2) NOT NULL CHECK (claim_amount>0)
);

CREATE TABLE core.claim_quarantine (
    id_pol INTEGER,
    claim_amount NUMERIC(12,2),
    reject_reason TEXT NOT NULL,
    loaded_at TIMESTAMPTZ NOT NULL DEFAULT now()
);