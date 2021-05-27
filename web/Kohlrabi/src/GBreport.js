import './App.css';
import { useFetch } from './useFetch';

function GBreport(props) {


    var bad = [];
    const bad_files = useFetch(`/papi/v1/pathology/review/${props.VRindex}/bad`);
    if(bad_files){
      bad = bad_files.map((row, i) =>
        <tr>
          <td>${row.file_name}</td>
        </tr>
       );
    }

    var good = [];
    const good_files = useFetch(`/papi/v1/pathology/review/${props.VRindex}/good`);
    if(good_files){
      good = good_files.map((row, i) =>
        <tr>
          <td>${row.file_name}</td>
        </tr>
       );
    }

    var unreviewed = [];
    const unreviewed_files = useFetch(`/papi/v1/pathology/review/${props.VRindex}/null`);
    if(unreviewed_files){
      unreviewed = unreviewed_files.map((row, i) =>
        <tr>
          <td>${row.file_name}</td>
        </tr>
       );
    }

    return (
      <div>
          <div>
            <h1>Files marked as Bad</h1>
            <table>
              {bad}
            </table>
          </div>
          <div>
            <h1>Files marked as Good</h1>
            <table>
              {good}
            </table>
          </div>
          <div>
            <h1>Files in need of Review</h1>
            <table>
              {unreviewed}
            </table>
          </div>
      </div>
    );
  }


export default GBreport;
