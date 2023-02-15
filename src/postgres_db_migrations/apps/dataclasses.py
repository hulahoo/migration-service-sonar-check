import sqlparse

from typing import Optional, List
from dataclasses import dataclass
from os import path, sep
from hashlib import sha512

from postgres_db_migrations.apps.enums import FileType


@dataclass
class MigrationFile:
    root: str
    path: str
    name: str

    @property
    def relative_path(self) -> str:
        return path.join(sep, self.path, self.name)

    @property
    def full_path(self) -> str:
        return path.join(self.root, self.path, self.name)

    @property
    def size(self):
        return path.getsize(self.full_path)

    @property
    def type(self) -> Optional[str]:
        filetype = self.name.split('.')[-1].lower()

        if filetype in FileType.list():
            return filetype

    @property
    def hash(self) -> str:
        return sha512(open(self.full_path, 'rb').read()).hexdigest()

    @property
    def raw_content(self):
        with open(self.full_path, 'r') as file:
            data = file.read()
            return data

    @property
    def sql_statements(self) -> List[str]:
        return list(
            map(
                lambda statement: str(statement).strip(),
                sqlparse.parse(self.raw_content, encoding='utf8')
            )
        )
