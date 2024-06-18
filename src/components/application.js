/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import React, { useState, useEffect } from 'react';
import Fetcher from '../utils/fetcher'
import AppConfig from './AppConfiguration'
import AppTelemetry from './apptelemetry'
import Validation from '../utils/validate'
import { useLoaderData } from 'react-router-dom';
import { Button, Container, Form, Tab, Tabs } from 'react-bootstrap';
import useFormData from '../hooks/useFormData';

const Application = () => {
    const ApplicationInfo = useLoaderData()
    const [ serverConfig, setServerConfig, handleServerChange ] = useFormData(ApplicationInfo?.data?.server || {
        serverurl: "Waiting..."
    })

    const [ telemetryConfig, setTelemetryConfig, handleTelemetryChange ] = useFormData(ApplicationInfo?.data?.telemetry || {
        enabled: "FALSE",
        broker: "Waiting...",
        port: 1883,
        pubtopic: "",
        username: "",
        password: ""
    })

    const handleBrowserChange = (field, value) => {
        // const bs = BrowserSettings;
        // let er = false;

        // if(field === 'appurl') {
        //     er = Validation.UrlCheck(value);
        //     if(er === true) {
        //         bs[field] = value;    
        //     }
        // }
        // else {
        //     bs[field] = value;
        // }

        // setBrowserSettings(bs);

        // return er;
    }

    const handleTelemetryChanged = (field, value) => {
        //const ts = TelemetrySettings;
        // let er = false;

        // if(field === 'port') {
        //     er = Validation.Numericality(value, {minimum: 1000, maximum: 65535});
        //     if(er === true) {
        //         ts[field] = parseInt(value);
        //     }
        // } 
        // else if(field === 'enabled') {
        //     ts[field] = value ? 'TRUE' : 'FALSE';
        // }
        // else if(field === 'broker') {
        //     er = Validation.IPAddress(value);
        //     if(er === true) {
        //         ts[field] = value;
        //     }
        // }
        // else if(field === 'pubtopic') {            
        //     ts[field] = value;
        // }
        // else if(field === 'username') {            
        //     ts[field] = value;
        // }
        // else if(field === 'password') {            
        //     ts[field] = value;
        // }
        
        // setTelemetrySettings(ts);
        // return er;
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

        // const aps = 'appurl=' + BrowserSettings.appurl +
        //             '&layout=' + BrowserSettings.layout;

        // const tels = 'telen=' + TelemetrySettings.enabled + 
        //             '&telbroker=' + TelemetrySettings.broker + 
        //             '&telport=' + TelemetrySettings.port + 
        //             '&teluser=' + TelemetrySettings.username + 
        //             '&telpasswd=' + TelemetrySettings.password + 
        //             '&telpubtopic=' + TelemetrySettings.pubtopic;

        // const sws = 'srlwsen=' + SerialWSSettings.enabled + 
        //             '&srlwsports=' + SerialWSSettings.serialport + 
        //             '&srlwsbaud=' + SerialWSSettings.baudrate + 
        //             '&srlwsportn=' + SerialWSSettings.socketport + 
        //             '&srlwsforeign=' + SerialWSSettings.allowforeign;
        // const data = aps + '&' + sws + '&' + tels;

        // Fetcher('/cgi/setapp.sh', 'POST', data, appSetResult );
        // return true;
    }

    return (   
        <Container className="content">
            <Form noValidate onSubmit={handleSubmit}>
                <AppConfig config={serverConfig} handleChange={handleServerChange} />            
                <Button variant="outline-primary" type="submit" size="sm" className='me-2'>Save</Button>
            </Form>
        </Container>
    )

}

// loader function
export const applicationLoader = async () => {
    const data = await Fetcher('/cgi/getapp.sh', 'GET');
    return data;
}

export default Application;