import React, { useState, useEffect, useRef } from 'react';
import Fetcher from '../utils/fetcher'
import useInterval from '../utils/interval'

const NetworkWireless = ( { config, handleChange } ) => {

    const netWifiDHCP = useRef();
    const netWifiMAC = useRef();
    const netWifiIp = useRef();
    const netWifiNm = useRef();
    const netWifiGw = useRef();
    const netWifiSsid = useRef();

    const netWifiApMAC = useRef();
    const netWifiFreq = useRef();
    const netWifiLink = useRef();
    const netWifiSignal = useRef();

    const [ Updated, setUpdated] = useState(0);
    const [ Period, setPeriod] = useState(0);
    const [ WifiApData, setWifiApData] = useState({
        status: "OK",
        APMAC: "Not set",
        frequency: "",
        linkqualtiy: "",
        signallevel: ""
    });

    const [ NetWifiIpStyle, setNetWifiIpStyle] = useState({ borderColor: "" });
    const [ NetWifiNmStyle, setNetWifiNmStyle] = useState({ borderColor: "" });
    const [ NetWifiGwStyle, setNetWifiGwStyle] = useState({ borderColor: "" });
    const [ NetWifiKeyStyle, setNetWifiKeyStyle] = useState({ borderColor: "" });

     useInterval( () => {
        Fetcher('/getwifidata.sh', 'GET', "", (data) => { setWifiApData(data.data) });
    }, Period)

    useEffect( () => {        
        let inView = true;

        if(inView) {
            netWifiApMAC.current.innerHTML = WifiApData.APMAC;
            //netWifiESSID.current.innerHTML = data.data.ESSID;
            netWifiFreq.current.innerHTML = WifiApData.frequency;
            netWifiLink.current.innerHTML = WifiApData.linkquality;
            netWifiSignal.current.innerHTML = WifiApData.signallevel;
        }

        return () => { inView = false;}
    }, [WifiApData])

    useEffect( () => {     
        let c = Updated;

        if(Updated < 2) {
            if(config.status && config.status === 'ENABLED') {
                netWifiDHCP.current.checked = config.dhcp === "TRUE";
                netWifiMAC.current.innerHTML = config.macAddress;
                netWifiIp.current.value = config.ipAddress;            
                netWifiNm.current.value = config.netmask;
                netWifiGw.current.value = config.gateway;
                netWifiSsid.current.value = config.SSID;

                if(config.dhcp === "TRUE") {
                    netWifiIp.current.readOnly = true;
                    netWifiNm.current.readOnly = true;
                    netWifiGw.current.readOnly = true;
                }
                c = c + 1;
                setUpdated(c);
            }
            else {
                netWifiMAC.current.innerHTML = "Not installed"
                netWifiIp.current.readOnly = true;
                netWifiNm.current.readOnly = true;
                netWifiGw.current.readOnly = true;
            }

            // wait until view has relevant data
            if(c === 2) {
                setPeriod(1000);
            }
        }
     }, [config])

     const changeErrorStyle = (field, error) => {
        let s = {borderColor: ""};

        if(error === false) {            
            s = {borderColor: "red"};
        }

        if(field === 'ipAddress') {
            setNetWifiIpStyle(s);
        }
        else if(field === 'netmask') {
            setNetWifiNmStyle(s);
        }
        else if(field == 'gateway') {
            setNetWifiGwStyle(s);
        }       
        else if(field === 'passkey') {
            setNetWifiKeyStyle(s);
        }        

    }    

    const handleDHCPChange = (state) => {
        if(state === true) {
            netWifiIp.current.readOnly = true;
            netWifiNm.current.readOnly = true;
            netWifiGw.current.readOnly = true;
        }
        else {
            netWifiIp.current.readOnly = false;
            netWifiNm.current.readOnly = false;
            netWifiGw.current.readOnly = false;
        }
        handleChange('dhcp', state)
    }
   
    return ( 

        <div className="network-content">      
            <div className="form-group app-group">
                <div className="custom-control custom-switch">                    
                    <input className="custom-control-input" type="checkbox" id="netwifidhcp"
                        ref={netWifiDHCP}
                        onChange={(e) => { handleDHCPChange(e.target.checked)}}  
                        />
                    <label htmlFor="netwifidhcp" className="custom-control-label col-form-label-sm">DHCP</label>                    
                </div>
            </div>
        
            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">MAC Address:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiMAC} ></label>                    
            </div>
            <div className="form-group app-group">
                <label htmlFor="wireless_ipaddress" className="col-form-label col-form-label-sm applabel">IP Address:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wireless_ipaddress"
                    onChange={ (e) => { const er = handleChange( "ipAddress", e.target.value); changeErrorStyle('ipAddress', er) }}
                    style={NetWifiIpStyle}
                    ref={netWifiIp}                
                />                    
            </div>
            <div className="form-group app-group">
                <label htmlFor="wireless_netmask" className="col-form-label col-form-label-sm applabel">Subnet Mask:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wireless_netmask" 
                    onChange={ (e) => {const er = handleChange( "netmask", e.target.value); changeErrorStyle('netmask', er)}}
                    style={NetWifiNmStyle}
                    ref={netWifiNm}
                />                    
            </div>
            <div className="form-group app-group">
                <label htmlFor="wireless_gateway" className="col-form-label col-form-label-sm applabel">Default Gateway:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wireless_gateway" 
                    onChange={ (e) => {const er = handleChange( "gateway", e.target.value); changeErrorStyle('gateway', er)}}
                    style={NetWifiGwStyle}
                    ref={netWifiGw}                
                />                    
            </div>

            <div className="form-group app-group">
                <label htmlFor="wifi-ssid" className="col-form-label col-form-label-sm applabel">AP SSID:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wifi-ssid"
                    onChange={ (e) => {handleChange( "SSID", e.target.value)}}
                    ref={netWifiSsid} 
                />                    
            </div>

            <div className="form-group app-group">
                <label htmlFor="wifi-passkey" className="col-form-label col-form-label-sm applabel">Passkey:</label>
                <input type="text" className="form-control form-control-sm appipmac" id="wifi-passkey"
                    onChange={ (e) => {const er = handleChange( "passkey", e.target.value); changeErrorStyle('passkey', er)}}
                    style={NetWifiKeyStyle}
                />                    
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">AP MAC:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiApMAC}>Not set</label>
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">Frequency:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiFreq}>Not set</label>                    
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">Link Quality:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiLink}>Not set</label>
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">Signal Level:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiSignal}>Not set</label>
            </div>
        </div>
   )
}

export default NetworkWireless;