ALTER TABLE stat_checked_objects ADD COLUMN IF NOT EXISTS ioc_type varchar(32);
ALTER TABLE stat_checked_objects DROP COLUMN IF EXISTS indicator_id;
ALTER TABLE stat_received_objects DROP COLUMN IF EXISTS indicator_id;