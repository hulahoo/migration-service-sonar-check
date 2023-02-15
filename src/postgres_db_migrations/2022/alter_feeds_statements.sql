ALTER TABLE feeds ADD UNIQUE (title);
ALTER TABLE feeds ADD COLUMN IF NOT EXISTS importing_fields jsonb;