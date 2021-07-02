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

    def get_storage_location(storage_class):
        # delay loading of Database to avoid a circular reference
        # plus, it is not needed unless this method is called
        from .database import Database
        with Database("posda_files").cursor() as cur:
            cur.execute("""
                select root_path
                from file_storage_root
                where storage_class = %s
            """, [storage_class])

            for val, in cur:
                return val

        # if we get here, it means there was no entry that matched
        # the requested storage_class, and this is a fatal error
        logging.fatal("Attempt to load nonexistent storage_class of "
                      f"{storage_class}.")
        raise RuntimeError(f"Fatal error: no such storage_class {storage_class}!")

    def load_db_config():
        file_location = Config.get("database_config")

        if file_location is None:
            raise RuntimeError("Missing database config. Is posda.env loaded?")

        with open(file_location) as inf:
            db_config = json.load(inf)

        return db_config
