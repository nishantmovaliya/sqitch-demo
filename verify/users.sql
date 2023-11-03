-- Verify flipr:users on pg

-- BEGIN;

-- -- XXX Add verifications here.

-- ROLLBACK;

SELECT nickname, password, timestamp
  FROM flipr.users
 WHERE FALSE;