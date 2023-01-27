from typing import Iterator
from os import walk, sep

from postgres_db_migrations.apps.dataclasses import MigrationFile


def scan_dir(root: str) -> Iterator[MigrationFile]:
    for root_dir, subdirs, files in walk(root):
        files.sort()
        subdirs.sort()

        for filename in files:
            yield MigrationFile(
                root=root,
                path=root_dir.replace(root, '').strip(sep),
                name=filename,
            )
