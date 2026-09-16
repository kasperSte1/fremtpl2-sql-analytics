-- raw -> core: strips the apostrophes from veh_gas, loads claims whose id_pol exists
-- in core.policy, and sends the rest to core.claim_quarantine.

BEGIN;
TRUNCATE core.claim, core.claim_quarantine, core.policy;

INSERT INTO core.policy (id_pol, claim_nb, exposure, veh_power, veh_age,
driv_age, bonus_malus, veh_brand, veh_gas, area, density, region)
SELECT id_pol, claim_nb, exposure, veh_power, veh_age,
driv_age, bonus_malus, veh_brand,
TRIM(BOTH $$'$$ FROM veh_gas) AS veh_gas, area, density, region FROM raw.freq;

INSERT INTO core.claim (id_pol, claim_amount)
SELECT s.id_pol, s.claim_amount
FROM raw.sev s
INNER JOIN core.policy p
    ON s.id_pol = p.id_pol;

INSERT INTO core.claim_quarantine (id_pol, claim_amount, reject_reason)
SELECT s.id_pol, s.claim_amount, 'policy not found'
FROM raw.sev s
LEFT JOIN core.policy p
	ON s.id_pol = p.id_pol
WHERE p.id_pol IS NULL;

COMMIT;