import sys
import json
import pandas as pd
import argparse
import uuid
import subprocess
import os

error_info = {}
error_info["no_error"] = { "code":0, "msg":"no-error" }
error_info["missing_file"] = { "code":401, "msg":"input-file-missing" }
error_info["file_format"] = { "code":402, "msg":"file-format-error" }
error_info["missing_columns"] = { "code":403, "msg":"missing-columns" }
error_info["showinf_failed"] = { "code":404, "msg":"showinf-failed" }
error_info["fconvert_failed"] = { "code":405, "msg":"fconvert-failed" }
error_info["vips_failed"] = { "code":406, "msg":"vips-failed" }
error_info["manifest_errors"] = { "code":407, "msg":"manifest-errors" }

parser = argparse.ArgumentParser(description="Convert WSI images to multires, tiff images.")
parser.add_argument("--inpmeta",nargs="?",default="quip_manifest.csv",type=str,help="input manifest (metadata) file.")
parser.add_argument("--outmeta",nargs="?",default="quip_manifest.csv",type=str,help="output manifest (metadata) file.")
parser.add_argument("--errfile",nargs="?",default="quip_wsi_error_log.json",type=str,help="error log file.")
parser.add_argument("--cfgfile",nargs="?",default="config_first.ini",type=str,help="HistoQC config file.")
parser.add_argument("--inpdir",nargs="?",default="/data/images",type=str,help="input folder.")
parser.add_argument("--outdir",nargs="?",default="/data/output",type=str,help="output folder.")
parser.add_argument("--slide",nargs="?",default="",type=str,help="one slide to check.")

def check_input_errors(pf,all_log):
    ret_val = 0;
    if "path" not in pf.columns:
        ierr = error_info["missing_columns"]
        ierr["msg"] = ierr["msg"]+": "+"path"
        all_log["error"].append(ierr)
        ret_val = 1

    if "file_uuid" not in pf.columns:
        ierr = error_info["missing_columns"] 
        ierr["msg"] = ierr["msg"]+": "+"file_uuid"
        all_log["error"].append(ierr)
        ret_val = 1

    if "file_ext" not in pf.columns:
        ierr = error_info["missing_columns"] 
        ierr["msg"] = ierr["msg"]+": "+"file_ext"
        all_log["error"].append(ierr)
        ret_val = 1
            
    if "manifest_error_code" not in pf.columns:
        ierr = error_info["missing_columns"] 
        ierr["msg"] = ierr["msg"]+": "+"manifest_error_code"
        all_log["error"].append(ierr)
        ret_val = 1

    if "manifest_error_msg" not in pf.columns:
        ierr = error_info["missing_columns"] 
        ierr["msg"] = ierr["msg"]+": "+"manifest_error_msg"
        all_log["error"].append(ierr)
        ret_val = 1

    return ret_val

def check_input_params(pf,all_log):
    ret_val = 0;
    if "path" not in pf.columns:
        ierr = error_info["missing_columns"]
        ierr["msg"] = ierr["msg"]+": "+"path"
        all_log["error"].append(ierr)
        ret_val = 1

    if "file_uuid" not in pf.columns:
        ierr = error_info["missing_columns"] 
        ierr["msg"] = ierr["msg"]+": "+"file_uuid"
        all_log["error"].append(ierr)
        ret_val = 1

    if "file_ext" not in pf.columns:
        ierr = error_info["missing_columns"] 
        ierr["msg"] = ierr["msg"]+": "+"file_ext"
        all_log["error"].append(ierr)
        ret_val = 1
            
    return ret_val

def process_manifest_file(args):
    inp_folder = args.inpdir 
    out_folder = args.outdir 
    inp_manifest_fname = args.inpmeta
    out_manifest_fname = args.outmeta
    out_error_fname = args.errfile 

    # HistoQC related files
    images_tmp_fname  = str(uuid.uuid1())+".tsv"
    histoqc_results_fname = "results.tsv"
    histoqc_config_fname = args.cfgfile

    out_error_fd = open(out_folder + "/" + out_error_fname,"w");
    all_log = {}
    all_log["error"] = []
    all_log["warning"] = [] 
    try:
        inp_metadata_fd = open(inp_folder + "/" + inp_manifest_fname);
    except OSError:
        ierr = error_info["missing_file"]
        ierr["msg"] = ierr["msg"]+": " + str(inp_manifest_fname);
        all_log["error"].append(ierr)
        json.dump(all_log,out_error_fd)
        out_error_fd.close()
        sys.exit(1)

    pfinp = pd.read_csv(inp_metadata_fd,sep=',')
    if check_input_errors(pfinp,all_log) != 0:
        json.dump(all_log,out_error_fd);
        out_error_fd.close();
        inp_metadata_fd.close();
        sys.exit(1);

    # Pre-processing: create input manifest file for HistoQC
    folder_uuid = out_folder + "/" + "images-" + str(uuid.uuid1());  
    os.makedirs(folder_uuid);
    images_tmp_fd  = open(out_folder + "/" + images_tmp_fname,"w");
    for idx, row in pfinp.iterrows():
        if row["manifest_error_code"]==error_info["no_error"]["code"]:
            os.symlink(inp_folder+"/"+row["path"],folder_uuid+"/"+row["file_uuid"]+row["file_ext"])
            images_tmp_fd.write(row["file_uuid"]+row["file_ext"]+"\n");
    images_tmp_fd.close()

    # Execute HistoQC process
    histoqc_log_fname = str(uuid.uuid1())+"-histoqc.log"
    cmd = "python qc_pipeline.py -s --force "
    cmd = cmd + "-o " + out_folder + " "
    cmd = cmd + "-p " + folder_uuid + " "
    cmd = cmd + "-c " + histoqc_config_fname + " "
    cmd = cmd + out_folder + "/" + images_tmp_fname + " "
    cmd = cmd + "> " + histoqc_log_fname + " 2>&1"

    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        ierr = {}
        ierr["code"] = str(process.returncode)
        ierr["msg"]  = "HistoQC error."
        all_log["error"].append(ierr)
        json.dump(all_log,out_error_fd)
        out_error_fd.close()
        inp_metadata_fd.close();
        sys.exit(1);

    # Post-process: 
    histoqc_results_fd = open(out_folder + "/" + histoqc_results_fname);
    dst = 0
    c_result = None
    pf_result = None
    for x in histoqc_results_fd:
        if dst==0: # header lines
           a = x.split(':')
           if a[0]=='#dataset':
              dst=1
              a[1] = a[1].replace("\n","")
              c_result = a[1].split('\t')
              c_result.append('file_uuid')
              pf_result = pd.DataFrame(columns=c_result)
        else: # read HistoQC output for each image 
           a  = x.replace("\n","")
           c_val = a.split("\t");
           c_val.append('NA');
           pt = pd.DataFrame([c_val],columns=c_result)
           pf_result = pf_result.append(pt,ignore_index=True)


    for idx, row in pf_result.iterrows():
        pf_result.at[idx,"file_uuid"],file_ext = os.path.splitext(str(row["filename"]));

    out_metadata_fd  = open(out_folder + "/" + out_manifest_fname,"w");
    pf_result.to_csv(out_metadata_fd,index=False)

    json.dump(all_log,out_error_fd)

    out_error_fd.close()
    inp_metadata_fd.close()
    out_metadata_fd.close()
    histoqc_results_fd.close()

def process_single_slide(args):
    inp_folder = args.inpdir 
    out_folder = args.outdir 
    inp_manifest_fname = args.inpmeta
    out_manifest_fname = args.outmeta
    out_error_fname = args.errfile 
    inp_slide = args.slide

    # HistoQC related files
    images_tmp_fname  = str(uuid.uuid1())+".tsv"
    histoqc_results_fname = "results.tsv"
    histoqc_config_fname = args.cfgfile

    all_log = {}
    all_log["error"] = []
    all_log["warning"] = [] 
    return_msg = {}
    return_msg["status"] = json.dumps(all_log)
    return_msg["output"] = json.dumps({})

    inp_json = {} 
    r_json = json.loads(inp_slide)
    for item in r_json:
        inp_json[item] = [r_json[item]]
    pfinp = pd.DataFrame.from_dict(inp_json)
    if check_input_params(pfinp,all_log) != 0:
        return_msg["status"] = json.dumps(all_log)
        print(return_msg)
        sys.exit(1);

    # Pre-processing: create input manifest file for HistoQC
    folder_uuid = out_folder + "/" + "images-" + str(uuid.uuid1());  
    os.makedirs(folder_uuid);
    images_tmp_fd  = open(out_folder + "/" + images_tmp_fname,"w");
    for idx, row in pfinp.iterrows():
        os.symlink(inp_folder+"/"+row["path"],folder_uuid+"/"+row["file_uuid"]+row["file_ext"])
        images_tmp_fd.write(row["file_uuid"]+row["file_ext"]+"\n");
    images_tmp_fd.close()

    # Execute HistoQC process
    histoqc_log_fname = str(uuid.uuid1())+"-histoqc.log"
    cmd = "python qc_pipeline.py -s --force "
    cmd = cmd + "-o " + out_folder + " "
    cmd = cmd + "-p " + folder_uuid + " "
    cmd = cmd + "-c " + histoqc_config_fname + " "
    cmd = cmd + out_folder + "/" + images_tmp_fname + " "
    cmd = cmd + "> " + histoqc_log_fname + " 2>&1"

    process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    process.wait()
    if process.returncode != 0:
        ierr = {}
        ierr["code"] = str(process.returncode)
        ierr["msg"]  = "HistoQC error."
        all_log["error"].append(ierr)
        return_msg["status"] = json.dumps(all_log)
        print(return_msg)
        sys.exit(1);

    # Post-process: 
    histoqc_results_fd = open(out_folder + "/" + histoqc_results_fname);
    dst = 0
    c_result = None
    pf_result = None
    for x in histoqc_results_fd:
        if dst==0: # header lines
           a = x.split(':')
           if a[0]=='#dataset':
              dst=1
              a[1] = a[1].replace("\n","")
              c_result = a[1].split('\t')
              c_result.append('file_uuid')
              pf_result = pd.DataFrame(columns=c_result)
        else: # read HistoQC output for each image 
           a  = x.replace("\n","")
           c_val = a.split("\t");
           c_val.append('NA');
           pt = pd.DataFrame([c_val],columns=c_result)
           pf_result = pf_result.append(pt,ignore_index=True)

    for idx, row in pf_result.iterrows():
        pf_result.at[idx,"file_uuid"],file_ext = os.path.splitext(str(row["filename"]));

    one_row = pd.DataFrame(columns=pf_result.columns)
    for idx, row in pf_result.iterrows():
        one_row.loc[0] = pf_result.loc[idx] 
        file_uuid = pf_result.at[idx,"file_uuid"] 
        out_metadata_fd = open(out_folder+"/"+file_uuid+"_"+out_manifest_fname,mode="w")
        one_row.to_csv(out_metadata_fd,index=False)
        out_metadata_fd.close()

    return_msg["status"] = json.dumps(all_log)
    return_msg["output"] = json.dumps(pf_result.to_dict(orient='records'))
    print(return_msg)

    histoqc_results_fd.close()

    return 0

def main(args):
    if args.slide.strip()=="":
        process_manifest_file(args)
    else:
        process_single_slide(args)

    sys.exit(0)

if __name__ == "__main__": 
    args = parser.parse_args(sys.argv[1:]); 
    main(args)

