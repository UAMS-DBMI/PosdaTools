from .roimath import make_transform
import numpy as np

import aiofiles

async def get_contour(filename, offset, length):
    data = await get_contour_data_from_file(filename, offset, length)

    parts = data.split('\\')
    points = len(parts)
    if points % 3 != 0:
        raise RuntimeException("contour is not in 3d space")

    # Make numpy array and parse as floats
    # After this, a looks like:
    # [x, y, z, x, y, z, x, y, z, ... ]
    a = np.array(parts).astype(float)

    # Break into sets of 3
    # After this, b looks like:
    # [[x, y, z],
    #  [x, y, z],
    #  [x, y, z],
    #  ...,
    # ]
    b = a.reshape((-1,3))

    # Add a fourth dimension which is always 1 (needed for later transform)
    # After this, c looks like:
    # [[x, y, z, 1],
    #  [x, y, z, 1],
    #  [x, y, z, 1],
    #  ...,
    # ]
    c = np.insert(b, 3, 1, axis=1)

    return c

async def get_contour_data_from_file(filename, offset, length):
    async with aiofiles.open(filename, 'rb') as f:
        await f.seek(offset)
        data = await f.read(length)
        return data.decode()


def format_color(color):
    default_color = (0, 0, 0)
    if color is not None :
        c = color.split('\\')
        if len(c) != 3:
            return default_color
    else:
        return default_color

    return tuple([int(i) for i in c])


async def get_transformed_contour(
    length, num_points, offset, filename, iop, ipp, pixel_spacing):

    points = await get_contour(filename, offset, length)
    iop = [float(i) for i in iop.split('\\')]
    ipp = [float(i) for i in ipp.split('\\')]
    pixel_spacing = np.array([float(i) for i in pixel_spacing.split('\\')])

    xform = make_transform(iop, ipp)

    xpoints = points.dot(xform)

    # create a slice with only the first two columns
    # which are the (x,y) coordinates. Note: we always expect to have
    # transformed the data such that the z coord is 0
    gpoints = xpoints[:,[0,1]]

    # Apply pixel spacing adjustment, convert to int
    spoints = (gpoints / pixel_spacing).astype(int) # maybe should be .round(0) ?


    if len(points) != num_points:
        print("Warning: actual point count != calculated count!")


    return spoints
