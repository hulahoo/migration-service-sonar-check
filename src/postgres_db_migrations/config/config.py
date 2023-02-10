import os

from dataclasses import dataclass
from environs import Env


@dataclass
class DBConfig:
    name: str
    user: str
    password: str
    host: str
    port: str


@dataclass
class AppConfig:
    table_prefix: str
    scripts_path: str
    verbose: bool = False
    csrf_enabled: bool = True
    session_cookie_secure: bool = True


@dataclass
class Config:
    db: DBConfig
    app: AppConfig


def load_config(path: str = None) -> Config:
    env = Env()
    env.read_env(path)

    return Config(
        db=DBConfig(
            name=env.str('APP_POSTGRESQL_NAME'),
            user=env.str('APP_POSTGRESQL_USER'),
            password=env.str('APP_POSTGRESQL_PASSWORD'),
            host=env.str('APP_POSTGRESQL_HOST'),
            port=env.str('APP_POSTGRESQL_PORT')
        ),
        app=AppConfig(
            table_prefix=env.str('METADATA_TABLE_PREFIX', default=''),
            scripts_path=os.path.join(os.getcwd(), env.str('SCRIPTS_PATH', default='src/postgres_db_migrations/migrations/2022/')),
            session_cookie_secure=env.bool('SESSION_COOKIE_SECURE'),
            csrf_enabled=env.bool('CSRF_ENABLED')
        )
    )


settings = load_config('.env')
