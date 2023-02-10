from datetime import datetime

from sqlalchemy import text
from sqlalchemy.exc import DatabaseError

from postgres_db_migrations.apps.utils import scan_dir
from postgres_db_migrations.apps.db import engine
from postgres_db_migrations.apps.db.models import Migration
from postgres_db_migrations.apps.db.providers import MigrationProvider
from postgres_db_migrations.apps.dataclasses import MigrationFile

from postgres_db_migrations.config.config import settings
from postgres_db_migrations.config.log_conf import logger


migration_provider = MigrationProvider()


class MigrationService:
    def read_files(self, root: str):
        for file in scan_dir(root):
            # skip unknown filetypes
            if not file.type:
                continue

            migration = Migration(
                file_name=file.relative_path,
                file_type=file.type,
                file_size=file.size,
                file_hash=file.hash,
            )

            migration_provider.add(migration)

            if not self._apply_migrations_from_file(file):
                break

    def _print_details(self, migration: Migration, file: MigrationFile):
        if not settings.app.verbose:
            return

        details = []

        details.append(f'Migration ID: {migration.uuid}')
        details.append(f'Path: {migration.file_name}')
        details.append(f'File type: {migration.file_type}')
        details.append(f'File size: {migration.file_size}')
        details.append(f'File hash: {migration.file_hash}')
        details.append(f'Created At: {migration.created_at}')
        details.append(f'\n{file.raw_content}\n')

        print('\n'.join(details))

    def _apply_migrations_from_file(self, file: MigrationFile) -> bool:
        migration = migration_provider.get_by_filename(file.relative_path)
        # skip applied migrations
        if migration.is_applied:
            return True

        self._print_details(migration, file)

        try:
            with engine.connect() as connection:
                with connection.begin():
                    for i, sql_statement in enumerate(file.sql_statements, start=1):
                        logger.info(
                            f'Apply migration # {i} of {len(file.sql_statements)} from [ {file.relative_path} ]...'
                        )
                        connection.execute(text(sql_statement))

        except DatabaseError as e:
            migration.has_errors = True
            migration.is_applied = False
            migration.applied_at = datetime.now()

            migration_provider.update(migration)

            logger.error(f'Error: {e}')

            result = False
        else:
            migration.has_errors = False
            migration.is_applied = True
            migration.applied_at = datetime.now()

            migration_provider.update(migration)

            result = True

        return result
