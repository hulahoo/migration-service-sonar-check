from typing import Optional
from sqlalchemy.exc import IntegrityError

from postgres_db_migrations.apps.db import session
from postgres_db_migrations.apps.db.models import Migration


class MigrationProvider:
    def add(self, migration: Migration):
        try:
            session.add(migration)
            session.commit()
        except IntegrityError:
            # skip duplicate records
            session.rollback()

    def update(self, migration: Migration):
        session.add(migration)
        session.commit()

    def get_all(self) -> list[Migration]:
        query = session.query(Migration).filter(Migration.is_applied == False).order_by(Migration.created_at)

        return query.all()

    def get_by_filename(self, file_name: str) -> Optional[Migration]:
        query = session.query(Migration).filter(Migration.file_name == file_name)

        return query.one_or_none()
