-- claim frequency by region, reported only where the frequency is measured to better than
-- 5% relative error. The relative error of a count is 100/sqrt(N), so the threshold is
-- 400 claims; it is a chosen precision floor, not a result, and it removes 7 of 22 regions.

SELECT region, round(sum(exposure), 4) AS sum_exposure, sum(claim_nb) AS sum_claim,
round(sum(claim_nb)/sum(exposure), 4) AS claim_frequency,
round(100/sqrt(sum(claim_nb))::numeric, 2) AS rel_error_pct
FROM core.policy
GROUP BY region
HAVING 100/sqrt(sum(claim_nb)) < 5
ORDER BY claim_frequency DESC;
