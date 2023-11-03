-- Revert flipr:appschema from pg

BEGIN;

-- XXX Add DDLs here.
DROP SCHEMA flipr;

COMMIT;
