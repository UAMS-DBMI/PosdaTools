const md5File = require('md5-file');
const fs = require('fs');
const fse = require('fs-extra');
const path = require('path');
const pg = require('pg-promise')();
const winston = require('winston');

const DIR = '/nas/public/posda/storage';

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
  // console.log(hash);


  let prefix = path.join(hash.substr(0, 2), hash.substr(2, 2), hash.substr(4, 2));
  let rel_path = path.join(prefix, hash);
  let output_dir = path.join(root, prefix);
  let output_filename = path.join(output_dir, hash);

  if (!fs.existsSync(output_dir)) {
    makeDirs(output_dir);
  }

  let size = fs.statSync(filename).size; // stat before copy
  fse.moveSync(filename, output_filename, { overwrite: true });

  return { hash: hash, rel_path: rel_path, size: size };
}


export async function finishImage(client: any, filename: string, iec: number) {
  winston.log('debug', 'Finished image for IEC' + iec);
  // console.log('Finishing IEC ' + iec);
  let details = placeFileAndGetMd5(filename, DIR);
  if (details.size == 0) {
    console.log("File was 0 size when we stat'd it, aborting!");
    return;
  }

  // Test if the file alredy exists (via digest)
  // If yes, get the file_id
  let existing_record = await client.oneOrNone(`
    select file_id from file
    where digest = $1
    limit 1
  `, [details.hash]);

  let file_id: number;

  if (existing_record == null) {
    // If no, add the file, retrieve the new file_id, and add the file location
    let new_file_id = await client.one(`
      insert into file
      (digest, size, is_dicom_file, file_type,
       processing_priority, ready_to_process)
      values ($1, $2, $3, $4, $5, $6)
      returning file_id
    `, [details.hash, details.size, false, 'series projection', 1, true]);

    file_id = new_file_id.file_id;

    // set it's location
    await client.query(
      "insert into file_location values ($1, $2, $3, $4)",
      [file_id, 2, details.rel_path, null]
    );
  } else {
    file_id = existing_record.file_id;
  }

  await client.query(
    "insert into image_equivalence_class_out_image values ($1, $2, $3)",
    [iec, 'combined', file_id]
  );

  await client.query(
    "update image_equivalence_class set processing_status = 'ReadyToReview' where image_equivalence_class_id = $1",
    [iec]
  );

  winston.log('debug', 'all done, file_id is' + file_id);
  // console.log(file_id);
}

// let client = pg("postgres://@/posda_files");
// finishImage(client, 'test.png', 999);
