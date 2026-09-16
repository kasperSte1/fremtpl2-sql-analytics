-- audit of the raw layer, before any promotion to core

-- rows loaded: 678,013 policies (the OpenML page states 677,991), 26,639 claims
SELECT count(*) FROM raw.freq;
SELECT count(*) FROM raw.sev;


-- NULLs in any column of either table: none
SELECT count(*) FROM raw.freq f WHERE NOT (f IS NOT NULL);
SELECT count(*) FROM raw.sev s WHERE NOT (s IS NOT NULL);


-- key integrity
-- id_pol unique in the policy table: 678,013 rows, 678,013 distinct
SELECT count(id_pol), count(DISTINCT id_pol) FROM raw.freq;

-- claims pointing to a policy that does not exist: 195 rows, 6 distinct ids
SELECT count(*), count(DISTINCT s.id_pol)
FROM raw.sev s
LEFT JOIN raw.freq f
    ON s.id_pol = f.id_pol
WHERE f.id_pol IS NULL;


-- declared claim_nb against the actual number of claim rows
-- 9,117 policies disagree, every one of them declaring more claims than exist
WITH claims_per_policy AS (SELECT id_pol,
count(*) AS actual_claims
FROM raw.sev
GROUP BY id_pol
)
SELECT CASE WHEN f.claim_nb < COALESCE(c.actual_claims, 0)
THEN 'understated' ELSE 'overstated' END AS direction,
count(*)
FROM raw.freq f
LEFT JOIN claims_per_policy c
    ON f.id_pol = c.id_pol
WHERE f.claim_nb <> COALESCE(c.actual_claims, 0)
GROUP BY 1;

-- ranges checked before declaring the CHECK constraints
-- claim_nb min 0 | exposure 0.0027 to 2.01 | driv_age min 18 | claim_amount min 1
-- veh_gas: 'Diesel' (8 chars), 'Regular' (9 chars), apostrophes are part of the value
-- area: A through F
SELECT min(claim_nb) FROM raw.freq;
SELECT min(exposure), max(exposure) FROM raw.freq;
SELECT min(driv_age) FROM raw.freq;
SELECT min(claim_amount) FROM raw.sev;
SELECT DISTINCT veh_gas, length(veh_gas) FROM raw.freq;
SELECT DISTINCT area FROM raw.freq;


-- portfolio coverage, the baseline for the three queries below:
-- 26,444 of the 36,102 declared claims carry an amount = 0.733
SELECT sum(claim_nb) AS declared FROM raw.freq;

SELECT count(*) AS with_amount
FROM raw.sev s
INNER JOIN raw.freq f
    ON s.id_pol = f.id_pol;


-- coverage: what share of declared claims has an amount row, by region
-- 0.481 (R21) to 0.841 (R82) against a portfolio mean of 0.733.
-- spread_if_random is the sampling error expected if amounts went missing at random;
-- sd_from_portfolio is the gap measured in those units. R82 sits 17.4 of them above
-- the portfolio on 5,032 claims, so the missing amounts are not a random subset
WITH declared AS (SELECT region, sum(claim_nb) AS declared
FROM raw.freq
GROUP BY region),
with_amount AS (SELECT f.region, count(*) AS with_amount
FROM raw.sev s
INNER JOIN raw.freq f
    ON s.id_pol = f.id_pol
GROUP BY f.region
)
SELECT d.region, d.declared, w.with_amount,
round(w.with_amount::numeric/ d.declared, 3) AS coverage,
round(sqrt(0.733 * (1 - 0.733) / d.declared), 4) AS spread_if_random,
round((w.with_amount::numeric / d.declared - 0.733) / sqrt(0.733 * (1 - 0.733) / d.declared), 2) AS sd_from_portfolio
FROM declared d
INNER JOIN with_amount w
    ON d.region = w.region
ORDER BY coverage;


-- the same by driver age band. Columns as above.
-- Falls monotonically from 0.851 (18-24) to 0.624 (66+), sd_from_portfolio from
-- +12.9 to -15.9 - the trend runs with age, not with sample size
WITH declared AS ( SELECT CASE WHEN driv_age <= 24 THEN '18-24'
WHEN driv_age <= 35 THEN '25-35'
WHEN driv_age <= 44 THEN '36-44'
WHEN driv_age <= 55 THEN '45-55'
WHEN driv_age <= 65 THEN '56-65'
ELSE '66+' END AS age_band,
sum(claim_nb) AS declared
FROM raw.freq
GROUP BY 1
),
with_amount AS (SELECT CASE WHEN f.driv_age <= 24 THEN '18-24'
WHEN f.driv_age <= 35 THEN '25-35'
WHEN f.driv_age <= 44 THEN '36-44'
WHEN f.driv_age <= 55 THEN '45-55'
WHEN f.driv_age <= 65 THEN '56-65'
ELSE '66+' END AS age_band,
count(*) AS with_amount
FROM raw.sev s
INNER JOIN raw.freq f
    ON s.id_pol = f.id_pol
GROUP BY 1
)
SELECT d.age_band, d.declared, w.with_amount,
round(w.with_amount::numeric / d.declared, 3) AS coverage,
round(sqrt(0.733 *(1-0.733)/d.declared), 4) AS spread_if_random,
round((w.with_amount::numeric / d.declared - 0.733) / sqrt(0.733 * (1 - 0.733) / d.declared), 2) AS sd_from_portfolio
FROM declared d
INNER JOIN with_amount w
    ON d.age_band = w.age_band
ORDER BY d.age_band;


-- does the gap sit in policies with several claims?
-- No. The two groups that carry the data, claim_nb 1 and 2, hold 35,746 of the 36,102
-- declared claims and sit 0.21 and 0.69 standard errors from the portfolio mean of 0.733.
-- A severity file recording only the first claim per policy would push coverage down as
-- claim_nb rises; it does not
WITH declared AS (SELECT claim_nb, sum(claim_nb) AS declared
FROM raw.freq
WHERE claim_nb > 0
GROUP BY claim_nb
),
with_amount AS (SELECT f.claim_nb, count(*) AS with_amount
FROM raw.sev s
INNER JOIN raw.freq f
    ON s.id_pol = f.id_pol
GROUP BY f.claim_nb
)
SELECT d.claim_nb, d.declared, w.with_amount,
round(w.with_amount::numeric / d.declared, 3) AS coverage,
round(sqrt(0.733 *(1-0.733)/d.declared), 4) AS spread_if_random,
round((w.with_amount::numeric / d.declared - 0.733) / sqrt(0.733 * (1 - 0.733) / d.declared), 2) AS sd_from_portfolio
FROM declared d
INNER JOIN with_amount w
    ON d.claim_nb = w.claim_nb
ORDER BY d.claim_nb;


-- tails of the two age columns: 99 is a sentinel value in both
-- driv_age: 70 policies at 99, against 5 at 98 and 3 at 100
-- veh_age: 48 policies at 99-100, with nothing between 86 and 98
SELECT driv_age, count(*)
FROM raw.freq
WHERE driv_age > 85
GROUP BY 1
ORDER BY 1 DESC;

SELECT veh_age, count(*)
FROM raw.freq
WHERE veh_age > 30
GROUP BY 1
ORDER BY 1 DESC;