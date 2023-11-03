-- Verify flipr:appschema on pg

BEGIN;

-- XXX Add verifications here.
SELECT pg_catalog.has_schema_privilege('flipr', 'usage');
-- SELECT 1/COUNT(*) FROM information_schema.schemata WHERE schema_name = 'nonesuch';

ROLLBACK;

-- DO $$
-- DECLARE
--     result varchar;
-- BEGIN
--    result := (SELECT name FROM flipr.pipelines WHERE id = 1);
--    ASSERT result = 'Example';
-- END $$;
