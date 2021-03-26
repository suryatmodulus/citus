--
-- Testing indexes on on columnar tables.
--

CREATE SCHEMA columnar_indexes;
SET search_path tO columnar_indexes, public;

--
-- create index with the concurrent option. We should
-- error out during index creation.
-- https://github.com/citusdata/citus/issues/4599
--
create table t(a int, b int) using columnar;
create index CONCURRENTLY t_idx on t(a, b);
\d t
explain insert into t values (1, 2);
insert into t values (1, 2);
SELECT * FROM t;

-- create index without the concurrent option. We should
-- error out during index creation.
create index t_idx on t(a, b);
\d t
explain insert into t values (1, 2);
insert into t values (3, 4);
SELECT * FROM t;

set columnar.enable_custom_scan to 'off';

create table columnar_table (a int, b int) using columnar;
insert into columnar_table (a, b) select i,i*2 from generate_series(0, 16000) i;

-- unique
create unique index ON columnar_table (a);
explain (costs off) select * from columnar_table where a=6456;
explain (costs off) select a from columnar_table where a=6456;
SELECT (select a from columnar_table where a=6456 limit 1)=6456;
SELECT (select b from columnar_table where a=6456 limit 1)=6456*2;

-- should work
insert into columnar_table values (16050);

-- error out
insert into columnar_table values (16050);

-- error out
insert into columnar_table values (15999);

drop index columnar_table_a_idx ;

-- btree
create index ON columnar_table (a);
SELECT (select sum(b) from columnar_table where a>700 and a<965)=439560;

-- some more rows
insert into columnar_table (a, b) select i,i*2 from generate_series(16000, 17000) i;

drop index columnar_table_a_idx;
truncate columnar_table;

-- pkey
insert into columnar_table (a, b) select i,i*2 from generate_series(16000, 16499) i;
alter table columnar_table add primary key (a);
insert into columnar_table (a, b) select i,i*2 from generate_series(16500, 17000) i;

-- error out
insert into columnar_table values (16100), (16101);
insert into columnar_table values (16999);

SET client_min_messages TO WARNING;
DROP SCHEMA columnar_indexes CASCADE;
