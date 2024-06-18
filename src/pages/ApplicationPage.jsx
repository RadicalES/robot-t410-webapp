/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import AppConfiguration from '../components/AppConfiguration';
import { Button, Card, Container, Form } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';

const ApplicationPage = () => {
    const ApplicationInfo = useLoaderData()
    const [ appConfig, setAppConfig, handleConfigChange ] = useFormData(ApplicationInfo?.data?.server || {
        serverurl: "Waiting..."
    })

    const handleSubmit = (e) => {
        e.preventDefault();
    }

    return (
        <Card className="content">
            <Card.Body>
                <Card.Title>Application Settings</Card.Title>
                <Form noValidate onSubmit={handleSubmit} className='mt-2 mb-2'>
                    <AppConfiguration config={appConfig} handleChange={handleConfigChange} />            
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