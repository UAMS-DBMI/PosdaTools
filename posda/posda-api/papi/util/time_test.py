import numpy as np
import timeit

raw = '10\\3\\2.7\\0.0000003'

data = np.loadtxt("GTV_Mass.csv", dtype=int, delimiter=",").flatten().tolist()
data = '\\'.join([str(i) for i in data])


def test1():
    global data

    a = np.array(data.split('\\')).astype(float)

def test2():
    global data

    a = np.fromstring(data, dtype=float, sep='\\')

def setup():
    pass


if __name__ == '__main__': 

    t = timeit.timeit("test2()", 
                      setup="from __main__ import test2, setup; setup()",
                      number=10000)

    print(t)
    t = timeit.timeit("test1()", 
                      setup="from __main__ import test1, setup; setup()",
                      number=10000)

    print(t)
