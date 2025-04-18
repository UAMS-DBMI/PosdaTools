import './App.css';
import { useFetch } from './useFetch';
import { useState } from "react";


function Images(props) {
  const [invertValue, setInvertValue] = useState(0);
  const [rotValue, setRotValue] = useState(0);
  //const currentClass = "smallImage";


  function invertButtonPress(){
    if (invertValue === 1){
      setInvertValue(0);
    }else {
      setInvertValue(1);
    }
  }
  function rotateButtonPress(){
    if (rotValue < 280){
      setRotValue(rotValue+90);
    } else {
      setRotValue(0);
    }
  }

    var images = [];
    const preview_files = useFetch(`/papi/v1/pathology/preview/${props.original_file}/${props.VRindex}`);
    if(preview_files){
      images = preview_files.map((row, i) =>
          <div className ="row">
            <img className="smallImage" style={{filter: `invert(${invertValue})`,  transform: `rotate(${rotValue}deg)`}} src={`/papi/v1/files/${row.preview_file_id}/data`} key={i} alt="svs-preview"/>
          </div>
      );
    }

    var filestatus = [];
    const current_file_data = useFetch(`/papi/v1/pathology/preview_file_name/${props.original_file}`);

    if(current_file_data){
      filestatus = current_file_data.map((row, i) => {
        var status = "Unreviewed";
        if (row.good === true){
          status = "Good";
        }else if(row.good === false){
          status = "Bad";
        }
        return <div key={i}> <label>File: {row.file_name} Review Status: {status} </label> </div>
      });
    }


    return (
      <div>
        <div className="row">
          <div>
            <button className="btn btn-warning m-1" onClick={() => invertButtonPress()}>Invert</button>
            <button className="btn btn-warning m-1" onClick={() => rotateButtonPress()}>Rotate</button>
          </div>
        </div>
        <div className ="imgdisplay">
          <div className ="row"> {filestatus} </div>
          {images}
        </div>
      </div>
    );
  }


export default Images;
