import json
import os


class Config(object):
    """Class that represents the current configuration state of Posda"""
    def get(option):
        option = option.upper()
        if not option.startswith("POSDA_"):
            option = "POSDA_" + option

        return os.environ.get(option, None)

    def load_db_config():
        file_location = Config.get("database_config")

        if file_location is None:
            raise RuntimeError("Missing database config. Is posda.env loaded?")

        with open(file_location) as inf:
            db_config = json.load(inf)

        return db_config
