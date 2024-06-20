/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import { Button, Card, Form } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';
import WirelessConfig from '../components/WirelessConfig';
import { useEffect, useRef, useState } from 'react';

const WirelessPage = () => {
    const data = useLoaderData()
    const status = data?.data?.status === 'OK' || false
    const [ config, setConfig, handleConfigChange ] = useFormData(data?.data || {
        name: "Wireless",
        macaddr: "Waiting...",
        enabled: "false",
        dhcp: "false",
        ipaddr: "192.168.1.20",
        gateway: "192.168.0.1",
        dns: "192.168.0.1",
        ssid: "",
        passkey: ""
    } )

    const DataWs = useRef(null);

    const [ apData, setApData] = useState({
            accessPoint : "Not set",
            frequency : "",
            quality : "",
            signalLevel : "",
            bitRate: "",
    });

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
            console.log("WIFI WS ERROR: ", err)
            //DataWs.current.close();
        }

        DataWs.current.onmessage = evt => {
            const d = JSON.parse(evt.data);            
            if ('wifiData' in d) {
                setApData(d['wifiData']);         
            }
        }
    }

    useEffect(() => {
        connectWifiData()
        return () => {
            const ws = DataWs.current;                        
            if(ws && ws.readyState != WebSocket.CLOSED ) {
                ws.close();
            }
        }
     }, [])

    const handleSubmit = (e) => {
        e.preventDefault();

        console.log("WIFI SETTINGS: ", config)

        const payload = 'enabled=' + config.enabled + 
        '&ipaddr=' + config.ipaddr + 
        '&gateway=' + config.gateway + 
        '&netmask=' + (config.netmask === undefined ? '255.255.255.0' : config.netmask) +
        '&dhcp=' + config.dhcp + 
        '&dns=' + config.dns + 
        '&ssid=' + config.ssid + 
        '&passkey=' + config.passkey;

        Fetcher('cgi/setwifi.sh', 'POST', payload)
        .then((resp) => {
            const { status } = resp;

            if(status === 'OK') {
                alert("Wifi settings saved!");
            }
            else {
                alert("Failed to save Wifi settings!");
            }

        })
        
        return true;
    }

    const handleReset = (e) => {
        e.preventDefault();
    }

    const handleRestart = (e) => {
        e.preventDefault();
    }

    const handleWifiRestart = (e) => {
        e.preventDefault();
    }

   // console.log("WIFI STATUS: ", status);

    return (

        <Card className="content">
            <Card.Body>
                <Card.Title>Wifi Settings</Card.Title>
                <Form noValidate onSubmit={handleSubmit} className='mt-2 mb-2'>
                    <WirelessConfig config={config} apData={apData} handleChange={handleConfigChange} />            
                    <Button variant="outline-primary" type="submit" size="sm" className="me-2">Save</Button>
                    <Button variant="danger" size="sm" className="me-2" onClick={handleReset} >Reset</Button>    
                    <Button variant="warning" size="sm" onClick={handleRestart} className="me-2">Restart Network</Button>
                    <Button variant="warning" size="sm" onClick={handleWifiRestart} className="me-2">Restart Wifi</Button>
                </Form>
                
            </Card.Body>
        </Card>
    );

}



// loader function
export const wirelessLoader = async () => {
    const data = await Fetcher('/cgi/getwifi.sh', 'GET');
    return data;
}

export default WirelessPage;