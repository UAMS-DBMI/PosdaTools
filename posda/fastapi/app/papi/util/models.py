from pydantic import BaseModel
import numpy as np
from dataclasses import dataclass


class Frame(BaseModel):
    file_id: int
    num_of_frames: int

class FrameResponse(BaseModel):
    volumetric: bool
    frames: list[Frame]


@dataclass
class File:
    file_id: int
    image_type: list[str]
    frame_count: int
    orientation: list
    position: list

    def from_raw(tup):
        file_id, image_type, num_frames, iop, ipp = tup

        if num_frames is None:
            num_frames = 1
        else:
            num_frames = int(num_frames)

        image_types = image_type.split('\\')

        # iop and ipp need to be broken into lists
        iop_parts = iop.split('\\')
        orientation = [float(i) for i in iop_parts]

        ipp_parts = ipp.split('\\')
        position = [float(i) for i in ipp_parts]

        return File(file_id, image_types, num_frames, orientation, position)

    def normals(self):
        return np.cross(self.orientation[:3], self.orientation[3:])

    def projected_position(self):
        return np.dot(self.position, self.normals())



def consistent(file_objs) -> tuple[list[File], bool]:
    """Detect if the list of frames is consistent or not.

    Also returns the list sorted appropriately by projecting 
    with the iop/ipp
    """

    # not enough slices to have any idea
    if len(file_objs) < 2:
        return (file_objs, False)

    sorted_by_proj_position = sorted(file_objs, key=lambda x: x.projected_position())

    all_positions = [i.projected_position() for i in sorted_by_proj_position]

    all_differences = np.diff(all_positions, axis=0)

    consistent_slices = np.allclose(all_differences, all_differences[0], atol=1e-3)

    return (sorted_by_proj_position, consistent_slices)