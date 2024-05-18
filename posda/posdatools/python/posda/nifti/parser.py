import os
import hashlib
import numpy as np
import gzip

class NiftiParser:
    spec = {
        'sizeof_hdr': {'type': 'long', 'offset': 0, 'length': 4, 'desc': 'Size of the header. Must be 348 (bytes)'},
        'data_type': {'type': 'string', 'offset': 4, 'length': 10, 'desc': 'Not used; compatibility with analyze.'},
        'db_name': {'type': 'string', 'offset': 14, 'length': 18, 'desc': 'Not used; compatibility with analyze.'},
        'extents': {'type': 'long', 'offset': 32, 'length': 4, 'desc': 'Not used; compatibility with analyze.'},
        'session_error': {'type': 'short', 'offset': 36, 'length': 2, 'desc': 'Not used; compatibility with analyze.'},
        'regular': {'type': 'string', 'offset': 38, 'length': 1, 'desc': 'Not used; compatibility with analyze.'},
        'dim_info': {'type': 'string', 'offset': 39, 'length': 1, 'desc': 'Encoding directions (phase, frequency, slice).'},
        'dim': {'type': 'short', 'offset': 40, 'length': 16, 'desc': 'Data array dimensions.'},
        'intent_p1': {'type': 'float', 'offset': 56, 'length': 4, 'desc': '1st intent parameter.'},
        'intent_p2': {'type': 'float', 'offset': 60, 'length': 4, 'desc': '2nd intent parameter.'},
        'intent_p3': {'type': 'float', 'offset': 64, 'length': 4, 'desc': '3rd intent parameter.'},
        'intent_code': {'type': 'short', 'offset': 68, 'length': 2, 'desc': 'nifti intent.'},
        'datatype': {'type': 'short', 'offset': 70, 'length': 2, 'desc': 'Data type.'},
        'bitpix': {'type': 'short', 'offset': 72, 'length': 2, 'desc': 'Number of bits per voxel.'},
        'slice_start': {'type': 'short', 'offset': 74, 'length': 2, 'desc': 'First slice index.'},
        'pixdim': {'type': 'float', 'offset': 76, 'length': 32, 'desc': 'Grid spacings (unit per dimension).'},
        'vox_offset': {'type': 'float', 'offset': 108, 'length': 4, 'desc': 'Offset into a .nii file.'},
        'scl_slope': {'type': 'float', 'offset': 112, 'length': 4, 'desc': 'Data scaling, slope.'},
        'scl_inter': {'type': 'float', 'offset': 116, 'length': 4, 'desc': 'Data scaling, offset.'},
        'slice_end': {'type': 'short', 'offset': 120, 'length': 2, 'desc': 'Last slice index.'},
        'slice_code': {'type': 'char', 'offset': 122, 'length': 1, 'desc': 'Slice timing order.'},
        'xyzt_units': {'type': 'char', 'offset': 123, 'length': 1, 'desc': 'Units of pixdim[1..4].'},
        'cal_max': {'type': 'float', 'offset': 124, 'length': 4, 'desc': 'Maximum display intensity.'},
        'cal_min': {'type': 'float', 'offset': 128, 'length': 4, 'desc': 'Minimum display intensity.'},
        'slice_duration': {'type': 'float', 'offset': 132, 'length': 4, 'desc': 'Time for one slice.'},
        'toffset': {'type': 'float', 'offset': 136, 'length': 4, 'desc': 'Time axis shift.'},
        'glmax': {'type': 'long', 'offset': 140, 'length': 4, 'desc': 'Not used; compatibility with analyze.'},
        'glmin': {'type': 'long', 'offset': 144, 'length': 4, 'desc': 'Not used; compatibility with analyze.'},
        'descrip': {'type': 'string', 'offset': 148, 'length': 80, 'desc': 'Any text.'},
        'aux_file': {'type': 'string', 'offset': 228, 'length': 24, 'desc': 'Auxiliary filename.'},
        'qform_code': {'type': 'short', 'offset': 252, 'length': 2, 'desc': 'Use the quaternion fields.'},
        'sform_code': {'type': 'short', 'offset': 254, 'length': 2, 'desc': 'Use of the affine fields.'},
        'quatern_b': {'type': 'float', 'offset': 256, 'length': 4, 'desc': 'Quaternion b parameter.'},
        'quatern_c': {'type': 'float', 'offset': 260, 'length': 4, 'desc': 'Quaternion c parameter.'},
        'quatern_d': {'type': 'float', 'offset': 264, 'length': 4, 'desc': 'Quaternion d parameter.'},
        'qoffset_x': {'type': 'float', 'offset': 268, 'length': 4, 'desc': 'Quaternion x shift.'},
        'qoffset_y': {'type': 'float', 'offset': 272, 'length': 4, 'desc': 'Quaternion y shift.'},
        'qoffset_z': {'type': 'float', 'offset': 276, 'length': 4, 'desc': 'Quaternion z shift.'},
        'srow_x': {'type': 'float', 'offset': 280, 'length': 16, 'desc': '1st row affine transform'},
        'srow_y': {'type': 'float', 'offset': 296, 'length': 16, 'desc': '2nd row affine transform.'},
        'srow_z': {'type': 'float', 'offset': 312, 'length': 16, 'desc': '3rd row affine transform.'},
        'intent_name': {'type': 'string', 'offset': 328, 'length': 16, 'desc': 'Name or meaning of the data.'},
        'magic': {'type': 'string', 'offset': 344, 'length': 4, 'desc': 'Magic string.'},
    }

    def __init__(self, file_name, file_id=None):
        self.file_name = file_name
        self.file_id = file_id
        self.file_data = None
        self.open()
        self.is_zipped, self.parsed_header = self.read_header(self.file_data)
        
        if self.parsed_header['magic'].strip() != "n+1":
            raise ValueError("Invalid magic string")

    def open(self):
        if self.file_data:
            return
        self.file_data = open(self.file_name, 'rb')

    def close(self):
        if self.file_data:
            self.file_data.close()
            self.file_data = None

    def read_header(self, file_data):
        zip_check = file_data.read(2)
        file_data.seek(0)
        
        is_zipped = False
        parsed_header = {}

        if zip_check == b'\x1f\x8b':  # Check for gzip signature
            is_zipped = True
            with gzip.open(file_data, 'rb') as gz:
                header_bytes = gz.read(348)
        else:
            header_bytes = self.file_data.read(348)

        for field, props in self.spec.items():
            buff = header_bytes[props['offset']:props['offset'] + props['length']]
            if props['type'] == 'float':
                value = np.frombuffer(buff, dtype='<f4')  # little-endian float
                parsed_header[field] = float(value[0]) if len(value) == 1 else [float(v) for v in value]
            elif props['type'] == 'char':
                value = np.frombuffer(buff, dtype='<i1')  # little-endian char
                parsed_header[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            elif props['type'] == 'string':
                parsed_header[field] = buff.decode('utf-8', errors='replace').replace('\0', '')
            elif props['type'] == 'short':
                value = np.frombuffer(buff, dtype='<i2')  # little-endian short
                parsed_header[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            elif props['type'] == 'long':
                value = np.frombuffer(buff, dtype='<i4')  # little-endian long
                parsed_header[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            else:
                print(f"Unhandled type {props['type']}")

        return is_zipped, parsed_header

    def copy_header_to_file(self, file):
        self.open()
        self.file_data.seek(0)
        buff = self.file_data.read(int(self.parsed_header['vox_offset']))
        if len(buff) != self.parsed_header['vox_offset']:
            raise ValueError("Non matching length reading nifti header")
        with open(file, 'wb') as header_file:
            header_file.write(buff)

    def num_slices_and_vols(self):
        return self.parsed_header['dim'][2], self.parsed_header['dim'][3]

    def rows_cols_and_bytes(self):
        return self.parsed_header['dim'][1], self.parsed_header['dim'][0], self.parsed_header['bitpix'] // 8

    def get_slice_offset_length_and_row_length(self, vol_num, frame_num):
        pix_start = self.parsed_header['vox_offset']
        num_cols = self.parsed_header['dim'][0]
        num_rows = self.parsed_header['dim'][1]
        slices_per_volume = self.parsed_header['dim'][2]
        num_volumes = self.parsed_header['dim'][3]
        bytes_per_pix = self.parsed_header['bitpix'] // 8
        row_size = num_cols * bytes_per_pix
        slice_size = row_size * num_rows
        vol_size = slice_size * slices_per_volume
        vol_start_off = vol_num * vol_size
        slice_start_off = vol_start_off + (frame_num * slice_size)
        slice_start = pix_start + slice_start_off
        return slice_start, slice_size, row_size

    def slice_digest(self, v, s):
        ctx = hashlib.md5()
        offset, length, row_size = self.get_slice_offset_length_and_row_length(v, s)
        self.open()
        self.file_data.seek(offset)
        buff = self.file_data.read(length)
        if len(buff) != length:
            raise ValueError("Read length mismatch")
        ctx.update(buff)
        dig = ctx.hexdigest()
        data = np.frombuffer(buff, dtype=np.uint16)
        max_val = data.max()
        min_val = data.min()
        return dig, max_val, min_val

    def flipped_slice_digest(self, v, s):
        offset, length, row_size = self.get_slice_offset_length_and_row_length(v, s)
        ctx = hashlib.md5()
        num_rows = self.parsed_header['dim'][1]
        self.open()
        for r in range(1, num_rows + 1):
            offset_r = offset + ((num_rows - r) * row_size)
            self.file_data.seek(offset_r)
            buff = self.file_data.read(row_size)
            if len(buff) != row_size:
                raise ValueError("Read length mismatch")
            ctx.update(buff)
        return ctx.hexdigest()

    def print_slice(self, v, s, fh):
        offset, length, row_size = self.get_slice_offset_length_and_row_length(v, s)
        self.open()
        self.file_data.seek(offset)
        buff = self.file_data.read(length)
        if len(buff) != length:
            raise ValueError("Read length mismatch")
        fh.write(buff)

    def print_rgb_slice_flipped(self, v, s, fh):
        offset, length, row_size = self.get_slice_offset_length_and_row_length(v, s)
        self.open()
        num_rows = length // row_size
        if self.parsed_header['datatype'] == 128:
            for r in range(1, num_rows + 1):
                offset_r = offset + ((num_rows - r) * row_size)
                self.file_data.seek(offset_r)
                buff = self.file_data.read(row_size)
                if len(buff) != row_size:
                    raise ValueError("Read length mismatch")
                fh.write(buff)
        else:
            raise TypeError("Called print_rgb_slice_flipped on non RGB image")

    def print_rgb_slice(self, v, s, fh):
        offset, length, row_size = self.get_slice_offset_length_and_row_length(v, s)
        self.open()
        self.file_data.seek(offset)
        buff = self.file_data.read(length)
        if self.parsed_header['datatype'] == 128:
            if len(buff) != length:
                raise ValueError("Read length mismatch")
            fh.write(buff)
        else:
            raise TypeError("Called print_rgb_slice on non RGB image")

    def print_slice_scaled(self, v, s, fh):
        offset, length, row_size = self.get_slice_offset_length_and_row_length(v, s)
        self.open()
        self.file_data.seek(offset)
        buff = self.file_data.read(length)
        num_pix = length // (self.parsed_header['bitpix'] // 8)
        ps = None
        datlen = None
        if self.parsed_header['datatype'] == 4:
            ps = np.int16
            datlen = 2
        elif self.parsed_header['datatype'] == 512:
            ps = np.uint16
            datlen = 2
        elif self.parsed_header['datatype'] == 16:
            ps = np.float32
            datlen = 4
        elif self.parsed_header['datatype'] == 2:
            ps = np.uint8
            datlen = 1
        elif self.parsed_header['datatype'] == 128:
            ps = np.uint8
            datlen = 3
        if len(buff) != length:
            raise ValueError("Read length mismatch")
        vals = np.frombuffer(buff, dtype=ps)
        scaled_vals = self.normalize(vals)
        fh.write(scaled_vals.tobytes())

    def normalize(self, array):
        min_val = array.min()
        max_val = array.max()
        scale = max_val - min_val
        if scale == 0:
            return array
        normalized_array = ((array - min_val) * 255 / scale).astype(np.uint8)
        return normalized_array