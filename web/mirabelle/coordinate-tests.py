#!/usr/bin/env python3

import numpy as np

direction = [ 0, 1, 0, 0, 0, -1, -1, 0, 0 ]
dimensions = [ 512, 512, 85 ]
spacing = [ 0.4882810116, 0.4882810116, 2.0000001816522506 ]

# this (manually calcualted) origin shifts the entire volume out of the negative
origin = [170, 0, 249]
# note that this looks like it corresponds to the negative direction vectors?
# the vectors show negative movement in z, and x
# x = 170 = the max value of the component that moves in -x (85) * that component's delta (~2)
# y = 0 = no component moves in negative y, so need to shift here
# z = 249 = the max value that moves in -z (512) * it's delta (~0.488)

# determine which component i/j/k moves in negative X (if any)
# determine which component i/j/k moves in negative Y (if any)
# determine which component i/j/k moves in negative Z (if any)

# make a mapping of X = i or j or k or 0
# make a mapping of Y = i or j or k or 0
# make a mapping of Z = i or j or k or 0
# for example map[X] = j

# construct origin as [map[X](max) * map[X](spacing), repeat for y, repeat for z]

# possibly some way to do it in a single expression?




point = [512,200,36]

# split into the 3 components, use X,Y,Z here to match DICOM standard
X_iop = direction[0:3]
Y_iop = direction[3:6]
Z_iop = direction[6:9]

delta_i, delta_j, delta_k = spacing

#the affine matrix
m = np.matrix([
    [X_iop[0] * delta_i,    Y_iop[0] * delta_j,     Z_iop[0] * delta_k,     origin[0]],
    [X_iop[1] * delta_i,    Y_iop[1] * delta_j,     Z_iop[1] * delta_k,     origin[1]],
    [X_iop[2] * delta_i,    Y_iop[2] * delta_j,     Z_iop[2] * delta_k,     origin[2]],
    [0,                     0,                      0,                      1],
])
# print(m)

def conv(a, b, c):
    """Convert a point using the m transformation matrix"""

    point_matrix = np.matrix([a, b, c, 1]).T

    out = m * point_matrix
    x = np.array(out)[0][0]
    y = np.array(out)[1][0]
    z = np.array(out)[2][0]
    return [int(x), int(y), int(z)]

# print(conv(*point))
dimi, dimj, dimk = dimensions
smallest_x = None
smallest_y = None
smallest_z = None
for i in range(dimi):
    for j in range(dimj):
        for k in range(dimk):
            x, y, z = conv(i, j, k)
            # find the smallest x
            if smallest_x is None or x < smallest_x:
                smallest_x = x
            if smallest_y is None or y < smallest_y:
                smallest_y = y
            if smallest_z is None or z < smallest_z:
                smallest_z = z

print(smallest_x, smallest_y, smallest_z)



