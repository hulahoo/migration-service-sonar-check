import pathlib

import sqlparse
from sqlalchemy import inspect, text

from postgres_db_migrations.apps.db import engine
from postgres_db_migrations.apps.db.models import Migration
from postgres_db_migrations.apps.services import MigrationService
from postgres_db_migrations.config.config import settings
from postgres_db_migrations.config.log_conf import logger

migration_service = MigrationService()

def migrate() -> None:
    with engine.connect() as connection:
        with connection.begin():
                for _, stmt in enumerate(sqlparse.parse(settings.app.script, encoding='utf8'), start=1):
                    connection.execute(text(str(stmt).strip()))
    if not inspect(engine).has_table(f'{settings.app.table_prefix}_migrations'):
        Migration.__table__.create(engine)
        logger.info("Create table")

    root = pathlib.Path(__file__).parent
    script_path = pathlib.Path(f'{root}/{settings.app.scripts_path}')

    migration_service.read_files(str(script_path))