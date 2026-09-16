-- Each claim matches exactly one policy, so the join cannot duplicate claims: 26,444 rows
-- in, 26,444 out. Policies with several claims do repeat, and their exposure repeats with
-- them - but nothing from the policy table is summed here, which is what separates this
-- from the fan-out in q02.
-- Every figure covers only the claims that carry an amount: 73% of those declared, and the
-- share varies by band. See the coverage checks in 03_audit.sql.

-- portfolio as a whole
SELECT count(*) AS claim_count,
round(avg(claim_amount), 2) AS avg_claim,
round(percentile_cont(0.5) WITHIN GROUP (ORDER BY claim_amount)::numeric, 2) AS median_claim,
round(percentile_cont(0.9) WITHIN GROUP (ORDER BY claim_amount)::numeric, 2) AS p90,
round(percentile_cont(0.99) WITHIN GROUP (ORDER BY claim_amount)::numeric, 2) AS p99,
max(claim_amount) AS max_claim_amount
FROM core.claim;


SELECT CASE WHEN p.driv_age < 25 THEN '18-24' WHEN p.driv_age <=35 THEN '25-35'
WHEN p.driv_age <=44 THEN '36-44' WHEN p.driv_age <=55 THEN '45-55'
WHEN p.driv_age <=65 THEN '56-65' ELSE '66+' END AS age_groups,
count(*) AS claim_count,
sum(c.claim_amount) AS sum_claim_amount,
max(c.claim_amount) AS max_claim_amount,
round((sum(c.claim_amount) - max(c.claim_amount))/(count(*)-1),2) AS avg_excl_largest,
round(max(c.claim_amount)*100/sum(c.claim_amount), 2) AS pct_from_largest,
round(100 * count(*)::numeric / sum(count(*)) OVER (), 1) AS pct_of_claims,
round(100 * sum(c.claim_amount) / sum(sum(c.claim_amount)) OVER (), 1) AS pct_of_total_cost,
round(avg(c.claim_amount), 2) AS avg_claim,
round(percentile_cont(0.5) WITHIN GROUP (ORDER BY c.claim_amount)::numeric, 2) AS median_claim,
round(percentile_cont(0.9) WITHIN GROUP (ORDER BY c.claim_amount)::numeric, 2) AS p90,
round(percentile_cont(0.99) WITHIN GROUP (ORDER BY c.claim_amount)::numeric, 2) AS p99
FROM core.claim c
INNER JOIN core.policy p
	ON c.id_pol = p.id_pol
GROUP BY 1
ORDER BY min(p.driv_age);
