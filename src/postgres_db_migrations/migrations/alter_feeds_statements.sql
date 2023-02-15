ALTER TABLE feeds ADD UNIQUE (title);
ALTER TABLE feeds ADD COLUMN IF NOT EXISTS importing_fields jsonb;

ALTER TABLE feeds ADD COLUMN IF NOT EXISTS is_deleted boolean default false;
ALTER TABLE feeds ADD COLUMN IF NOT EXISTS deleted_at timestamp with time zone;
ALTER TABLE feeds ADD COLUMN IF NOT EXISTS deleted_by bigint;