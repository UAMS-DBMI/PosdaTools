# V1 Read a DICOM file
import pydicom
import os


def print_dicom_header(dicom_file_path):

    # Load the DICOM file, stopping before loading pixel data
    # ds = pydicom.dcmread(dicom_file_path, stop_before_pixels=True)

    # Read the whole DICOM file with its pixel data
    ds = pydicom.dcmread(dicom_file_path, force=True)

    # Print header information
    print("DICOM Header Information:")
    for element in ds:
        if element.tag != (0x7FE0, 0x0010):  # Exclude pixel data tag
            print(f"{element.tag}: {element.name} = {element.value}")


os.chdir("/Users/alrubayehayder/Downloads")

phi_path = "PHI/error-pydicom-studies"

# Prompt user to enter the series ID
# dicom_series = input("Enter the series ID: ")

dicom_series = (
    "/1.3.6.1.4.1.14519.5.2.1.229995358598705052057270804485123891958-corrected/"
)
dicom_file_name = "5037f5996667f31ee6b5ac56c9367de3"

dicom_file_path = phi_path + dicom_series + dicom_file_name
print_dicom_header(dicom_file_path)
