import argparse

from sqlalchemy import inspect

from postgres_db_migrations.apps.db import engine
from postgres_db_migrations.config.log_conf import logger
from postgres_db_migrations.config.config import settings
from postgres_db_migrations.apps.db.models import Migration
from postgres_db_migrations.apps.services import MigrationService

migration_service = MigrationService()


def execute() -> None:
    # create _migrations table if it not exists
    if not inspect(engine).has_table(f'{settings.app.table_prefix}_migrations'):
        Migration.__table__.create(engine)
        logger.info("Create table")

    parser = argparse.ArgumentParser(
        prog='postgres_db_migrations',
        description='Apply db migrations',
        epilog=''
    )
    parser.add_argument('-v', '--verbose', action='store_true', help='Print details for each file')

    args = parser.parse_args()

    settings.app.verbose = args.verbose
    print(settings.app.scripts_path, '???')

    migration_service.read_files(settings.app.scripts_path)
