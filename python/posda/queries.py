from contextlib import contextmanager

from .config import Database

class Error(Exception): pass
class ConfusingArgsError(Error): pass
class InvalidArgsError(Error): pass


class Query(object):
    def __str__(self):
        return f"<Query: {self.name}>"
    def __repr__(self):
        return self.__str__()


    def __init__(self, name):
        self.name = name
        self._conn = None
        self._cur = None
        with Database("posda_queries") as conn:
            cur = conn.cursor()
            cur.execute("select * from queries where name = %s", [name])
            self.schema = None
            for name, query, args, columns, tags, schema, desc in cur:
                self.query = self.__fix_query(query)
                self.args = args
                self.columns = columns
                self.tags = tags
                self.schema = schema
                self.description = desc
                self._database = Database(self.schema)

            if self.schema is None:
                raise KeyError(f"Query does not exist: {name}")

    def __fix_query(self, query):
        """Replace perl-style query arguments with python-style."""
        return query.replace("?", "%s")

    def __fix_args(self, *args, **kwargs):
        if kwargs and args:
            raise ConfusingArgsQueryError("Don't know how to handle both args "
                                          "and kwargs at the same time!")
        # if kwarags are passed, convert to ordered normal args
        if kwargs:
            try:
                args = [kwargs[a] for a in self.args]
            except KeyError as e:
                raise InvalidArgsError("Supplied kwargs did not "
                                       "match the query args") from e
        return args

    def execute(self, *args, **kwargs):
        args = self.__fix_args(*args, **kwargs)

        if self._conn is None:
            self._conn = self._database.connection()
        if self._cur is None:
            self._cur = self._conn.cursor()

        self._cur.execute(self.query, args)
        return self._cur.rowcount

    def run(self, *args, **kwargs):
        args = self.__fix_args(*args, **kwargs)

        with self._database as conn:
            with conn.cursor() as cur:
                cur.execute(self.query, args)
                for row in cur:
                    yield row

    def get_single_value(self, *args, **kwargs):
        """Return the first value in the first row of the Query.

        This is a convenience method for queries that only
        return a single value
        """
        for row in self.run(*args, **kwargs):
            return row[0]
