-- how each driver age band compares with the portfolio as a whole. Same driv_age bands as q04.
-- relativity is the band's frequency divided by the portfolio frequency - 1.00 means the
-- band claims at exactly the portfolio rate.

WITH bands AS (SELECT CASE WHEN driv_age < 25 THEN '18-24' WHEN driv_age <=35 THEN '25-35'
WHEN driv_age <=44 THEN '36-44' WHEN driv_age <=55 THEN '45-55'
WHEN driv_age <=65 THEN '56-65' ELSE '66+' END AS age_groups, sum(claim_nb) AS sum_claim,
sum(exposure) AS sum_exposure, sum(sum(claim_nb)) OVER () /sum(sum(exposure)) OVER () AS total_frequency
FROM core.policy
GROUP BY 1
)
SELECT age_groups, rank() OVER(ORDER BY sum_claim/sum_exposure DESC) AS risk_rank,
round(total_frequency,4) AS portfolio_frequency,
round(sum_claim/sum_exposure, 4) AS segment_frequency, round((sum_claim/sum_exposure)/total_frequency, 4) AS relativity
FROM bands
ORDER BY risk_rank;