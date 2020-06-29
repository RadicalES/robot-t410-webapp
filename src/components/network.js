/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect } from 'react';
import Fetcher from '../utils/fetcher'
import NetworkWired from './networkwired'
import NetworkWireless from './networkwireless'
import Validation from '../utils/validate'

const Network = () => {

    const [ NetRefresh, setNetRefresh ] = useState(0);
    const [ InView, setInView ] = useState(true);

    const [ WiredSettings, setWiredSettings ] = useState({
        name: "Wired",
        macAddress: "Waiting...",
        status: "ENABLED",
        dhcp: "FALSE",
        ipAddress: "192.168.1.20",
        netmask: "255.255.255.0",
        gateway: "192.168.0.1"
    })

    const [ WifiSettings, setWifiSettings ] = useState({
        name: "Wired",
        macAddress: "Waiting...",
        status: "ENABLED",
        dhcp: "FALSE",
        ipAddress: "192.168.1.20",
        netmask: "255.255.255.0",
        gateway: "192.168.0.1",
        SSID: "",
        passkey: ""
    })

    const udapteNetSettings = (data) => {
        const wifi = data.data.wifi;
        setWiredSettings(data.data.wired);
        wifi['SSID'] = data.data.wifiap.SSID;
        setWifiSettings(data.data.wifi);        
    }

    useEffect( () => {       
        if(InView) {
            Fetcher('/cgi/getnwk.sh', 'GET', "", (data) => { if(InView) udapteNetSettings(data) } );       
        }
    }, [NetRefresh])

    useEffect(() => {
        return () => {
            setInView(false);
        }
     }, [])

    const handleWiredChange = (field, value) => {
        const ws = WiredSettings;
        let er = false;

        if(field === 'dhcp') {
            ws[field] = value ? 'TRUE' : 'FALSE';
        }
        else {
            er = Validation.IPAddress(value);
            if(er === true) {
                ws[field] = value;
            }
        }
        
        setWiredSettings(ws);
        return er;
    }

    const handleWifiChange = (field, value) => {
        const ws = WifiSettings;
        let er = false;

        
        if(field === 'dhcp') {
            ws[field] = value ? 'TRUE' : 'FALSE';
        }
        else if(field === 'SSID') {
            ws[field] = value;
            er = true;
        }
        else if(field === 'passkey') {
            ws[field] = value;
            er = true;
        }
        else {
            er = Validation.IPAddress(value);
            if(er === true) {
                ws[field] = value;
            }
        }

        setWifiSettings(ws);
        return er;
    }

    const netSetResult = (result) => {        
        const { status } = result.data;        

        if(status === 'OK') {
            alert("Settings saved!");
        }
        else {
            alert("Failed to save!");
        }
    }

    const handleSubmit = (e) => {
        e.preventDefault();        
          
       const wificfg = 'wifi_ipaddr=' + WifiSettings.ipAddress + 
                        '&wifi_gateway=' + WifiSettings.gateway + 
                        '&wifi_netmask=' + WifiSettings.netmask +
                        '&wifi_dhcp=' + WifiSettings.dhcp + 
                        '&wifi_ssid=' + WifiSettings.SSID + 
                        (('passkey' in WifiSettings) ? ('&wifi_passkey=' + WifiSettings.passkey) : "") +
                        '&wifi_enable=ENABLED';

        const wiredcfg = 'wired_ipaddr=' + WiredSettings.ipAddress + 
                        '&wired_gateway=' + WiredSettings.gateway + 
                        '&wired_netmask=' + WiredSettings.netmask +
                        '&wired_dhcp=' + WiredSettings.dhcp;

        const data = wiredcfg + '&' + wificfg;

        Fetcher('/cgi/setnwk.sh', 'POST', data, netSetResult );

        return true;
    }

    const netResetResult = (result) => {        
        const { status } = result.data;        

        if(status === 'OK') {
            alert("Default network setting.\nRestart device to take effect.");
            let n = NetRefresh;
            n++;
            setNetRefresh(n);
        }
        else {
            alert("Failed to reset settings");
        }
    }

    const netRestartResult = (result) => {        
        const { status } = result.data;        

        if(status === 'OK') {
            alert("Network restarted!");
        }
        else {
            alert("Failed to restart");
        }
    }

    const handleNetReset = (e) => {
        Fetcher('/cgi/resetnwk.sh', 'POST', {}, netResetResult );
    }

    const handleNetRestart = (e) => {
        Fetcher('/cgi/restartnwk.sh', 'POST', {}, netRestartResult );
    }

    const handleNetRestartWifi = (e) => {
        Fetcher('/cgi/restartnwkwifi.sh', 'POST', {}, netRestartResult );
    }

    return (

    <div className="container content network-tabs">

        <ul className="nav nav-tabs" id="networkTab" role="tablist">
            <li className="nav-item">
                <a className="nav-link active" id="net-wired-tab" data-toggle="tab" href="#wired" role="tab" aria-controls="wired" aria-selected="true">Wired</a>
            </li>
            <li className="nav-item">
                <a className="nav-link" id="net-wireless-tab" data-toggle="tab" href="#wireless" role="tab" aria-controls="wireless" aria-selected="false">Wireless</a>
            </li>
        </ul>           

        <form onSubmit={handleSubmit} noValidate>
            <div className="tab-content tab-content-app" id="network-tab-content">
                <div className="tab-pane fade show active" id="wired" role="tabpanel" aria-labelledby="wired-tab">
                    <NetworkWired config={WiredSettings} handleChange={handleWiredChange}/>                
                </div>

                <div className="tab-pane fade" id="wireless" role="tabpanel" aria-labelledby="wireless-tab">
                    <NetworkWireless config={WifiSettings} handleChange={handleWifiChange}/>
                </div>

            </div>

            <button type="button" className="btn btn-secondary btn-sm appbtn" onClick={handleNetReset} >Reset</button>    
            <button type="submit" className="btn btn-secondary btn-sm appbtn">Save</button>
            <button type="button" className="btn btn-secondary btn-sm appbtn" onClick={handleNetRestart} >Restart Network</button>
            <button type="button" className="btn btn-secondary btn-sm appbtn" onClick={handleNetRestartWifi} >Restart Wifi</button>
        </form>

    </div>

    )

}

export default Network;