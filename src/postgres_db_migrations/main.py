import threading

from .migrations import migrate
from .web.routers.api import execute as flask_app
from .config.log_conf import logger

def execute():
    """
    Function entrypoint to start:
    1. Apply db migrations
    2. Flask application to serve enpoints
    """
    flask_thread = threading.Thread(target=flask_app)
    migrations_thread = threading.Thread(target=migrate)

    logger.info("Start Flask app")
    flask_thread.start()

    logger.info("Start migrations")
    migrations_thread.start()
