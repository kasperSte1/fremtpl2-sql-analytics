-- claim frequency by driver age band, with the relative standard error of each band's
-- claim count. Bands are fixed in advance for readability, not cut from the distribution;
-- unlike the vehicle bands in q05, no percentile query stands behind them.

SELECT CASE WHEN driv_age < 25 THEN '18-24' WHEN driv_age <=35 THEN '25-35'
WHEN driv_age <=44 THEN '36-44' WHEN driv_age <=55 THEN '45-55'
WHEN driv_age <=65 THEN '56-65' ELSE '66+' END AS age_groups,
round(sum(exposure), 4) AS sum_exposure, sum(claim_nb) AS sum_claim,
round((sum(claim_nb)/sum(exposure)), 4) AS claim_freq,
round(100/sqrt(sum(claim_nb))::numeric, 2) AS standard_error_percent
FROM core.policy
GROUP BY 1
ORDER BY min(driv_age);