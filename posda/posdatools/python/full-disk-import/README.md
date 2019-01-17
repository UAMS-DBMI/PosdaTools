# Full Disk Import Utils

These are a handful of small scripts, in early development,
to support the import of a full disk of DICOM files directly
into Posda

## scan.py
This script walks the given directory, calls `stat` on every file
found, and records the results into a plist file.

## report.py
This script reads a plist file and generates a simple statistical
report, including total length, total size in bytes, as well as
the mean size, and standard deviation.


