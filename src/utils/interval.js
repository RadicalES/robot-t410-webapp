/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import { useEffect, useRef } from 'react';

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