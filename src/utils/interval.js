import React, { useEffect, useRef } from 'react';

const useInterval = (callback, delay) => {
    const savedCallback = useRef();
  
    useEffect(() => {
      savedCallback.current = callback;
    });
  
    useEffect(() => {

      const tick = () => {
        savedCallback.current();
      }
  
      if(delay && delay > 0 ) {
        let id = setInterval(tick, delay);
        return () => clearInterval(id);
      }
    }, [delay]);

}

export default useInterval;