/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect } from 'react';
import Fetcher from '../utils/fetcher'
import AppBrowser from './appbrowser'
import AppTelemetry from './apptelemetry'
import AppSerialWS from './appserialws'
import Validation from '../utils/validate'

const Application = () => {

    const [ BrowserSettings, setBrowserSettings ] = useState({
        appurl: "Waiting...",
        layout: "portrait"
    })

    const [ TelemetrySettings, setTelemetrySettings ] = useState({
        enabled: "FALSE",
        broker: "Waiting...",
        port: 1883,
        pubtopic: ""
    })

    const [ SerialWSSettings, setSerialWSSettings ] = useState({
        enabled: "FALSE",
        serialport: "",
        baudrate: 9600,
        socketport: 0,
        allowforeign: "FALSE"
    })

    const udapteAppSettings = (data) => {
        setBrowserSettings(data.data.browser);
        setTelemetrySettings(data.data.telemetry);
        setSerialWSSettings(data.data.serialws);
    }

    useEffect( () => {
        let inView = true;
        Fetcher('/cgi/getapp.sh', 'GET', "", (data) => { if(inView) udapteAppSettings(data) } );
        return () => { inView = false; }
    }, [])

    const handleBrowserChange = (field, value) => {
        const bs = BrowserSettings;
        let er = false;

        if(field === 'appurl') {
            er = Validation.UrlCheck(value);
            if(er === true) {
                bs[field] = value;    
            }
        }
        else {
            bs[field] = value;
        }

        setBrowserSettings(bs);

        return er;
    }

    const handleTelemetryChange = (field, value) => {
        const ts = TelemetrySettings;
        let er = false;

        if(field === 'port') {
            er = Validation.Numericality(value, {minimum: 1000, maximum: 65535});
            if(er === true) {
                ts[field] = parseInt(value);
            }
        } 
        else if(field === 'enabled') {
            ts[field] = value ? 'TRUE' : 'FALSE';
        }
        else if(field === 'broker') {
            er = Validation.IPAddress(value);
            if(er === true) {
                ts[field] = value;
            }
        }
        else if(field === 'pubtopic') {            
            ts[field] = value;
        }
        
        setTelemetrySettings(ts);
        return er;
    }

    const handleSerialWSChange = (field, value) => {
        const sws = SerialWSSettings;
        let er = false;

        if(field === 'socketport') {
            er = Validation.Numericality(value, {minimum: 1000, maximum: 65535});
            if(er === true) {
                sws[field] = parseInt(value);
            }
        }            
        else if(field === 'badurate') {
            sws[field] = parseInt(value);
        } 
        else if((field === 'enabled') || (field === 'allowforeign')) {
            sws[field] = value ? 'TRUE' : 'FALSE';
        }
        else {
            sws[field] = value;
        }

        setSerialWSSettings(sws);
        return er;
    }

    const appSetResult = (result) => {        
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

        const aps = 'appurl=' + BrowserSettings.appurl +
                    '&layout=' + BrowserSettings.layout;

        const tels = 'telen=' + TelemetrySettings.enabled + 
                    '&telbroker=' + TelemetrySettings.broker + 
                    '&telport=' + TelemetrySettings.port + 
                    '&telpubtopic=' + TelemetrySettings.pubtopic;

        const sws = 'srlwsen=' + SerialWSSettings.enabled + 
                    '&srlwsports=' + SerialWSSettings.serialport + 
                    '&srlwsbaud=' + SerialWSSettings.baudrate + 
                    '&srlwsportn=' + SerialWSSettings.socketport + 
                    '&srlwsforeign=' + SerialWSSettings.allowforeign;
        const data = aps + '&' + sws + '&' + tels;

        Fetcher('/cgi/setapp.sh', 'POST', data, appSetResult );
        return true;
    }

    const handleTestWS = (e) => {
        alert("Not implemented")
    }

    return (   
            <div className="container content network-tabs">
                <ul className="nav nav-tabs" id="applicationTab" role="tablist">
                    <li className="nav-item">
                        <a className="nav-link active" id="app-browser-tab" data-toggle="tab" href="#browser" role="tab" aria-controls="browser" aria-selected="true">Browser</a>
                    </li>
                    <li className="nav-item">
                        <a className="nav-link" id="napp-telemetry-tab" data-toggle="tab" href="#telemetry" role="tab" aria-controls="telemetry" aria-selected="false">Telemetry</a>
                    </li>
                    <li className="nav-item">
                        <a className="nav-link" id="napp-websock-tab" data-toggle="tab" href="#websock" role="tab" aria-controls="websock" aria-selected="false">Serial WS</a>
                    </li>

                </ul>           

                
                <form onSubmit={handleSubmit} noValidate>
                    <div className="tab-content tab-content-app" id="network-tab-content">
                    
                        <div className="tab-pane fade show active" id="browser" role="tabpanel" aria-labelledby="browser-tab">
                            <AppBrowser config={BrowserSettings} handleChange={handleBrowserChange}/>                
                        </div>
                    
                        <div className="tab-pane fade show" id="telemetry" role="tabpanel" aria-labelledby="telemetry-tab">
                            <AppTelemetry config={TelemetrySettings} handleChange={handleTelemetryChange} />                
                        </div>

                        <div className="tab-pane fade show" id="websock" role="tabpanel" aria-labelledby="websock-tab">
                            <AppSerialWS config={SerialWSSettings} handleChange={handleSerialWSChange} />
                        </div>

                    </div>

                    <input type="submit" className="btn btn-secondary btn-sm appbtn" value="Save Settings" />
                    <button type="button" className="btn btn-secondary btn-sm appbtn" onClick={handleTestWS}>Test Websocket</button>            
                </form>

        </div>

    )

}

export default Application;