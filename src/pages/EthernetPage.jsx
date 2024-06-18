/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import AppConfiguration from '../components/AppConfiguration';
import { Button, Card, Container, Form } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';
import EthernetConfig from '../components/EthernetConfig';

const EthernetPage = () => {
    const data = useLoaderData()
    const [ config, setConfig, handleConfigChange ] = useFormData(data?.data || {
        name: "Wired",
        macAddress: "Waiting...",
        status: "ENABLED",
        dhcp: "FALSE",
        ipAddress: "192.168.1.20",
        gateway: "192.168.0.1",
        dns: "192.168.0.1"
    } )

    const handleSubmit = (e) => {
        e.preventDefault();
    }

    const handleReset = (e) => {
        e.preventDefault();
    }

    const handleRestart = (e) => {
        e.preventDefault();
    }



    return (

        <Card className="content">
            <Card.Body>
                <Card.Title>Ethernet Settings</Card.Title>
                <Form noValidate onSubmit={handleSubmit} className='mt-2 mb-2'>
                    <EthernetConfig config={config} handleChange={handleConfigChange} />            
                    <Button variant="outline-primary" type="submit" size="sm" className="me-2">Save</Button>
                    <Button variant="danger" size="sm" className="me-2" onClick={handleReset} >Reset</Button>    
                    <Button variant="warning" size="sm" onClick={handleRestart} className="me-2">Restart Network</Button>
                </Form>
                
            </Card.Body>
        </Card>


    );

}



// loader function
export const ethernetLoader = async () => {
    const data = await Fetcher('/cgi/getapp.sh', 'GET');
    return data;
}

export default EthernetPage;

