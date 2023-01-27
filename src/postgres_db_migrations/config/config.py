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


@dataclass
class Config:
    db: DBConfig
    app: AppConfig


def load_config(path: str = None) -> Config:
    env = Env()
    env.read_env(path)

    return Config(
        db=DBConfig(
            name=env.str('POSTGRES_DB'),
            user=env.str('POSTGRES_USER'),
            password=env.str('POSTGRES_PASS'),
            host=env.str('POSTGRES_HOST'),
            port=env.str('POSTGRES_PORT')
        ),
        app=AppConfig(
            table_prefix=env.str('METADATA_TABLE_PREFIX'),
            scripts_path=os.path.join(os.getcwd(), env.str('SCRIPTS_PATH')),
        )
    )


settings = load_config('.env')
