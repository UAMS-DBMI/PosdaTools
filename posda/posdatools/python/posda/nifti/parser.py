import os
import hashlib
import numpy as np
import nibabel as nib
import struct
import gzip




class NiftiParser:

    # Nifti 1 Definition
    # https://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h

    n1_def = {
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
    
    # Nifti 2 Definition
    # https://nifti.nimh.nih.gov/pub/dist/doc/nifti2.h
    
    n2_def = {
        'sizeof_hdr': {'type': 'int', 'offset': 0, 'length': 4, 'desc': 'MUST be 540'},
        'magic': {'type': 'char[8]', 'offset': 4, 'length': 8, 'desc': 'MUST be valid signature.'},
        'datatype': {'type': 'short', 'offset': 12, 'length': 2, 'desc': 'Defines data type!'},
        'bitpix': {'type': 'short', 'offset': 14, 'length': 2, 'desc': 'Number bits/voxel.'},
        'dim': {'type': 'int64_t[8]', 'offset': 16, 'length': 64, 'desc': 'Data array dimensions.'},
        'intent_p1': {'type': 'double', 'offset': 80, 'length': 8, 'desc': '1st intent parameter.'},
        'intent_p2': {'type': 'double', 'offset': 88, 'length': 8, 'desc': '2nd intent parameter.'},
        'intent_p3': {'type': 'double', 'offset': 96, 'length': 8, 'desc': '3rd intent parameter.'},
        'pixdim': {'type': 'double[8]', 'offset': 104, 'length': 64, 'desc': 'Grid spacings.'},
        'vox_offset': {'type': 'int64_t', 'offset': 168, 'length': 8, 'desc': 'Offset into .nii file'},
        'scl_slope': {'type': 'double', 'offset': 176, 'length': 8, 'desc': 'Data scaling: slope.'},
        'scl_inter': {'type': 'double', 'offset': 184, 'length': 8, 'desc': 'Data scaling: offset.'},
        'cal_max': {'type': 'double', 'offset': 192, 'length': 8, 'desc': 'Max display intensity'},
        'cal_min': {'type': 'double', 'offset': 200, 'length': 8, 'desc': 'Min display intensity'},
        'slice_duration': {'type': 'double', 'offset': 208, 'length': 8, 'desc': 'Time for 1 slice.'},
        'toffset': {'type': 'double', 'offset': 216, 'length': 8, 'desc': 'Time axis shift.'},
        'slice_start': {'type': 'int64_t', 'offset': 224, 'length': 8, 'desc': 'First slice index.'},
        'slice_end': {'type': 'int64_t', 'offset': 232, 'length': 8, 'desc': 'Last slice index.'},
        'descrip': {'type': 'char[80]', 'offset': 240, 'length': 80, 'desc': 'Any text you like.'},
        'aux_file': {'type': 'char[24]', 'offset': 320, 'length': 24, 'desc': 'Auxiliary filename.'},
        'qform_code': {'type': 'int', 'offset': 344, 'length': 4, 'desc': 'NIFTI_XFORM_* code.'},
        'sform_code': {'type': 'int', 'offset': 348, 'length': 4, 'desc': 'NIFTI_XFORM_* code.'},
        'quatern_b': {'type': 'double', 'offset': 352, 'length': 8, 'desc': 'Quaternion b param.'},
        'quatern_c': {'type': 'double', 'offset': 360, 'length': 8, 'desc': 'Quaternion c param.'},
        'quatern_d': {'type': 'double', 'offset': 368, 'length': 8, 'desc': 'Quaternion d param.'},
        'qoffset_x': {'type': 'double', 'offset': 376, 'length': 8, 'desc': 'Quaternion x shift.'},
        'qoffset_y': {'type': 'double', 'offset': 384, 'length': 8, 'desc': 'Quaternion y shift.'},
        'qoffset_z': {'type': 'double', 'offset': 392, 'length': 8, 'desc': 'Quaternion z shift.'},
        'srow_x': {'type': 'double[4]', 'offset': 400, 'length': 32, 'desc': '1st row affine transform.'},
        'srow_y': {'type': 'double[4]', 'offset': 432, 'length': 32, 'desc': '2nd row affine transform.'},
        'srow_z': {'type': 'double[4]', 'offset': 464, 'length': 32, 'desc': '3rd row affine transform.'},
        'slice_code': {'type': 'int', 'offset': 496, 'length': 4, 'desc': 'Slice timing order.'},
        'xyzt_units': {'type': 'int', 'offset': 500, 'length': 4, 'desc': 'Units of pixdim[1..4]'},
        'intent_code': {'type': 'int', 'offset': 504, 'length': 4, 'desc': 'NIFTI_INTENT_* code.'},
        'intent_name': {'type': 'char[16]', 'offset': 508, 'length': 16, 'desc': 'Name or meaning of data.'},
        'dim_info': {'type': 'char', 'offset': 524, 'length': 1, 'desc': 'MRI slice ordering.'},
        'unused_str': {'type': 'char[15]', 'offset': 525, 'length': 15, 'desc': 'Unused, filled with \\0'},
    }

    def __init__(self, file_path, file_id=None):
        
        self.file_path = file_path
        self.file_id = file_id
        
        self.is_zipped = False
        self.nifti_type = 1

        self.file_data = None
        self.header_data = None
        self.image_data = None
        self.header_parsed = {}
        
        self.file_nib = None
        
        self.open()
        
        # if self.header_parsed['magic'].strip() != "n+1":
        #     raise ValueError("Invalid magic string")

    def open(self):
        if self.file_data:
            return
        
        with open(self.file_path, 'rb') as check_file:
            zip_check = check_file.read(2)
        
        if zip_check == b'\x1f\x8b':
            self.is_zipped = True
            self.file_data = gzip.open(self.file_path, 'rb')
        else:
            self.file_data = open(self.file_path, 'rb')
            
        self.file_data.seek(0)
        type_check = self.file_data.read(352)
        
        if type_check[344:348] in [b'n+1\0', b'ni1\0']:
            self.nifti_type = 1
            self.read_n1_header()
        elif type_check[4:8] in [b'n+2\0', b'ni2\0']:
            self.nifti_type = 2
            self.read_n2_header()  
        else:
            raise ValueError("Invalid NIfTI header")
       
        self.read_image_data()
            
        self.file_nib = nib.nifti1.Nifti1Image.from_stream(self.file_data)

    def close(self):
        if self.file_data:
            self.file_data.close()
            self.file_data = None

    def read_n1_header(self):

        self.file_data.seek(0)
        self.header_data = self.file_data.read(348)

        for field, props in self.n1_def.items():
            buff = self.header_data[props['offset']:props['offset'] + props['length']]
            if props['type'] == 'float':
                value = np.frombuffer(buff, dtype='<f4')  # little-endian float
                self.header_parsed[field] = float(value[0]) if len(value) == 1 else [float(v) for v in value]
            elif props['type'] == 'char':
                value = np.frombuffer(buff, dtype='<i1')  # little-endian char
                self.header_parsed[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            elif props['type'] == 'string':
                self.header_parsed[field] = buff.decode('utf-8', errors='replace').replace('\0', '')
            elif props['type'] == 'short':
                value = np.frombuffer(buff, dtype='<i2')  # little-endian short
                self.header_parsed[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            elif props['type'] == 'long':
                value = np.frombuffer(buff, dtype='<i4')  # little-endian long
                self.header_parsed[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            else:
                print(f"Unhandled type {props['type']}")
                
        # for field, props in self.n1_def.items():
        #     buff = self.header_data[props['offset']:props['offset'] + props['length']]
        #     if props['type'] == 'char':
        #         self.header_parsed[field] = buff.decode('utf-8', errors='replace').replace('\0', '')
        #     elif props['type'] == 'float':
        #         value = np.frombuffer(buff, dtype='<f4')  # little-endian float
        #         self.header_parsed[field] = float(value[0]) if len(value) == 1 else [float(v) for v in value]
        #     elif props['type'] == 'short':
        #         value = np.frombuffer(buff, dtype='<i2')  # little-endian short
        #         self.header_parsed[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
        #     elif props['type'] == 'int':
        #         value = np.frombuffer(buff, dtype='<i4')  # little-endian long
        #         self.header_parsed[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
        #     else:
        #         print(f"Unhandled type {props['type']}")

        extensions = {}

        self.file_data.seek(348)
        has_ext = self.file_data.read(1) != b'\x00'
        
        if has_ext:
            self.file_data.seek(352)

            while True:
                size_data = self.file_data.read(4)
                if len(size_data) < 4:
                    break
                
                size = np.frombuffer(size_data, dtype=np.uint32)[0]
                if size < 8:
                    break

                code_data = self.file_data.read(4)
                if len(code_data) < 4:
                    break 
                
                code = np.frombuffer(code_data, dtype=np.uint32)[0]
                
                content_data = self.file_data.read(size - 8)
                if len(content_data) < (size - 8):
                    break
                
                extensions[code] = content_data
        
        self.header_parsed['extensions'] = extensions

    def read_n2_header(self):
        self.file_data.seek(0)
        self.header_data = self.file_data.read(540)  # NIfTI-2 header size is 540 bytes

        for field, props in self.n2_def.items():
            buff = self.header_data[props['offset']:props['offset'] + props['length']]
            if props['type'] in ['float', 'double', 'double[4]', 'double[8]']:
                value = np.frombuffer(buff, dtype='<f8')
                self.header_parsed[field] = float(value[0]) if len(value) == 1 else [float(v) for v in value]
            elif props['type'] in ['char', 'char[24]', 'char[80]', 'char[8]', 'char[16]']:  # Handle all char array types
                self.header_parsed[field] = buff.decode('utf-8', errors='replace').replace('\0', '')
            elif props['type'] in ['short', 'int', 'int64_t']:  # Handle different integer types
                if 'int64_t' in props['type'] or 'int' in props['type']:
                    value = np.frombuffer(buff, dtype='<i8')  # Little-endian 64-bit integer
                else:
                    value = np.frombuffer(buff, dtype='<i2')  # Little-endian short
                self.header_parsed[field] = int(value[0]) if len(value) == 1 else [int(v) for v in value]
            else:
                print(f"Unhandled type {props['type']}")
    
    def read_image_data(self):
        self.file_data.seek(int(self.header_parsed['vox_offset']))
        self.image_data = self.file_data.read()



    #--------------------------------------------------
    # Convert functions from Bill's parser if needed
    #--------------------------------------------------



    def copy_header_to_file(self, file):
        self.open()
        self.file_data.seek(0)
        buff = self.file_data.read(int(self.header_parsed['vox_offset']))
        if len(buff) != self.header_parsed['vox_offset']:
            raise ValueError("Non matching length reading nifti header")
        with open(file, 'wb') as header_file:
            header_file.write(buff)

    def num_slices_and_vols(self):
        return self.header_parsed['dim'][2], self.header_parsed['dim'][3]

    def rows_cols_and_bytes(self):
        return self.header_parsed['dim'][1], self.header_parsed['dim'][0], self.header_parsed['bitpix'] // 8

    def get_slice_offset_length_and_row_length(self, vol_num, frame_num):
        pix_start = self.header_parsed['vox_offset']
        num_cols = self.header_parsed['dim'][0]
        num_rows = self.header_parsed['dim'][1]
        slices_per_volume = self.header_parsed['dim'][2]
        num_volumes = self.header_parsed['dim'][3]
        bytes_per_pix = self.header_parsed['bitpix'] // 8
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
        num_rows = self.header_parsed['dim'][1]
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
        if self.header_parsed['datatype'] == 128:
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
        if self.header_parsed['datatype'] == 128:
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
        num_pix = length // (self.header_parsed['bitpix'] // 8)
        ps = None
        datlen = None
        if self.header_parsed['datatype'] == 4:
            ps = np.int16
            datlen = 2
        elif self.header_parsed['datatype'] == 512:
            ps = np.uint16
            datlen = 2
        elif self.header_parsed['datatype'] == 16:
            ps = np.float32
            datlen = 4
        elif self.header_parsed['datatype'] == 2:
            ps = np.uint8
            datlen = 1
        elif self.header_parsed['datatype'] == 128:
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