from contextlib import contextmanager

@contextmanager
def test(things):
    print("begin")
    yield "test"
    print("end")



with test(4) as a:
    print(a)
