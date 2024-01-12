#!/usr/bin/env python3
# coding: utf-8

import numpy as np
import pandas as pd
import re
import argparse
import sys

data = None
flag = None
allowed = None


flag_text = {
    'empty': "Tag should be empty. If the tag is already empty, you can ignore.",
    'delete': "Tag should be deleted",
    'conditional': "Tag can be conditionally deleted or empty, empty or delete unless there is a reason to keep it",
    'retired': "This is a retired tag, delete unless there is a reason to keep it",
}

def parse_args():
    parser = argparse.ArgumentParser(description='some program')
    parser.add_argument('input', help='input file to process')
    parser.add_argument('--out','-o', default="out.csv", help='output file to write to')

    return parser.parse_args()

def apply_flag_table():
    """Apply Flag table rules"""
    global data, flag

    # join the df with flags
    joined = data.join(flag, on='element')
    # examine the rows that have a flag
    joined_matches = joined[joined['Flag action'].notnull()]

    # if the action is empty and the q_value is already empty, we want to exclude them
    empty_mask = (joined_matches['Flag action'] == 'empty') & (joined_matches['q_value'].isin(['<empty>', '<<empty>>']))
    # joined_matches.loc[~empty_mask, 'review'] = lambda x: x

    new_vals = joined_matches[~empty_mask]['Flag action'].apply(lambda x: flag_text[x])
    
    data.loc[data.index.isin(new_vals.index), 'review'] = new_vals

    # data[data.index.isin(new_vals.index)]


def apply_bpe():
    """Apply Body Part Examined rules"""
    global data

    # look only at Body Part Examined "<(0018,0015)>"

    #filter out only lines with body part examined
    bpe = data[data['element'] == "<(0018,0015)>"]
    # create a mask where q_value is one of the 'empty' values
    empty_mask = (bpe['q_value'] == '<empty>') | (bpe['q_value'] == '<<empty>>')
    remains = bpe[~empty_mask] # select rows that DON'T match the mask

    # mask of rows with q_value that is explicitly allowed
    allowed_mask = remains['q_value'].isin(allowed.index)
    bad_rows = remains[~allowed_mask] # rows that don't match that mask

    data.loc[data.index.isin(bad_rows.index), 'review'] = \
        'Body Part Examined is not in the table'


def apply_undef():
    """Apply undefined description rule"""

    data.loc[(data['description'] == '<undef>') | \
             (data['description'] == '<<undef>>'), 'review'] = \
        "The tag description is undefined"


def apply_patient_age():
    """Check patient age"""

    def is_age_bad(age):
        """Return True if age format is wrong, or out of range"""
        
        group = re.match('<(\d\d\d)([DMY])>', age)
        if group is None:
            return True # age is bad

        val, unit = group[1], group[2]

        if unit == 'Y':
            int_val = int(val)
            if int_val > 90:
                return True # age is bad

        return False # age is good


    pe = data[data['element'] == "<(0010,1010)>"]
    empty_mask = (pe['q_value'] == '<empty>') | (pe['q_value'] == '<<empty>>')
    remains = pe[~empty_mask]

    bad_rows = remains[remains['q_value'].apply(is_age_bad)]

    data.loc[data.index.isin(bad_rows.index), 'review'] = \
        "Invalid format/value in patient age tag."


def apply_uid_check():
    """Check UIDs are hashed"""

    def is_sop_class(thing):
        return re.search('<\(0008,0016\)>|\(0008,1150\)', thing) is not None

    def is_tcia_uid(uid):
        return re.match('<1.3.6.1.4.1.14519.5.2.1.', uid) is not None

    uid_rows = data[data['vr'] == 'UI']
    uid_rows[uid_rows['element'] == "<(0008,0016)>"]

    # mask to select any row where the element is SOP Class UID 
    # OR Referenced SOP Class UID, OR the q_value is <empty> or <<empty>>
    mask = (uid_rows['element'].apply(is_sop_class)) | \
           (uid_rows['q_value'].isin(['<empty>', '<<empty>>']))

    # invert the mask to select only the rows that don't match
    without_mask = uid_rows[~mask]

    # new mask to select only rows where the q_value contains a TCIA UID
    is_tcia_mask = without_mask['q_value'].apply(is_tcia_uid)

    # invert the mask to select only rows that don't match
    bad_rows = without_mask[~is_tcia_mask]

    data.loc[data.index.isin(bad_rows.index), 'review'] = \
        "The UID does not have the TCIA prefix"


def apply_un():
    """Flag UN VR"""

    data.loc[data['vr'] == 'UN', 'review'] = "The VR is unknown"


def apply_modality():
    """Flag potentially unsupported modalities"""

    # constrcut a mask that selects Modality tags where the modality 
    # value is unsupported
    # TODO: this could be a configuration var
    mask = (data['element'] == "<(0008,0060)>") & \
           (data['q_value'].isin(['<OT>', '<PR>', '<SR>', '<KO>']))

    data.loc[mask, 'review'] = \
        "This modality may not be supported by Posda. Remove series if possible"

def apply_patient_id_check():
    """Check Patient ID matches Name"""

    # TODO: can we get tag values out of pydicom?
    patient_id_tag = "<(0010,0020)>"
    patient_name_tag = "<(0010,0010)>"

    id_mask = data['element'] == patient_id_tag
    name_mask = data['element'] == patient_name_tag

    all_ids = data[id_mask]['q_value']
    all_names = data[name_mask]['q_value']

    # this returns the difference between two sets in both directions!
    difference = np.setxor1d(all_ids, all_names, assume_unique=True)

    data.loc[data['q_value'].isin(difference), 'review'] = \
        "PatientID/Name mismatch!"


def apply_no_text_value_found():
    """Check for no text value found"""

    mask = data['q_value'] == "<no text value found>"
    data.loc[mask, 'review'] = (
        "<no text value found> in tag value. "
        "Verify that the tag is empty (or delete if possible). "
        "If SQ tag, follow protocol discussed in Curation Meeting "
        "(in Curation Meeting Notes)"
    )


def apply_study_year_check():
    """Check all dates against Study Year"""

    def is_context_version_date(thing):
        return re.search('\(0008,0106\)', thing) is not None

    def get_year_from_dicom_date(some_date):
        # DICOM DA and DTs always start with the year, just extract it and 
        # convert to an int
        return int(some_date[1:5])

    # get the year of the "study"
    # TODO: this assumes there is only one study date; if there is more than 
    # one, skip this?
    study_date_rows = data[data['element'] == "<(0013,\"CTP\",50)>"]['q_value']
    if len(study_date_rows) > 0:
        study_date = int(study_date_rows.iat[0].replace('<', '').replace('>', ''))
        
        date_mask = data['vr'].isin(['DA', 'DT'])
        date_rows = data[date_mask]
        
        #exclude those with empty values, or that are Context Version Date tags
        empty_mask = date_rows['q_value'].isin(['<empty>', '<<empty>>'])
        cvd_mask = date_rows['element'].apply(is_context_version_date)
        
        dates = date_rows[~(empty_mask | cvd_mask)]
        
        years = dates['q_value'].apply(get_year_from_dicom_date)
        # find years larger than the study date
        data.loc[data.index.isin(years[years > study_date].index), 'review'] = \
            f"The date is outside of the study year range.\nThe Year of Study in the Group 13 tag is: {study_date}"

def main(args):
    global data, flag, allowed

    data = pd.read_csv(args.input)
    # data = pd.read_csv("small.csv")
    # data = pd.read_csv("1121.csv")
    # data = pd.read_csv("big.csv")

    flag = pd.read_csv("flag.csv").set_index('element')
    allowed = pd.read_csv("allowed.csv").set_index('Body Part Examined')

    # add the review column, set it to empty by default
    data['review'] = pd.NA

    apply_flag_table()
    apply_bpe()
    apply_undef()
    apply_patient_age()
    apply_uid_check()
    apply_un()
    apply_modality()
    apply_patient_id_check()
    apply_no_text_value_found()
    apply_study_year_check()

    data.to_csv(sys.stdout)

if __name__ == '__main__':
    args = parse_args()
    main(args)
