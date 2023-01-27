import sys
import logging

verbose = False

logger = logging.getLogger('postgres_db_migrations')
logger.setLevel(logging.DEBUG)

console = logging.StreamHandler(sys.stdout)
console.setLevel(logging.DEBUG)
formatter = logging.Formatter(
    '%(asctime)s %(message)s', datefmt='%Y-%m-%dT%H:%M:%S'
)

console.setFormatter(formatter)

logger.addHandler(console)
