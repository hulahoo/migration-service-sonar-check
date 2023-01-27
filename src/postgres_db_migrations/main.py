import argparse

from postgres_db_migrations.apps.db import metadata
from postgres_db_migrations.apps.db.models import Migration
from postgres_db_migrations.apps.services import MigrationService
from postgres_db_migrations.config.config import settings

migration_service = MigrationService()


def execute() -> None:
    # create _migrations table if it not exists
    metadata.create_all()

    parser = argparse.ArgumentParser(
        prog='postgres_db_migrations',
        description='Apply db migrations',
        epilog=''
    )

    parser.add_argument('-v', '--verbose', action='store_true', help='Print details for each file')

    args = parser.parse_args()

    settings.app.verbose = args.verbose

    migration_service.read_files(settings.app.scripts_path)
