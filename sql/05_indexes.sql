-- indexes on the columns the analytical queries join and filter on.
-- core.claim.id_pol carries the foreign key, which PostgreSQL does not index on its own.
-- The DROPs below are commented out; uncommenting them and re-running 06_benchmark.sql
-- is how the "before" column in the README was measured.

CREATE INDEX IF NOT EXISTS idx_claim_id_pol ON core.claim (id_pol);
CREATE INDEX IF NOT EXISTS idx_policy_driv_age ON core.policy (driv_age);

--DROP INDEX core.idx_claim_id_pol;
--DROP INDEX core.idx_policy_driv_age;

ANALYZE core.claim;
ANALYZE core.policy;
