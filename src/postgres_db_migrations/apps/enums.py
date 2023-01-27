from enum import Enum


class FileType(str, Enum):
    SQL = 'sql'
    PYTHON = 'py'

    @classmethod
    def list(cls):
        return list(map(lambda c: c.value, cls))
