import './App.css';
import { useFetch } from './useFetch';
import { useState } from "react";


function Images(props) {
  const [invertValue, setInvertValue] = useState(0);
  const [rotValue, setRotValue] = useState(0);
  const currentClass = "smallImage";


  function invertButtonPress(){
    if (invertValue == 1){
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
    const preview_files = useFetch(`/papi/v1/pathology/preview/${props.original_file}`);
    if(preview_files){
      images = preview_files.map((row, i) =>
         <img className="smallImage" style={{filter: `invert(${invertValue})`,  transform: `rotate(${rotValue}deg)`}} src={`/papi/v1/files/${row.preview_file_id}/data`} key={i} alt="svs-preview"/>
       );
    }

    return (
      <div>
          <div>
            <button className="btn btn-warning" onClick={() => invertButtonPress()}>Invert</button>
            <button className="btn btn-warning" onClick={() => rotateButtonPress()}>Rotate</button>
          </div>
        <div className ="imgdisplay">
          {images}
        </div>
      </div>
    );
  }


export default Images;
