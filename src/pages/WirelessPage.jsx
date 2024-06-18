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
        macAddress: "Waiting...",
        enabled: "false",
        dhcp: "false",
        ipAddress: "192.168.1.20",
        gateway: "192.168.0.1",
        dns: "192.168.0.1",
        SSID: "",
        passkey: ""
    } )

    const DataWs = useRef(null);

    const [ apData, setApData] = useState({
        wifiConfig : {
            accessPoint : "Not set",
            frequency : ""
        },
        wifiLinkStatistics : {
            quality : "",
            signalLevel : ""
        }
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
            DataWs.current.close();
        }

        DataWs.current.onmessage = evt => {

            console.log("WRL SKT DATA", evt.data)

            const d = JSON.parse(evt.data);            
            if ('wifiData' in d) {
                setApData(d);         
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

    console.log("WIFI STATUS: ", status);

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