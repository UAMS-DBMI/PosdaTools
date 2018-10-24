from ..subprocess import lines

def insert_file(filename, comment="Added by Python Job"):
    """Insert a file into posda, and return the new file_id

    Currently implemented via calls to 
    the perl program ImportSingleFileIntoPosdaAndReturnId.pl
    """
    for line in lines(['ImportSingleFileIntoPosdaAndReturnId.pl', filename, comment]):
        if line.startswith("File id:"):
            return int(line[8:])

    # TODO: pass on the error if there was one
    raise RuntimeError("Failed to insert file into posda!")
