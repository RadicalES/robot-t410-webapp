/* (C) 2020 - 2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import AppConfig from '../components/AppConfig';
import { Button, Card, Form } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';

const ApplicationPage = () => {
    const data = useLoaderData()

    const [ config, setConfig, handleConfigChange ] = useFormData(data?.data || {
        serverUrl: "Waiting..."
    })

    const handleSubmit = (e) => {
        e.preventDefault();
        const payload = 'serverUrl=' + config.serverUrl;
        Fetcher('cgi/setapp.sh', 'POST', payload)
        .then((resp) => {
            const { status } = resp;

            if(status === 'OK') {
                alert("Application settings saved!");
            }
            else {
                alert("Failed to save application settings!");
            }

        })
        
        return true;
    }

    return (
        <Card className="content">
            <Card.Body>
                <Card.Title>Application Settings</Card.Title>
                <Form noValidate className='mt-2 mb-2' onSubmit={handleSubmit}>
                    <AppConfig config={config} handleChange={handleConfigChange} />            
                    <Button variant="outline-primary" type="submit" size="sm" className='me-2'>Save</Button>
                </Form>
            </Card.Body>
        </Card>
    );

}

// loader function
export const applicationLoader = async () => {
    const data = await Fetcher('/cgi/getapp.sh', 'GET');
    return data;
}

export default ApplicationPage;