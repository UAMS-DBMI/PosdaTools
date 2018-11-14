#!/usr/bin/env python3

from posda.database import Database

import argparse

import csv
import re
import subprocess

class ColumnMissingError(Exception):
    def __init__(self, message):
        super(ColumnMissingError, self).__init__(
            f"A required column for the specificed "
            f"Operation is missing: {message}")

class InvalidSpreadsheetError(Exception):
    pass

class Operation:
    def __init__(self, operation_name):
        self.details = Operation.get_op_details(operation_name)
        self.process()
        

    def process(self):
        # determine all required parameters
        self.parameters = re.findall("<(.*?)>", 
                                     self.details.command_line)
        self.input_line_params = re.findall("<(.*?)>", 
                                     self.details.input_line_format)

    def process_row(self, row):
        line = self.details.input_line_format
        for param in self.input_line_params:
            column_index = self.headers.index(param)
            replace_value = row[column_index]

            line = line.replace(f"<{param}>", replace_value)

        print(line)
        

    def load_parameters(self, first_row):
        command_line = self.details.command_line
        for param in self.parameters:
            if param == "?bkgrnd_id?":
                replace_value = '0'
            else:
                column_index = self.headers.index(param)
                replace_value = first_row[column_index]

            command_line = command_line.replace(f"<{param}>", replace_value)

        self.command_line = command_line
        print(command_line)

    def ensure_valid(self, headers):
        self.headers = headers
        for param in self.parameters + self.input_line_params:
            if param.startswith('?'):
                continue
            if param not in headers:
                raise ColumnMissingError(param)

    def start(self):
        print("starting the subproc")


    def __str__(self):
        return f"<Operation: {self.details.operation_name}>"

    def get_op_details(operation):
        with Database("posda_queries") as conn:
            cur = conn.cursor()
            cur.execute("""
                select *
                from spreadsheet_operation
                where operation_name = %s
            """, [operation])

            for row in cur:
                return row



input_filename = "test.csv" #TODO
print("-"*80) #TODO remove this


def parse_op(headers, first_row):
    if "Operation" not in headers:
        raise InvalidSpreadsheetError("Missing Operation!")

    op_index = headers.index("Operation")
    
    return first_row[op_index]


with open(input_filename) as infile:
    reader = csv.reader(infile)

    headers = next(reader)
    first_row = next(reader)

    op_name = parse_op(headers, first_row)
    op = Operation(op_name)

    op.ensure_valid(headers)

    op.load_parameters(first_row)

    # Spawn the subprocess here
    op.start()

    op.process_row(first_row)
    for row in reader:
        op.process_row(row)


