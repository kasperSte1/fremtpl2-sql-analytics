-- claim frequency by vehicle age and engine power. The one-dimensional breakdowns are
-- kept alongside the grid because power looks flat on its own and reverses direction
-- inside it; the pair is the point, not either table separately.

-- Percentiles measured before the bands, so the cut points follow the data.

-- veh_power: quartiles 5 and 7, median 6, 95th 11, 99th 13. The code is massed at the
-- low end, so quartile bands would span two values each; the cut is at the median and
-- the 95th instead, leaving 12-15 thin on purpose.
SELECT percentile_cont(ARRAY[0.25, 0.5, 0.75, 0.95, 0.99]) WITHIN GROUP (ORDER BY veh_power) FROM core.policy;

-- veh_age: quartiles 2, 6 and 11 - the bands below are the bottom quarter, the middle
-- half and the top quarter.
SELECT percentile_cont(ARRAY[0.25, 0.5, 0.75]) WITHIN GROUP (ORDER BY veh_age) FROM core.policy;

SELECT CASE WHEN veh_age <= 2 THEN '0-2' WHEN veh_age <= 11 THEN '3-11' ELSE '12+' END AS veh_age_band,
sum(claim_nb) AS sum_claim, round(sum(exposure), 4) AS sum_exposure,
round(sum(claim_nb)/sum(exposure), 4) AS claim_frequency,
round(100/sqrt(sum(claim_nb))::numeric, 2) AS standard_error_percent
FROM core.policy
GROUP BY 1
ORDER BY min(veh_age);

SELECT CASE WHEN veh_power <= 6 THEN '4-6' WHEN veh_power <= 11 THEN '7-11' ELSE '12-15' END AS veh_power_band,
sum(claim_nb) AS sum_claim, round(sum(exposure), 4) AS sum_exposure,
round(sum(claim_nb)/sum(exposure), 4) AS claim_frequency,
round(100/sqrt(sum(claim_nb))::numeric, 2) AS standard_error_percent
FROM core.policy
GROUP BY 1
ORDER BY min(veh_power);

SELECT CASE WHEN veh_age <= 2 THEN '0-2' WHEN veh_age <= 11 THEN '3-11' ELSE '12+' END AS veh_age_band,
CASE WHEN veh_power <= 6 THEN '4-6' WHEN veh_power <= 11 THEN '7-11' ELSE '12-15' END AS veh_power_band,
sum(claim_nb) AS sum_claim, round(sum(exposure), 4) AS sum_exposure,
round((sum(claim_nb)/sum(exposure)), 4) AS claim_frequency,
round(100/sqrt(sum(claim_nb))::numeric, 2) AS standard_error_percent
FROM core.policy
GROUP BY 1, 2
ORDER BY min(veh_age), min(veh_power);