/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect, useRef } from 'react';

const NetworkWired = ({ config, handleChange }) => {

    const netWiredDHCP = useRef();
    const netWiredMAC = useRef();
    const netWiredIp = useRef();
    const netWiredNm = useRef();
    const netWiredGw = useRef();
   
    const [ Updated, setUpdated] = useState(0);
    const [ NetWiredIpStyle, setNetWiredIpStyle] = useState({ borderColor: "" });
    const [ NetWiredNmStyle, setNetWiredNmStyle] = useState({ borderColor: "" });
    const [ NetWiredGwStyle, setNetWiredGwStyle] = useState({ borderColor: "" });

    console.log("NET CONFIG:", config)

    useEffect( () => {        
        if(Updated < 2) {
            netWiredDHCP.current.checked = config.dhcp === "TRUE";
            netWiredMAC.current.innerHTML = config.macAddress;
            netWiredIp.current.value = config.ipAddress;            
            netWiredGw.current.value = config.gateway;

            if(config.dhcp === "TRUE") {
                netWiredIp.current.readOnly = true;
                netWiredGw.current.readOnly = true;
            }

            setUpdated(Updated + 1);
        }
     }, [config])

    const changeErrorStyle = (field, error) => {
        let s = {borderColor: ""};

        if(error === false) {            
            s = {borderColor: "red"};
        }

        if(field === 'ipAddress') {
            setNetWiredIpStyle(s);
        }
        else if(field === 'netmask') {
            setNetWiredNmStyle(s);
        }
        else {
            setNetWiredGwStyle(s);
        }       
    }    

    const handleDHCPChange = (state) => {
        if(state === true) {
            netWiredIp.current.readOnly = true;
            netWiredGw.current.readOnly = true;
        }
        else {
            netWiredIp.current.readOnly = false;
            netWiredGw.current.readOnly = false;
        }

        handleChange('dhcp', state)
    }

    return ( 

    <div className="network-content">        

            <div className="form-group app-group">
                <div className="custom-control custom-switch">                    
                    <input className="custom-control-input" type="checkbox" id="netwireddhcp"
                        ref={netWiredDHCP}
                        onChange={(e) => { handleDHCPChange(e.target.checked)}}  
                        />
                    <label htmlFor="netwireddhcp" className="custom-control-label col-form-label-sm">DHCP</label>                    
                </div>
            </div>
        
            <div className="form-group app-group">
                <label htmlFor="wired_macaddress" className="col-form-label col-form-label-sm applabel">MAC Address:</label>
                <label className="form-control form-control-sm appipmac readonly-field" 
                    ref={netWiredMAC}>                    
                </label>
            </div>
            <div className="form-group app-group">
                <label htmlFor="wired_ipaddress" className="col-form-label col-form-label-sm applabel">IP Address:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wired_ipaddress"                 
                        onChange={ (e) => { const er = handleChange( "ipAddress", e.target.value); changeErrorStyle('ipAddress', er) }}
                        style={NetWiredIpStyle}
                        ref={netWiredIp}
                />
            </div>
            <div className="form-group app-group">
                <label htmlFor="wired_gateway" className="col-form-label col-form-label-sm applabel">Default Gateway:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wired_gateway" 
                    onChange={ (e) => {const er = handleChange( "gateway", e.target.value); changeErrorStyle('gateway', er)}}
                    style={NetWiredGwStyle}
                    ref={netWiredGw}
                />                    
            </div>
    </div>


    )

}

export default NetworkWired;
