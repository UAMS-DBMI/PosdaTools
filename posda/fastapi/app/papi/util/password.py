import string
import random
import hashlib
import base64

def make_salt(length: int=8) -> str:
    """Make a simple random salt

    This was adapted from perl Passwords.pm
    """

    chars = [
        '.',
        '/',
        *string.digits,
        *string.ascii_letters,
    ]

    salt = random.choices(chars, k=length)

    return ''.join(salt)

def encode(password: str) -> str:
    salt = make_salt()
    return _encode(salt, password)

def _encode(salt: str, password: str) -> str:
    m = hashlib.sha256()

    m.update(salt.encode())
    m.update(password.encode())

    digest = base64.b64encode(m.digest()).decode()

    # to be exactly compatible with the perl implementation, we must
    # drop any padding characters in the base64!
    digest = digest.replace("=", '')

    return f"{salt},{digest}"

def is_valid(hashed_password: str, candidate_password: str) -> bool:
    salt, _ = hashed_password.split(',')

    hashed_candidate = _encode(salt, candidate_password)

    return hashed_password == hashed_candidate


def test():
    print("running some simple tests")

    salt = make_salt()
    print("A sample salt:", salt)
    assert len(salt) == 8
    assert len(make_salt(3)) == 3
    assert len(make_salt(9)) == 9

    admin_encoded = "aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE"
    print(_encode(salt, "some test"))
    tencode = _encode("aJE5lY8D", "admin")
    print(tencode)
    assert tencode == admin_encoded

    assert is_valid(admin_encoded, "admin")

if __name__ == '__main__':
    test()
