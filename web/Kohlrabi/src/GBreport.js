import './App.css';
import { useFetch } from './useFetch';

function GBreport(props) {

    var myfilesdiv = [];
    const myfiles = useFetch(`/papi/v1/pathology/review/${props.VRindex}`);
    if(myfiles){
      myfilesdiv = myfiles.map((row, i) =>
        <tr>
          <td>${row.file_name}</td><td>${row.good}</td>
        </tr>
       );
    }

    return (
      <div>
          <div>
            <h1>Files as currently labeled</h1>
            <table>
              {myfilesdiv}
            </table>
          </div>
      </div>
    );
  }


export default GBreport;
