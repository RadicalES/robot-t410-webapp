/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import { Button, Card, Form } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';
import WirelessConfig from '../components/WirelessConfig';
import { useState } from 'react';

const WirelessPage = () => {
    const data = useLoaderData()
    const [ config, setConfig, handleConfigChange ] = useFormData(data?.data || {
        name: "Wireless",
        macAddress: "Waiting...",
        status: "ENABLED",
        dhcp: "FALSE",
        ipAddress: "192.168.1.20",
        gateway: "192.168.0.1",
        dns: "192.168.0.1",
        SSID: "",
        passkey: ""
    } )

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
    const data = await Fetcher('/cgi/getapp.sh', 'GET');
    return data;
}

export default WirelessPage;