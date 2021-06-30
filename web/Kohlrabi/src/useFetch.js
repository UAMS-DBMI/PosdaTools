import { useState, useEffect } from "react";

export const useFetch = url => {
  const [data, setData] = useState(null);

  useEffect(() => {
    async function fetchData(){
      const response = await fetch(url);
      if(!response.ok){
        console.log("bad response from server");
        return;
      }

      const json = await response.json();
      setData(json);
    }
    fetchData();
  }, [url]);
  return data;
}
