/* (C) 2020-2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React, { useState, useEffect } from 'react';
import Fetcher from '../utils/fetcher'
import NetworkWired from './networkwired'
import NetworkWireless from './networkwireless'
import Validation from '../utils/validate'
import { useActionData, useLoaderData } from 'react-router-dom';
import { Alert, Button, Container, Form, Spinner, Tab, Tabs } from 'react-bootstrap';
import useFormData from '../hooks/useFormData';

const Network = () => {
    const NetworkInfo = useLoaderData()
    const ActionData = useActionData()
    const [ wiredValues, setWiredValues, handleWiredChange ] = useFormData(NetworkInfo?.data?.wired || {
        name: "Wired",
        macAddress: "Waiting...",
        status: "ENABLED",
        dhcp: "FALSE",
        ipAddress: "192.168.1.20",
        gateway: "192.168.0.1",
        dns: "192.168.0.1"
    } )

    const [ wirelessValues, setWirelessValues, handleWirelessChange ] = useFormData(NetworkInfo?.data?.wifi || {
        name: "Wireless",
        macAddress: "Waiting...",
        status: "ENABLED",
        dhcp: "FALSE",
        ipAddress: "192.168.1.20",
        gateway: "192.168.0.1",
        dns: "192.168.0.1",
        SSID: "",
        passkey: ""
    })


    console.log("NetInfo: ", NetworkInfo)


    const netSetResult = (result) => {        
        const { status } = result.data;        

        if(status === 'OK') {
            alert("Settings saved!");
        }
        else {
            alert("Failed to save!");
        }
    }

    const handleSubmit = (event) => {
          
        event.preventDefault();
          
    //    const wificfg = 'wifi_ipaddr=' + WifiSettings.ipAddress + 
    //                     '&wifi_gateway=' + WifiSettings.gateway + 
    //                     '&wifi_dhcp=' + WifiSettings.dhcp + 
    //                     '&wifi_dns=' + WifiSettings.dns + 
    //                     '&wifi_ssid=' + WifiSettings.SSID + 
    //                     (('passkey' in WifiSettings) ? ('&wifi_passkey=' + WifiSettings.passkey) : "") +
    //                     '&wifi_enable=ENABLED';

        const wiredcfg = 'wired_ipaddr=' + wiredValues.ipAddress + 
                        '&wired_gateway=' + wiredValues.gateway + 
                        '&wired_dns=' + wiredValues.dns + 
                        '&wired_dhcp=' + wiredValues.dhcp;

        const wificfg = ''

        const data = wiredcfg + '&' + wificfg;

        console.log("SET NWK: ", data)

      //  Fetcher('/cgi/setnwk.sh', 'POST', data, netSetResult );

        //return true;
    }

    const netResetResult = (result) => {        
        const { status } = result.data;        

        if(status === 'OK') {
            alert("Default network setting.\nRestart device to take effect.");
            let n = 0;//NetRefresh;
            n++;
           // setNetRefresh(n);
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
   <Container className="content">

        <Form noValidate onSubmit={handleSubmit}  >
            <Tabs 
                id="networkTab" 
                defaultActiveKey="wired"
            >
                    <Tab eventKey="wired" title="Wired">
                        <NetworkWired config={wiredValues} handleChange={handleWiredChange}/>                
                    </Tab>

                    <Tab eventKey="wireless" title="Wireless">
                        <NetworkWireless config={wirelessValues} handleChange={handleWirelessChange}/>
                    </Tab>

            </Tabs>
  
            <Button variant="danger" size="sm" className="me-2" onClick={handleNetReset} >Reset</Button>    
            <Button variant="outline-primary" type="submit" size="sm" className="me-2">Save</Button>
            <Button variant="warning" size="sm" onClick={handleNetRestart} className="me-2">Restart Network</Button>
            <Button variant="warning" size="sm" onClick={handleNetRestartWifi} className="me-2">Restart Wifi</Button>
        </Form>

        <Alert variant='success' >
            {ActionData && ActionData.status && <p>{ActionData.status}</p>}
            {ActionData && ActionData.error && <p>{ActionData.error}</p>}
        </Alert>

    </Container>

    )

}

// loader function
export const networkLoader = async () => {
    const data = await Fetcher('/cgi/getnwk.sh', 'GET');
    return data;
}

export const networkSaveAction = async ( { request }) => {
    const data = await request.formData();
    const submission = {

    }
    console.log(data)

    return {
        status: "OK",
        error: ""
    }
}

export default Network;