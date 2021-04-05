import json
import os
import logging


class Config(object):
    """Class that represents the current configuration state of Posda

    Do not instantiate; contains only static methods.
    """
    def get(option, default=None):
        """Read an option from the environment.

        The option can be specified with or without the POSDA_ prefix,
        in all uppercase or not, and you can use - instead of _.

        Thus, these are all equivalent:
            Config.get('POSDA_API_URL')
            Config.get('API_URL')
            Config.get('api_url')
            Config.get('api-url')

        If the option is not present, None is returned, unless default
        is set, then that is returned instead. A warning is issued when
        this happens (via logging.warning).
        """
        option = option.replace('-', '_').upper()
        if not option.startswith("POSDA_"):
            option = "POSDA_" + option

        val = os.environ.get(option, None)
        if val is None:
            logging.warning("Attempt to load nonexistent environment variable: "
                            f"{option}. Using default value {default}.")
            val = default

        return val

    def load_db_config():
        file_location = Config.get("database_config")

        if file_location is None:
            raise RuntimeError("Missing database config. Is posda.env loaded?")

        with open(file_location) as inf:
            db_config = json.load(inf)

        return db_config
