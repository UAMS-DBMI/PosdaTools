import uuid
from sanic import Blueprint
from sanic.response import text, json
from sanic.views import HTTPMethodView
from sanic.exceptions import NotFound

from .util import db

import hashlib
import base64

import redis
EXPIRE_TIME = 5 * 60

r = redis.Redis(host='redis', port=6379, db=1)


def mkpassword(salt, password):
    """Produce a password slug in the same way Posda::Passwords do"""
    sha = hashlib.sha256()
    sha.update((salt + password).encode())
    digest64 = base64.b64encode(sha.digest()).decode().replace('=', '')

    return salt + ',' + digest64

def check_pw(candidate, slug):
    salt, *rest = slug.split(',')

    if slug == mkpassword(salt, candidate):
        return True

    return False

async def _get_password_form_db(username):
    query = """
        select
            password
        from auth.users
        where user_name = $1
    """

    try:
        result = await db.fetch_one(query, [username])
    except NotFound:
        return ','

    return result['password']

def _check_auth(request):
    """Shared code to check a request for authorization"""
    auth = request.headers.get('authorization', None)
    if auth is not None and auth.startswith("Bearer "):
        token = auth.replace("Bearer ", '')
    else:
        return fail("login required")

    valid = r.get(token)
    if not valid:
        return fail("authentication required")
    r.expire(token, EXPIRE_TIME)
    request['token'] = token
    request['username'] = valid.decode()

    return None


# It's too hard to write a decorator that will work for both functions
# and methods, so here are two
def login_required(func):
    def halter(request, *args, **kwargs):
        auth = _check_auth(request)
        if auth is None:
            return func(request, *args, **kwargs)
        else:
            return auth

    return halter

def login_required_method(method):
    def halter(self, request, *args, **kwargs):
        auth = _check_auth(request)
        if auth is None:
            return method(self, request, *args, **kwargs)
        else:
            return auth

    return halter



def generate_login_blueprint():
    """Setup a Blueprint for the login/logout endpoints"""
    bp = Blueprint("auth")

    bp.add_route(
        LoginView.as_view(),
        '/login'
    )

    bp.add_route(
        LogoutView.as_view(),
        '/logout'
    )

    bp.add_route(
        ChangePasswordView.as_view(),
        '/change_password'
    )


    bp.add_route(
        test,
        '/test'
    )

    return bp

@login_required
async def test(request):
    return json({
        'status': 'success',
        'token': request.token,
        'message': 'it works!',
    })


def fail(reason, status=401):
    return json({
        'status': 'failure',
        'reason': reason,
    }, status=status)

class ChangePasswordView(HTTPMethodView):
    @login_required_method
    async def post(self, request):
        user = request.form.get('username')
        new_password = request.form.get('new_password')

        if user != request['username']:
            return fail("can't change that password")

        salt = 'salty' # make real salt
        slug = mkpassword(salt, new_password)

        # update DB here

        return text(slug)

class LogoutView(HTTPMethodView):
    @login_required_method
    async def post(self, request):
        r.delete(request.token)
        return json({
            'status': 'success',
        })


class LoginView(HTTPMethodView):
    async def post(self, request):
        user = request.form.get('username')
        password = request.form.get('password')


        if user is None or password is None:
            return fail("missing username or password as form parameters")

        slug = await _get_password_form_db(user)

        if not check_pw(password, slug):
            return fail("incorrect credentials")

        token = str(uuid.uuid4())

        r.set(token, user)
        r.expire(token, EXPIRE_TIME)
        return json({
            'status': 'success',
            'token': token,
        })
