import React from 'react';
import { Link } from 'react-router-dom';

export default function Home() {
  const iecExamples = {
    "A torso and a sliver": 1,
    "A nice torso": 2,
    "A grotesque abomination": 3,
    "A head and a tennis racket": 98738,
    "A perfect head": 98739,
    "A full body (man)": 98740,
    "A face without the top of the head": 98742,
    "A second full body (same man?)": 98745,
    "A third full body (woman, with glasses)": 98746,
    "Extremely large full body (man)": 98748,
  };

  return (
	  <div>
	  <h1>Welcome</h1>
	  
    <h2>Examples (all direct IECs)</h2>
	  <ul>
      {Object.entries(iecExamples).map((entry) => (
        <li>
            <Link to={`/mask/iec/${entry[1]}`}>{entry[0]}</Link>
        </li>
      ))}
	  </ul>

    <h2>Old example links</h2>
	  <ul>
      <li>
          <Link to={`/mask/iec/3`}>Example Mask IEC</Link>
      </li>
      <li>
          <Link to={`/mask/vr/1`}>Example Mask VR</Link>
      </li>
	  </ul>


	  </div>
  );
}
