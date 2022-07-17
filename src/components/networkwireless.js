/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect, useRef } from 'react';
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
    const netWifiBitRate = useRef();
    const DataWs = useRef(null);

    const [ Updated, setUpdated] = useState(0);
    const [ InView, setInView] = useState(false);
    const [ WifiApData, setWifiApData] = useState({
        wifiConfig : {
            accessPoint : "Not set",
            frequency : ""
        },
        wifiLinkStatistics : {
            quality : "",
            signalLevel : ""
        }
    });

    const [ NetWifiIpStyle, setNetWifiIpStyle] = useState({ borderColor: "" });
    const [ NetWifiNmStyle, setNetWifiNmStyle] = useState({ borderColor: "" });
    const [ NetWifiGwStyle, setNetWifiGwStyle] = useState({ borderColor: "" });
    const [ NetWifiKeyStyle, setNetWifiKeyStyle] = useState({ borderColor: "" });

    const connectWifiData = () => {
        let { hostname } = window.location;   
        
        if (process.env.NODE_ENV === 'development' && process.env.REACT_APP_WSPROXYIP) {
            hostname = process.env.REACT_APP_WSPROXYIP;
            if (process.env.REACT_APP_WSPROXYPORT) {
                hostname += `:${process.env.REACT_APP_WSPROXYPORT}`;
            }
        }

        const url = 'ws://' + hostname + ':7000/';        
        DataWs.current = new WebSocket(url);
        
        DataWs.current.onopen = () => {
        }

        DataWs.current.onclose = e => {
        }

        DataWs.current.onerror = err => {
            DataWs.current.close();
        }

        DataWs.current.onmessage = evt => {
            const d = JSON.parse(evt.data);            
            if ( ('wifiConfig' in d) && ('wifiLinkStatistics' in d) ) {
                setWifiApData(d);         
            }
        }
    }

    useEffect( () => {         
        if(InView) {       
            netWifiApMAC.current.innerHTML = WifiApData.wifiConfig.accessPoint;
            netWifiFreq.current.innerHTML = WifiApData.wifiConfig.frequency;
            netWifiLink.current.innerHTML = WifiApData.wifiLinkStatistics.quality;
            netWifiSignal.current.innerHTML = WifiApData.wifiLinkStatistics.signalLevel;
            netWifiBitRate.current.innerHTML = WifiApData.wifiConfig.bitRate;
        }
    }, [WifiApData])

    useEffect( () => {     
        let c = Updated;

        if(Updated < 2) {
            if(config.status && config.status === 'ENABLED') {
                netWifiDHCP.current.checked = config.dhcp === "TRUE";
                netWifiMAC.current.innerHTML = config.macAddress;
                netWifiIp.current.value = config.ipAddress;            
                netWifiGw.current.value = config.gateway;
                netWifiSsid.current.value = config.SSID;

                if(config.dhcp === "TRUE") {
                    netWifiIp.current.readOnly = true;
                    netWifiGw.current.readOnly = true;
                }
                c = c + 1;
                setUpdated(c);
            }
            else {
                netWifiMAC.current.innerHTML = "Not installed"
                netWifiIp.current.readOnly = true;
                netWifiGw.current.readOnly = true;
            }

            // wait until view has relevant data
            if(c === 2) {
                setInView(true);                
                connectWifiData();
            }            
        }

        
     }, [config])

    useEffect(() => {
        return () => {
            setInView(false);
            const ws = DataWs.current;                        
            if(ws && ws.readyState != WebSocket.CLOSED ) {
                ws.close();
            }
        }
     }, [])

     const changeErrorStyle = (field, error) => {
        let s = {borderColor: ""};

        if(error === false) {            
            s = {borderColor: "red"};
        }

        if(field === 'ipAddress') {
            setNetWifiIpStyle(s);
        }
        else if(field === 'gateway') {
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
                <input type="password" className="form-control form-control-sm appipmac" id="wifi-passkey" autoComplete="off"
                    onChange={ (e) => {const er = handleChange( "passkey", e.target.value); changeErrorStyle('passkey', er)}}
                    style={NetWifiKeyStyle}
                />                    
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">AP MAC:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiApMAC}>Not set</label>
            </div>

            <div className="form-group app-group">
                <label className="col-form-label col-form-label-sm applabel">Bit Rate:</label>
                <label className="form-control form-control-sm appipmac readonly-field" ref={netWifiBitRate}>Not set</label>                    
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