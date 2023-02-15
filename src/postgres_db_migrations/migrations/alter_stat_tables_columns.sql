ALTER TABLE stat_checked_objects ADD COLUMN IF NOT EXISTS ioc_type varchar(32);
CREATE INDEX IF NOT EXISTS ix_stat_checked_object_ioc_type ON stat_checked_objects (ioc_type);

ALTER TABLE stat_checked_objects DROP COLUMN IF EXISTS indicator_id;
ALTER TABLE stat_received_objects DROP COLUMN IF EXISTS indicator_id;
DROP INDEX IF EXISTS ix_stat_received_object_indicator_id;
DROP INDEX IF EXISTS ix_stat_checked_object_indicator_id;
	
ALTER TABLE processes ADD COLUMN IF NOT EXISTS name varchar(128);
ALTER TABLE processes ADD COLUMN IF NOT EXISTS request jsonb;