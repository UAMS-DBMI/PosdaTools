import hashlib
import sys
import openslide
import json
import csv
import ntpath
import os
import os.path
import pandas as pd
import argparse
import uuid

error_info = {}
error_info["no_error"] = { "code":0, "msg":"no-error" }
error_info["image_file"] = { "code":201, "msg":"image-format-unsupported" }
error_info["openslide"] = { "code":202, "msg":"openslide-error" }
error_info["file_format"] = { "code":203, "msg":"file-format-error" }
error_info["missing_file"] = { "code":204, "msg":"missing-file" }
error_info["missing_columns"] = { "code":205, "msg":"missing-columns" }
error_info["manifest_errors"] = { "code":206, "msg":"manifest-errors" }

# compute md5sum hash of image file
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

# Extract openslide metadata from image file
def package_metadata(img_meta,img):
    img_meta["level_count"] = int(img.level_count);
    img_meta["width"]  = img.dimensions[0];
    img_meta["height"] = img.dimensions[1];
 
    img_prop = img.properties;
    img_meta["vendor"] = "unknown" 
    img_meta["objective_power"] = "unknown";
    img_meta["mpp_x"] = float(-1.0);
    img_meta["mpp_y"] = float(-1.0);
    if openslide.PROPERTY_NAME_VENDOR in img_prop:
       img_meta["vendor"] = img_prop[openslide.PROPERTY_NAME_VENDOR];
    if openslide.PROPERTY_NAME_OBJECTIVE_POWER in img_prop:
       img_meta["objective_power"] = img_prop[openslide.PROPERTY_NAME_OBJECTIVE_POWER];
    if openslide.PROPERTY_NAME_MPP_X in img_prop:
       img_meta["mpp_x"] = float(img_prop[openslide.PROPERTY_NAME_MPP_X]);
    if openslide.PROPERTY_NAME_MPP_Y in img_prop:
       img_meta["mpp_y"] = float(img_prop[openslide.PROPERTY_NAME_MPP_Y]);
    img_meta_prop = {}
    for p in img_prop:
        img_meta_prop[p] = img_prop[p];
    img_meta["properties"] = img_meta_prop;
    return img_meta;

def openslide_metadata(fname):
    ierr = error_info["no_error"];
    img  = None;
    img_json = None;
    if os.path.exists(fname): 
        try: 
            img = openslide.OpenSlide(fname); 
        except openslide.OpenSlideUnsupportedFormatError: 
            ierr = error_info["image_file"]; 
        except: 
            ierr = error_info["openslide"];
    else: # file does not exist
        ierr = error_info["missing_file"];

    img_meta = {};
    img_meta["error_info"] = ierr
    if str(ierr["code"]) == str(error_info["no_error"]["code"]):
       img_meta = package_metadata(img_meta,img);
    img_temp = json.dumps(img_meta);
    img_json = json.loads(img_temp);
    return img_json,img,ierr;

def extract_macro_image(img):
    img_rgba  = img.associated_images;
    macro_rgb = None;
    label_rgb = None;
    thumb_rgb = None;
    if img_rgba != None:
       if "macro" in img_rgba:
          macro_rgb = img_rgba["macro"].convert("RGB");
       if "label" in img_rgba:
          label_rgb = img_rgba["label"].convert("RGB");
       if "thumbnail" in img_rgba:
          thumb_rgb = img_rgba["thumbnail"].convert("RGB");
       else:
          img_w = img.level_dimensions[img.level_count-1][0]
          img_h = img.level_dimensions[img.level_count-1][1]
          div_v = float(256/img_w)
          img_w = int(img_w*div_v)
          img_h = int(img_h*div_v)
          thumb_rgb = img.get_thumbnail((img_w,img_h)).convert("RGB"); 
    return macro_rgb,label_rgb,thumb_rgb;

def write_macro_image(img_json,macro_rgb,label_rgb,thumb_rgb,out_folder,file_uuid,pfout,file_idx):
    local_path = file_uuid
    full_path  = out_folder+"/"+local_path
    if not os.path.exists(full_path):
       os.makedirs(full_path);

    fname_out = file_uuid+"-metadata.json";
    out_metadata_json_fd = open(full_path+"/"+fname_out,"w");
    json.dump(img_json,out_metadata_json_fd);
    out_metadata_json_fd.close();
    pfout.at[file_idx,"metadata_json"] = local_path+"/"+fname_out;
    pfout.at[file_idx,"macro_img"] = "";
    pfout.at[file_idx,"label_img"] = "";
    pfout.at[file_idx,"thumb_img"] = "";

    if macro_rgb is not None:
       fname_out = file_uuid+"-macro.jpg";
       macro_rgb.save(full_path+"/"+fname_out);
       pfout.at[file_idx,"macro_img"] = local_path+"/"+fname_out;
    if label_rgb is not None:
       fname_out = file_uuid+"-label.jpg";
       label_rgb.save(full_path+"/"+fname_out);
       pfout.at[file_idx,"label_img"] = local_path+"/"+fname_out;
    if thumb_rgb is not None:
       fname_out = file_uuid+"-thumb.jpg";
       thumb_rgb.save(full_path+"/"+fname_out);
       pfout.at[file_idx,"thumb_img"] = local_path+"/"+fname_out;

parser = argparse.ArgumentParser(description="WSI metadata extractor.")
parser.add_argument("--inpmeta",nargs="?",default="quip_manifest.csv",type=str,help="input manifest (metadata) file.")
parser.add_argument("--errfile",nargs="?",default="quip_wsi_error_log.json",type=str,help="error log file.")
parser.add_argument("--inpdir",nargs="?",default="/data/images",type=str,help="input folder.")
parser.add_argument("--outdir",nargs="?",default="/data/output",type=str,help="output folder.")
parser.add_argument("--slide",nargs="?",default="",type=str,help="one slide to process.")

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
            
    return ret_val

def process_manifest_file(args):
    inp_folder   = args.inpdir
    out_folder   = args.outdir
    inp_manifest_fname = args.inpmeta 
    out_manifest_fname = inp_manifest_fname
    out_error_fname = args.errfile 

    out_error_fd = open(out_folder + "/" + out_error_fname,"w");
    all_log = {}
    all_log["error"] = []
    all_log["warning"] = [] 
    try:
        inp_metadata_fd = open(inp_folder + "/" + inp_manifest_fname);
    except OSError:
        ierr = error_info["missing_file"];
        ierr["msg"] = ierr["msg"]+": "+str(inp_manifest_fname)
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
 
    out_metadata_fd = open(out_folder + "/" + out_manifest_fname,"w");
    cols  = ['file_uuid','slide_error_msg','slide_error_code','label_img','macro_img','thumb_img','metadata_json'];
    pfout = pd.DataFrame(columns=cols);
    pfout_idx = 0
    for file_idx in range(len(pfinp["path"])):
        if str(pfinp["manifest_error_code"][file_idx])==str(error_info["no_error"]["code"]): # Extract metadata from image
            file_uuid = pfinp["file_uuid"][file_idx];
            fname = inp_folder+"/"+pfinp["path"][file_idx];
            img_json,img,ierr = openslide_metadata(fname);
            img_json["filename"] = file_uuid; 
            pfout.at[pfout_idx,"file_uuid"] = file_uuid;
            pfout.at[pfout_idx,"slide_error_code"] = str(ierr["code"]);
            pfout.at[pfout_idx,"slide_error_msg"] = ierr["msg"];
            if str(ierr["code"])!=str(error_info["no_error"]["code"]):
                ierr["row_idx"] = file_idx
                ierr["file_uuid"] = file_uuid
                all_log["error"].append(ierr) 
 
            # If file is OK, extract macro image and write it out
            if str(ierr["code"])==str(error_info["no_error"]["code"]):
                macro_rgb,label_rgb,thumb_rgb = extract_macro_image(img);
                write_macro_image(img_json,macro_rgb,label_rgb,thumb_rgb,out_folder,file_uuid,pfout,pfout_idx);

            pfout_idx = pfout_idx + 1; 

    pfout.to_csv(out_metadata_fd,index=False)
    json.dump(all_log,out_error_fd)

    inp_metadata_fd.close();
    out_error_fd.close()
    out_metadata_fd.close();

def process_single_slide(args):
    inp_folder   = args.inpdir
    out_folder   = args.outdir
    inp_manifest_fname = args.inpmeta 
    out_manifest_fname = inp_manifest_fname
    out_error_fname = args.errfile 
    inp_slide = args.slide

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
 
    cols  = ['file_uuid','slide_error_msg','slide_error_code','label_img','macro_img','thumb_img','metadata_json'];
    pfout = pd.DataFrame(columns=cols);
    pfout_idx = 0
    for file_idx in range(len(pfinp["path"])):
        file_uuid = pfinp["file_uuid"][file_idx];
        fname = inp_folder+"/"+pfinp["path"][file_idx];
        img_json,img,ierr = openslide_metadata(fname);
        img_json["filename"] = file_uuid; 
        pfout.at[pfout_idx,"file_uuid"] = file_uuid;
        pfout.at[pfout_idx,"slide_error_code"] = str(ierr["code"]);
        pfout.at[pfout_idx,"slide_error_msg"] = ierr["msg"];
        if str(ierr["code"])!=str(error_info["no_error"]["code"]):
            ierr["row_idx"] = file_idx
            ierr["file_uuid"] = file_uuid
            all_log["error"].append(ierr) 
 
        # If file is OK, extract macro image and write it out
        if str(ierr["code"])==str(error_info["no_error"]["code"]):
            macro_rgb,label_rgb,thumb_rgb = extract_macro_image(img);
            write_macro_image(img_json,macro_rgb,label_rgb,thumb_rgb,out_folder,file_uuid,pfout,pfout_idx);

        pfout_idx = pfout_idx + 1; 

    one_row = pd.DataFrame(columns=pfout.columns)
    for idx, row in pfout.iterrows():
        one_row.loc[0] = pfout.loc[idx] 
        file_uuid = pfout.at[idx,"file_uuid"] 
        out_metadata_fd = open(out_folder+"/"+file_uuid+"_"+out_manifest_fname,mode="w")
        one_row.to_csv(out_metadata_fd,index=False)
        out_metadata_fd.close()

    return_msg["status"] = json.dumps(all_log)
    return_msg["output"] = json.dumps(pfout.to_dict(orient='records'))
    print(return_msg)

def main(args):
    if args.slide.strip()=="":
        process_manifest_file(args)
    else:
        process_single_slide(args)

    sys.exit(0)

if __name__ == "__main__":
    args = parser.parse_args() 
    main(args)

