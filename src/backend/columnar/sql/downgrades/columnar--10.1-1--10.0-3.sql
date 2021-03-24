/* columnar--10.1-1--10.0-3.sql */

-- define foreign keys between columnar metadata tables
ALTER TABLE columnar.chunk
ADD FOREIGN KEY (storage_id, stripe_num, chunk_group_num)
REFERENCES columnar.chunk_group(storage_id, stripe_num, chunk_group_num) ON DELETE CASCADE;

ALTER TABLE columnar.chunk_group
ADD FOREIGN KEY (storage_id, stripe_num)
REFERENCES columnar.stripe(storage_id, stripe_num) ON DELETE CASCADE;

-- For a proper mapping between tid & (stripe, row_num), add a new column to
-- columnar.stripe and define a BTREE index on this column.
DROP INDEX columnar.stripe_first_row_number_idx;
ALTER TABLE columnar.stripe DROP COLUMN first_row_number;
