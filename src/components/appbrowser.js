/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect, useRef } from 'react';

const AppBrowser = ({ config, handleChange }) => {
    const appUrl = useRef();
    const appLayout = useRef();
    const [ Updated, setUpdated] = useState(0);
    const [ UrlStyle, setUrlStyle] = useState({ borderColor: "" });

    useEffect( () => {
        if(Updated < 2) {
            appUrl.current.value = config.appurl;
            appLayout.current.value = config.layout;
            setUpdated(Updated + 1);
        }        

    }, [config])

    const changeErrorStyle = (error) => {
        let s = {borderColor: ""};

        if(error === false) {            
            s = {borderColor: "red"};
        }

        setUrlStyle(s);       
    }

    return ( 
        <div className="network-content">            
            
                <div className="form-group app-group">                
                    <label htmlFor="wapURL" className="col-form-label col-form-label-sm applabel">Startup URL:</label>
                    <input type="url" className="form-control form-control-sm appurl" id="wapURL"                        
                        onChange={( (e) => { const err = handleChange('appurl', e.target.value); changeErrorStyle(err);})}
                        style={UrlStyle}
                        ref={appUrl}
                        />
                </div>            

                <div className="form-group app-group">                    
                    <label className="col-form-label col-form-label-sm applabel" htmlFor="applayout">Layout:</label>
                    <select className="custom-select appselect" id="applayout"
                        ref={appLayout}
                        onChange={(e) => { handleChange('layout', e.target.value)}}
                        >
                        <option value="portrait">Portrait</option>
                        <option value="landscape">Landscape</option>
                    </select>
                </div>

        </div>

    )
}

export default AppBrowser;

