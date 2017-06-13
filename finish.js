"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const md5File = require('md5-file');
const fs = require('fs');
const fse = require('fs-extra');
const path = require('path');
const pg = require('pg-promise')();
const DIR = '/home/posda/cache/k-storage';
function makeDirs(targetDir) {
    targetDir.split('/').forEach((dir, index, splits) => {
        const parent = splits.slice(0, index).join('/');
        const dirPath = path.resolve(parent, dir);
        if (!fs.existsSync(dirPath)) {
            fs.mkdirSync(dirPath);
        }
    });
}
function placeFileAndGetMd5(filename, root) {
    let hash = md5File.sync(filename);
    console.log(hash);
    let prefix = path.join(hash.substr(0, 2), hash.substr(2, 2), hash.substr(4, 2));
    let rel_path = path.join(prefix, hash);
    let output_dir = path.join(root, prefix);
    let output_filename = path.join(output_dir, hash);
    if (!fs.existsSync(output_dir)) {
        makeDirs(output_dir);
    }
    let size = fs.statSync(filename).size; // stat before copy
    fse.copySync(filename, output_filename);
    return { hash: hash, rel_path: rel_path, size: size };
}
function finishImage(client, filename, iec) {
    return __awaiter(this, void 0, void 0, function* () {
        let details = placeFileAndGetMd5(filename, DIR);
        if (details.size == 0) {
            console.log('File was 0 size when we statd it, aborting!');
            return;
        }
        let rows = yield client.query(`
    insert into file
    (digest, size, is_dicom_file, file_type,
     processing_priority, ready_to_process)
    values ($1, $2, $3, $4, $5, $6)
    returning file_id
  `, [details.hash, details.size, false, 'series projection', 1, true]);
        let new_file_id = rows[0].file_id;
        yield client.query("insert into file_location values ($1, $2, $3, $4)", [new_file_id, 2, details.rel_path, null]);
        yield client.query("insert into image_equivalence_class_out_image values ($1, $2, $3)", [iec, 'combined', new_file_id]);
        yield client.query("update image_equivalence_class set processing_status = 'ReadyToReview' where image_equivalence_class_id = $1", [iec]);
        console.log(new_file_id);
    });
}
exports.finishImage = finishImage;
// finishImage('test.png', 999);
