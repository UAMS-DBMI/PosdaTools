const md5File = require('md5-file');
const fs = require('fs');
const fse = require('fs-extra');
const path = require('path');
const pg = require('pg-native');

const DIR = 'dicom';

function makeDirs(targetDir: string) {
  targetDir.split('/').forEach((dir: any, index: any, splits: any) => {
    const parent = splits.slice(0, index).join('/');
    const dirPath = path.resolve(parent, dir);
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath);
    }
  });
}

function placeFileAndGetMd5(filename: string, root: string) {
  let hash = md5File.sync(filename);
  console.log(hash);


  let prefix = path.join(hash.substr(0, 2), hash.substr(2, 2), hash.substr(4, 2));
  let rel_path = path.join(prefix, hash);
  let output_dir = path.join(root, prefix);
  let output_filename = path.join(output_dir, hash);

  if (!fs.existsSync(output_dir)) {
    makeDirs(output_dir);
  }

  fse.copySync(filename, output_filename);

  return { hash: hash, rel_path: rel_path, size: fs.statSync(output_filename).size };
}


export function finishImage(filename: string, iec: number) {
  let details = placeFileAndGetMd5(filename, DIR);

  let client = new pg();
  client.connectSync('postgres://tcia-utilities/N_posda_files');

  let rows = client.querySync(`
    insert into file
    (digest, size, is_dicom_file, file_type,
     processing_priority, ready_to_process)
    values ($1, $2, $3, $4, $5, $6)
    returning file_id
  `, [details.hash, details.size, false, 'series projection', 1, true]);


  let new_file_id = rows[0].file_id;

  client.querySync(
    "insert into file_location values ($1, $2, $3, $4)",
    [new_file_id, 1, details.rel_path, null]
  );

  client.querySync(
    "insert into image_equivalence_class_out_image values ($1, $2, $3)",
    [iec, 'combined', new_file_id]
  );

  client.querySync(
    "update image_equivalence_class set processing_status = 'QTest2' where image_equivalence_class_id = $1",
    [iec]
  );

  console.log(new_file_id);
}
