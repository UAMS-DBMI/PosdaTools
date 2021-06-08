import './App.css';
import { useFetch } from './useFetch';
import { useState } from "react";
import Images from "./Images";


function App(props) {
  const [index, setIndex] = useState(0);

  function nextButtonPress(){
    if (index < (original_files.length-1)){
      setIndex(index+1);
    }
  }
  function backButtonPress(){
    if (index > 0){
      setIndex(index-1);
    }
  }
  function buttonPress(){
    alert("not yet implemented");
  }

  const original_files = useFetch('/papi/v1/pathology/start/' + props.VRindex);
  if(!original_files){
    return(<span>loading....</span>);
  }else if (original_files.length === 0) {
      return(<span>No files for review in VR {props.VRindex} </span>);
  }



    return (
      <div>
          <h1>Now Viewing Image {index+1} out of {original_files.length}</h1>
          <div>
            <button className="btn btn-success" onClick={() => buttonPress()}>Good</button>
            <button className="btn btn-error" onClick={() => buttonPress()}>Bad</button>
            <button className="btn btn-warning" onClick={() => buttonPress()}>Edit</button>
            <button className="btn btn-warning" onClick={() => buttonPress()}>Download</button>
          </div>
        <div>
          <button className="btn btn-warning" onClick={() => backButtonPress()}>Back</button>
          <button className="btn btn-warning" onClick={() => nextButtonPress()}>Next</button>
        </div>
        <div>
          <Images original_file={original_files[index].svsfile_id} VRindex={props.VRindex} />
        </div>
      </div>
    );
  }


export default App;
