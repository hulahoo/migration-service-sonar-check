from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session

from postgres_db_migrations.config.config import settings


db_url = f'postgresql://{settings.db.user}:{settings.db.password}@{settings.db.host}:{settings.db.port}/{settings.db.name}'

engine = create_engine(
    db_url,
    pool_pre_ping=True,
    pool_recycle=3600,
    max_overflow=10,
    pool_size=15,
)

Base = declarative_base()
session = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=engine))
