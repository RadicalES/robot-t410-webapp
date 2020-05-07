/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect, useRef } from 'react';

const AppSerialWS= ({ config, handleChange }) => {
    const appSWSenable = useRef();
    const appSWSsport= useRef();
    const appSWSwport = useRef();
    const appSWSbaud = useRef();
    const appSWSforeign = useRef();

    const [ Updated, setUpdated] = useState(0);
    const [ PortStyle, setPortStyle] = useState({ borderColor: "" });

    useEffect( () => {        
       if(Updated < 2) {
           appSWSenable.current.checked = config.enabled === "TRUE";
           appSWSsport.current.value = config.serialport;
           appSWSbaud.current.value = config.baudrate;
           appSWSwport.current.value = config.socketport;
           appSWSforeign.current.value = config.allowforeign === "TRUE";
           setUpdated(Updated + 1);
       }
    }, [config])


    const changeErrorStyle = (error) => {
        let s = {borderColor: ""};

        if(error === false) {            
            s = {borderColor: "red"};
        }
        
        setPortStyle(s);       
    }

    return ( 
        <div className="network-content">            
                
            <div className="form-group app-group">
                <div className="custom-control custom-switch">                    
                    <input className="custom-control-input" type="checkbox" id="srlwssvrcb"
                        ref={appSWSenable}
                        onChange={(e) => { handleChange('enabled', e.target.checked)}}  
                        />
                    <label htmlFor="srlwssvrcb" className="custom-control-label col-form-label-sm">Enable Server</label>                    
                </div>
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel" htmlFor="serialport">Serial Port:</label>
                <select className="custom-select appselect" id="serialport"
                    ref={appSWSsport}
                    onChange={(e) => { handleChange('serialport', e.target.value)}}
                    >
                    <option value="ttyS1">Port 1</option>
                    <option value="ttyS2">Port 2</option>
                </select>
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel" htmlFor="serialbaud">Baud Rate:</label>
                <select className="custom-select appselect form-control-sm" id="serialbaud"
                    ref={appSWSbaud}
                    onChange={(e) => { handleChange('baudrate', e.target.value)}}
                    >
                    <option value="1200">1200</option>
                    <option value="2400">2400</option>
                    <option value="4800">4800</option>
                    <option value="9600">9600</option>
                    <option value="19200">19200</option>
                    <option value="38400">38400</option>
                    <option value="57600">57600</option>
                    <option value="115200">115200</option>
                </select>
            </div>

            <div className="form-group app-group">
                <label htmlFor="serialwsport" className="col-form-label col-form-label-sm applabel">Socket Port:</label>
                <input type="number" className="form-control form-control-sm appselect" id="serialwsport" min="100" max="65535"
                    ref={appSWSwport}
                    style={PortStyle}
                    onChange={( (e) => { const err= handleChange('socketport', e.target.value); changeErrorStyle(err) })}
                    />
            </div>

            <div className="form-group app-group">
                <div className="custom-control custom-switch">                    
                    <input className="custom-control-input" type="checkbox" 
                        ref={appSWSforeign}
                        onChange={( (e) => { handleChange('allowforeign', e.target.checked)})} id="srlwsforeign" />
                    <label htmlFor="srlwsforeign" className="custom-control-label col-form-label-sm">Allow Foreign Connections</label>                    
                </div>
            </div>           
        </div>

    )
}

export default AppSerialWS;