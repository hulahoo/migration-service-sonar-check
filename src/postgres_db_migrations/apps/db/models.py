from sqlalchemy import Column, String, DateTime, Boolean, BigInteger, text, func
from sqlalchemy.dialects.postgresql import UUID

from postgres_db_migrations.apps.db import Base
from postgres_db_migrations.config.config import settings


class Migration(Base):
    __tablename__ = f'{settings.app.table_prefix}_migrations'

    uuid = Column(UUID, primary_key=True, server_default=text('uuid_generate_v4()'))
    file_name = Column(String(255), unique=True)
    file_type = Column(String(15))
    file_size = Column(BigInteger)
    file_hash = Column(String(32))
    description = Column(String(255))
    has_errors = Column(Boolean(), default=False)
    is_applied = Column(Boolean(), default=False)
    applied_at = Column(DateTime)
    created_at = Column(DateTime, default=func.now(), nullable=False)
