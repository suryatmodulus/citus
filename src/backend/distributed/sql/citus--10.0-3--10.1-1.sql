-- citus--10.0-3--10.1-1

-- add the current database to the distributed objects if not already in there.
-- this is to reliably propagate some of the alter database commands that might be
-- supported.
INSERT INTO citus.pg_dist_object SELECT
  (SELECT oid FROM pg_class WHERE relname = 'pg_database') AS oid,
  (SELECT oid FROM pg_database WHERE datname = current_database()) as objid,
  0 as objsubid
ON CONFLICT DO NOTHING;

#include "../../columnar/sql/columnar--10.0-3--10.1-1.sql"
