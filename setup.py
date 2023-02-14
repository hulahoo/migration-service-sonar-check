import os
from setuptools import setup, find_packages

install_requires = [
    ('sqlalchemy', '1.4.46'),
    ('psycopg2-binary', '2.9.5'),
    ('sqlparse', '0.4.3'),
    ('python-dotenv', '0.21.0'),
    ('Flask', '1.0.1'),
    ('flask-restplus', '0.13.0'),
    ('Flask-WTF', '1.0.1'),
    ('prometheus-client', '0.16.0'),
    ('environs', '9.5.0'),
    ('psutil', '5.9.4')
]

CI_PROJECT_NAME = os.environ.get("CI_PROJECT_NAME", "postgres-db-migrations")
ARTIFACT_VERSION = os.environ.get("ARTIFACT_VERSION", "0.1")
CI_PROJECT_TITLE = os.environ.get("CI_PROJECT_TITLE", "Сервис миграций БД")
CI_PROJECT_URL = os.environ.get("CI_PROJECT_URL", "https://gitlab.in.axept.com/rshb/postgres-db-migrations")


setup(
    name=CI_PROJECT_NAME,
    version=ARTIFACT_VERSION,
    description=CI_PROJECT_TITLE,
    url=CI_PROJECT_URL,
    install_requires=[">=".join(req) for req in install_requires],
    python_requires=">=3.10.8",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    package_data={"2022": ["*.sql"], "2022.data": ["*.sql"]},
    include_package_data=True,
    entry_points={
        'console_scripts': [
            CI_PROJECT_NAME + " = " + "postgres_db_migrations.main:execute",
        ]
    },
)
