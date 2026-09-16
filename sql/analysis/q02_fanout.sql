-- the fan-out trap: a policy with k claims produces k rows after the join, so aggregating
-- afterwards counts rows instead of claims and sums the same exposure k times. Measured
-- here: 0.1007 the correct way against 1.8901 the naive one, an 18.8x overstatement.
-- This is why frequency everywhere in this repository comes from core.policy alone.

WITH claim_frequency AS (SELECT sum(exposure) AS sum_exposure,
sum(claim_nb) AS sum_claim_nb FROM core.policy
),
claim_frequency_naive AS (SELECT count(*) AS joined_rows,
sum(p.exposure) AS sum_exposure FROM core.policy p
LEFT JOIN core.claim c
    ON p.id_pol = c.id_pol
)
SELECT round(cf.sum_claim_nb / cf.sum_exposure, 4) AS freq_correct,
round(cfn.joined_rows / cfn.sum_exposure, 4) AS freq_naive
FROM claim_frequency cf
CROSS JOIN claim_frequency_naive cfn;
