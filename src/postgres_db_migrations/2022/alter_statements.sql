-- Added indicator_id to stat_received_objects
ALTER TABLE stat_received_objects ADD COLUMN IF NOT EXISTS indicator_id uuid;
CREATE INDEX IF NOT EXISTS ix_stat_received_object_indicator_id ON stat_received_objects (indicator_id);

-- Added indicator_id to stat_checked_objects
ALTER TABLE stat_checked_objects ADD COLUMN IF NOT EXISTS indicator_id uuid;
CREATE INDEX IF NOT EXISTS ix_stat_checked_object_indicator_id ON stat_received_objects (indicator_id);

ALTER TABLE feeds ADD UNIQUE (title);
ALTER TABLE feeds ADD COLUMN IF NOT EXISTS importing_fields jsonb;