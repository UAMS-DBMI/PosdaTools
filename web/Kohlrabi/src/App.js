import './App.css';
import { useFetch } from './useFetch';
import { useState } from "react";
import Images from "./Images";
import GBReport from "./GBreport";



function App(props) {
  const [index, setIndex] = useState(0);
  const [complete, setComplete] = useState(0);

  function nextButtonPress(){
    if (index < (original_files.length-1)){
      setIndex(index+1);
    }else{
      setComplete(1);
    }
    //else route to summary page with option to download the summary??
  }
  function backButtonPress(){
    if (index > 0){
      setComplete(0);
      setIndex(index-1);
    }
  }
  function buttonPress(){
    alert("not yet implemented");
  }
  function buttonPressGood(){
    fetch('/papi/v1/pathology/set_edit/' + original_files[index].path_file_id +'/good', {method: 'PUT'}).then( () => nextButtonPress());
  }
  function buttonPressBad(){
    fetch('/papi/v1/pathology/set_edit/' + original_files[index].path_file_id +'/bad', {method: 'PUT'}).then( () => nextButtonPress());
  }



  const original_files = useFetch('/papi/v1/pathology/start/' + props.VRindex);
  if(props.VRindex === null){
    return <span>Improper URL. No visual review instance selected.</span>
  }
  if(!original_files){
    return(<span>loading....</span>);
  }else if (original_files.length === 0) {
      return(<span>No files for review in VR {props.VRindex} </span>);
  }else if (complete === 1){
    return (
      <div>
      <GBReport VRindex={props.VRindex} />
        <button className="btn btn-warning" onClick={() => backButtonPress()}>Back</button>
      </div>
    )
  }else{
    return (
      <div class="container-fluid">
        <div class="page-header">
          <center>
            <h1>Kohlrabi Pathology Viewer</h1>
          </center>
        </div>
        <hr>
        </hr>
          <div class="row"><h3 align-center>Image File {index+1} of {original_files.length}</h3></div>
          <div class="row">
            <div class ="col">
              <div class="row">
                <button className="btn btn-success m-1 " onClick={() => buttonPressGood()}>Good</button>
                <button className="btn btn-danger m-1" onClick={() => buttonPressBad()}>Bad</button>
              </div>
              {/* <button className="btn btn-primary" onClick={() => buttonPress()}>Edit</button>
              <button className="btn btn-primary" onClick={() => buttonPress()}>Download</button> */}
              <div>
              <div class="row">
                <button className="btn btn-primary m-1" onClick={() => backButtonPress()}>Back</button>
                <button className="btn btn-primary m-1" onClick={() => nextButtonPress()}>Next</button>
              </div>
              </div>
            </div>
            <div className="col-md-10 col-sm-8">
                <Images original_file={original_files[index].path_file_id} VRindex={props.VRindex} />
            </div>
        </div>
      </div>
  );}
  }


export default App;
