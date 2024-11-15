# # V7 Scan all DICOM files in a series, no error checking (Best Version)
# import pydicom
# import os


# def write_corrected_dicom(dicom_file_path, output_dir):

#     ds = pydicom.dcmread(dicom_file_path, force=True)

#     # Convert ds into a string
#     _ = str(ds)

#     # Create directory for corrected DICOM file
#     os.makedirs(output_dir, exist_ok=True)

#     # Save the corrected DICOM file
#     corrected_file_path = os.path.join(output_dir, os.path.basename(dicom_file_path))
#     ds.save_as(corrected_file_path)
#     print(f"Corrected DICOM file saved to {corrected_file_path}")


# def correct_dicom_files_in_series(series_dir):

#     for root, _, files in os.walk(series_dir):
#         for file in files:
#             dicom_file_path = os.path.join(root, file)
#             output_dir = os.path.join(root + "-corrected")
#             write_corrected_dicom(dicom_file_path, output_dir)


# # Change the working directory
# os.chdir("/Users/alrubayehayder/Downloads/PHI/error-pydicom-studies")

# dicom_series = input("Enter the series ID: ")

# series_dir = os.path.join(".", dicom_series)

# correct_dicom_files_in_series(series_dir)


# V6 Scan all DICOM files in a series, error checking
# import pydicom
# import os


# def write_corrected_dicom(dicom_file_path, output_dir):
#     try:
#         # Load the original DICOM file
#         ds = pydicom.dcmread(dicom_file_path, force=True)

#         # Convert ds into a string
#         _ = str(ds)

#         # Create directory for corrected DICOM file
#         os.makedirs(output_dir, exist_ok=True)

#         # Save the corrected DICOM file
#         corrected_file_path = os.path.join(
#             output_dir, os.path.basename(dicom_file_path)
#         )
#         ds.save_as(corrected_file_path)
#         print(f"Corrected DICOM file saved to {corrected_file_path}")
#     except pydicom.errors.InvalidDicomError:
#         print(f"Invalid DICOM file: {dicom_file_path}")


# def correct_dicom_files_in_series(series_dir):
#     # Iterate over all files in the series directory
#     for root, _, files in os.walk(series_dir):
#         for file in files:
#             # Check if the file is a DICOM file
#             try:
#                 pydicom.dcmread(
#                     os.path.join(root, file), stop_before_pixels=True
#                 ).file_meta
#             except pydicom.errors.InvalidDicomError:
#                 continue
#             dicom_file_path = os.path.join(root, file)
#             output_dir = os.path.join(root + "-corrected")
#             write_corrected_dicom(dicom_file_path, output_dir)


# # Change the working directory
# os.chdir("/Users/alrubayehayder/Downloads/PHI/error-pydicom-studies")

# # Prompt the user to enter the series ID
# dicom_series = input("Enter the series ID: ")

# # Set the path to the series directory
# series_dir = os.path.join(".", dicom_series)

# # Correct all DICOM files in the specified series directory
# correct_dicom_files_in_series(series_dir)


# V5 Single file
# import pydicom
# import os


# def write_corrected_dicom(dicom_file_path, dicom_series):
#     # Load the original DICOM file
#     ds = pydicom.dcmread(dicom_file_path, force=True)

#     # Convert ds into a string
#     _ = str(ds)

#     # Create directory for corrected DICOM file
#     output_dir = os.path.join(
#         os.path.dirname(os.path.dirname(dicom_file_path)), dicom_series + "-corrected"
#     )
#     os.makedirs(output_dir, exist_ok=True)

#     # Save the corrected DICOM file
#     corrected_file_path = os.path.join(output_dir, os.path.basename(dicom_file_path))
#     ds.save_as(corrected_file_path)
#     print(f"Corrected DICOM file saved to {corrected_file_path}")


# # Change the working directory
# os.chdir("/Users/alrubayehayder/Downloads/PHI/error-pydicom-studies")

# # Set the series ID and DICOM file name
# dicom_series = "1.3.6.1.4.1.14519.5.2.1.229995358598705052057270804485123891958"
# dicom_file_name = "0bbfd391d1ebcac30bd19000a383784d"

# dicom_file_path = os.path.join(dicom_series, dicom_file_name)

# # Write corrected DICOM file
# write_corrected_dicom(dicom_file_path, dicom_series)


# # V4 Single file (Working fine)
# import pydicom
# import os


# def write_corrected_dicom(dicom_file_path, dicom_series):
#     # Load the original DICOM file
#     ds = pydicom.dcmread(dicom_file_path, force=True)
#     _ = str(ds)

#     # Create a new DICOM file dataset
#     # corrected_ds = pydicom.dataset.FileDataset(
#     #     os.path.join(dicom_series + "-corrected", os.path.basename(dicom_file_path)),
#     #     ds,
#     #     file_meta=ds.file_meta,
#     # )

#     # Create directory for corrected DICOM file
#     output_dir = os.path.join(
#         os.path.dirname(os.path.dirname(dicom_file_path)), dicom_series + "-corrected"
#     )
#     os.makedirs(output_dir, exist_ok=True)

#     # Save the corrected DICOM file
#     corrected_file_path = os.path.join(output_dir, os.path.basename(dicom_file_path))
#     ds.save_as(corrected_file_path)
#     print(f"Corrected DICOM file saved to {corrected_file_path}")


# # Change the working directory
# os.chdir("/Users/alrubayehayder/Downloads")

# phi_path = "PHI/error-pydicom-studies"

# # Set the series ID and DICOM file name
# dicom_series = "1.3.6.1.4.1.14519.5.2.1.229995358598705052057270804485123891958"
# dicom_file_name = "0bbfd391d1ebcac30bd19000a383784d"

# dicom_file_path = os.path.join(phi_path, dicom_series, dicom_file_name)

# # Write corrected DICOM file
# write_corrected_dicom(dicom_file_path, dicom_series)


# V3
# import pydicom
# import os


# def write_corrected_dicom(dicom_file_path, dicom_series):
#     # Load the original DICOM file
#     ds = pydicom.dcmread(dicom_file_path, force=True)

#     # Create a new DICOM file dataset
#     corrected_ds = pydicom.dataset.FileDataset(
#         os.path.join(dicom_series + "-corrected", os.path.basename(dicom_file_path)),
#         {},
#         file_meta=ds.file_meta,
#     )

#     # Copy each tag from the original dataset to the corrected dataset
#     for data_element in ds:
#         corrected_ds.add(data_element)

#     # Create directory for corrected DICOM file
#     output_dir = os.path.join(
#         os.path.dirname(os.path.dirname(dicom_file_path)), dicom_series + "-corrected"
#     )
#     os.makedirs(output_dir, exist_ok=True)

#     # Save the corrected DICOM file
#     corrected_file_path = os.path.join(output_dir, os.path.basename(dicom_file_path))
#     corrected_ds.save_as(corrected_file_path, write_like_original=False)
#     print(f"Corrected DICOM file saved to {corrected_file_path}")


# # Change the working directory
# os.chdir("/Users/alrubayehayder/Downloads")

# phi_path = "PHI/error-pydicom-studies"

# # Set the series ID and DICOM file name
# dicom_series = "1.3.6.1.4.1.14519.5.2.1.229995358598705052057270804485123891958"
# dicom_file_name = "0bbfd391d1ebcac30bd19000a383784d"

# dicom_file_path = os.path.join(phi_path, dicom_series, dicom_file_name)

# # Write corrected DICOM file
# write_corrected_dicom(dicom_file_path, dicom_series)


# V2 Read a DICOM and write it to a file using PyDICOM
# import pydicom
# import os


# def write_corrected_dicom(dicom_file_path, dicom_series):
#     # Load the original DICOM file
#     ds = pydicom.dcmread(dicom_file_path, force=True)

#     # Create a new DICOM file dataset
#     corrected_ds = pydicom.dataset.FileDataset(
#         os.path.join(dicom_series + "-corrected", os.path.basename(dicom_file_path)),
#         ds,
#         file_meta=ds.file_meta,
#     )

#     # Create directory for corrected DICOM file
#     output_dir = os.path.join(
#         os.path.dirname(os.path.dirname(dicom_file_path)), dicom_series + "-corrected"
#     )
#     os.makedirs(output_dir, exist_ok=True)

#     # Save the corrected DICOM file
#     corrected_file_path = os.path.join(output_dir, os.path.basename(dicom_file_path))
#     corrected_ds.save_as(corrected_file_path, write_like_original=False)
#     print(f"Corrected DICOM file saved to {corrected_file_path}")


# # Change the working directory
# os.chdir("/Users/alrubayehayder/Downloads")

# phi_path = "PHI/error-pydicom-studies"

# # Set the series ID and DICOM file name
# dicom_series = "1.3.6.1.4.1.14519.5.2.1.229995358598705052057270804485123891958"
# dicom_file_name = "0bbfd391d1ebcac30bd19000a383784d"

# dicom_file_path = os.path.join(phi_path, dicom_series, dicom_file_name)

# # Write corrected DICOM file
# write_corrected_dicom(dicom_file_path, dicom_series)


# V1 Read a DICOM file
# import pydicom
# import os


# def print_dicom_header(dicom_file_path):

#     # Load the DICOM file, stopping before loading pixel data
#     # ds = pydicom.dcmread(dicom_file_path, stop_before_pixels=True)

#     # Read the whole DICOM file with its pixel data
#     ds = pydicom.dcmread(dicom_file_path, force=True)

#     # Print header information
#     print("DICOM Header Information:")
#     for element in ds:
#         if element.tag != (0x7FE0, 0x0010):  # Exclude pixel data tag
#             print(f"{element.tag}: {element.name} = {element.value}")


# os.chdir("/Users/alrubayehayder/Downloads")

# phi_path = "PHI/error-pydicom-studies"

# # Prompt user to enter the series ID
# # dicom_series = input("Enter the series ID: ")

# dicom_series = (
#     "/1.3.6.1.4.1.14519.5.2.1.229995358598705052057270804485123891958-corrected/"
# )
# dicom_file_name = "0bbfd391d1ebcac30bd19000a383784d"

# dicom_file_path = phi_path + dicom_series + dicom_file_name
# print_dicom_header(dicom_file_path)
