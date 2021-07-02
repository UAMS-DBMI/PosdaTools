import './App.css';
import { useFetch } from './useFetch';


function GBreport(props) {

    var myfilesdiv = [];
    var filestatus = [];
    const myfiles = useFetch(`/papi/v1/pathology/review/${props.VRindex}`);
    if(myfiles){
      let sortedfiles = [...myfiles];
      sortedfiles.sort((a, b) => {
        if (a.good < b.good) {
          return -1;
        }
        if (a.good > b.good) {
          return 1;
        }
        return 0;
      });

        filestatus = sortedfiles.map((row, i) => {
          var status = "Unreviewed";
          if (row.good === true){
            status = "Good";
          }else if(row.good === false){
            status = "Bad";
          }
          return  <div key={i}> <tr><td> {row.file_name} </td> <td>{status}</td> </tr></div>
      });
    }



    return (
      <div>
          <div>
            <h1>Files as currently labeled</h1>
            <table>
            <tr><th>File</th><th>Status</th></tr>
              {filestatus}
            </table>
          </div>
      </div>
    );
  }


export default GBreport;
