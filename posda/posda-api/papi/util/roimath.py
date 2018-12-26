#!/usr/bin/env python3

import numpy as np

def make_transform(iop, ipp):

    x = np.array(iop[:3])
    y = np.array(iop[3:])

    z = np.cross(x, y)


    # build the transform, Bill's way?
    # Note that we transpose at the end
    xform = np.matrix([
        np.append(x, 0),
        np.append(y, 0),
        np.append(z, 0),
        [0, 0, 0, 1]
    ]).T

    # xform is now:
    # [ X0  Y0  Z0  0 ]
    # [ X1  Y1  Z1  0 ]
    # [ X2  Y2  Z2  0 ]
    # [ 0   0   0   1 ]

    # ipp needs to have 4 dimensions, so we add an extra 1 at the end
    ipp = np.matrix(ipp + [1])

    # apply the transform to the ipp
    rot_ipp = ipp.dot(xform)


    # TODO: I do not understand why this is necessary; I do not see this
    #       in the DICOM standard, however without this step the points
    #       are clearly not correct (Z does not go to 0)

    # Here we change the bottom row of the transform to the output
    # of the ipp rotation above.
    xform.A[3] = -rot_ipp.A[0]

    return xform


if __name__ == '__main__':
    # some test points
    points = [
        [-14.611, -53.268, 88.894, 1],
        [-14.622, -53.135, -14.8, 1],
        [-14.8, -51.007, -51.007, 1],
        [-14.811, -50.874, 88.892, 1],
    ]

    iop = [-8.3346015e-2,9.9652019e-1,-9.7995078e-4,1.2180652e-4,-9.7318472e-4,-9.9999952e-1]
    ipp = [-3.59993e-1,-223.741,261.634]

    xform = make_transform(iop, ipp)


    npoints = np.array(points)
    print("Points before transform")
    print(npoints)
    print("Points after transform, also rounded to ints")
    print(npoints.dot(xform).round(0))
