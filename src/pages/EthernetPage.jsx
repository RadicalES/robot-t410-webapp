/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import { Button, Card, Form } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';
import EthernetConfig from '../components/EthernetConfig';

const EthernetPage = () => {
    const data = useLoaderData()
    const status = data?.status === 'OK' || false
    const [ config, setConfig, handleConfigChange ] = useFormData(data?.data || {
        name: "Wired",
        macaddr: "Waiting...",
        enabled: "false",
        dhcp: "false",
        ipaddr: "192.168.0.20",
        netmask: "255.255.255.0",
        gateway: "192.168.0.1",
        dns: "192.168.0.1"
    } )

    const handleSubmit = (e) => {
        e.preventDefault();

        const payload = 'enabled=' + config.enabled + 
        '&ipaddr=' + config.ipaddr + 
        '&gateway=' + config.gateway + 
        '&netmask=' + (config.netmask === undefined ? '255.255.255.0' : config.netmask) +
        '&dhcp=' + config.dhcp + 
        '&dns=' + config.dns;

        Fetcher('cgi/setethernet.sh', 'POST', payload)
        .then((resp) => {
            const { status } = resp;

            if(status === 'OK') {
                alert("Ethernet settings saved!");
            }
            else {
                alert("Failed to save ethernet settings!");
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

    console.log("ETHERNET DATA: ", data);

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
    const data = await Fetcher('/cgi/getethernet.sh', 'GET');
    return data;
}

export default EthernetPage;

