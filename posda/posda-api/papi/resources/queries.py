from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic.exceptions import InvalidUsage

from ..util import db
from ..util import json_objects, json_records
from ..auth import fail

import posda
from posda.queries import Query


async def get_all_queries(request, **kwargs):
    tags = request.args.get("tags")
    args = request.args.get("args")
    columns = request.args.get("columns")

    query = """
        select name
        from queries
    """

    where = []
    bind_vars = []

    if tags is not None:
        where.append("tags && ${}")
        bind_vars.append([tags])

    if args is not None:
        where.append("args && ${}")
        bind_vars.append([args])

    if columns is not None:
        where.append("columns && ${}")
        bind_vars.append([columns])

    if len(where) > 0:
        query = query + 'where ' + ' and '.join(where)
        # replace all the placeholders with sequentially numbered bind vars
        query = query.format(*range(1, len(where) + 1))


    return json_records(
        await db.fetch(query, bind_vars)
    )


class ExecuteQuery(HTTPMethodView):
    async def get_query_details(self, query_name):
        result = await db.fetch_one("""
            select *
            from queries
            where name = $1
        """, [query_name])

        return result

    async def post(self, request):
        query_name = request.args.get('query_name')

        query = await self.get_query_details(query_name)

        # print(request.json)

        if query['schema'] != "posda_files":
            raise InvalidUsage("This API currently supports only queries "
                               "in the posda_files schema.")


        # check that all arguments were provided
        args = []
        for argument in query['args']:
            value = request.form.get(argument)
            if value is None:
                raise InvalidUsage("Missing value for argument {}".format(
                    argument))
            else:
                args.append(value)


        results = Query(query['name']).run(*args)


        return json({
            'status': 'success',
            'columns': query['columns'],
            'results': results,
        })
