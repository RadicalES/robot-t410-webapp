
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import { Button, Card, Form } from 'react-bootstrap';
import TelemetryConfiguration from '../components/TelemetryConfiguration';
import Fetcher from '../utils/fetcher';

const TelemetryPage = () => {
    const TelemetryInfo = useLoaderData()
    const [ telemetryConfig, setTelemetryConfig, handleConfigChange ] = useFormData(TelemetryInfo?.data || {
        enabled: "FALSE",
        broker: "Waiting...",
        port: 1883,
        pubtopic: "",
        username: "",
        password: ""
    })

    const handleSubmit = (e) => {
        e.preventDefault();
    }

    return (
        <Card className="content">
            <Card.Body>
                <Card.Title>Telemetry Settings</Card.Title>
                <Form noValidate onSubmit={handleSubmit} className='mt-2 mb-2'>
                    <TelemetryConfiguration config={telemetryConfig} handleChange={handleConfigChange} />            
                    <Button variant="outline-primary" type="submit" size="sm" className='me-2'>Save</Button>
                </Form>
            </Card.Body>
        </Card>
    );

}

// loader function
export const telemetryLoader = async () => {
    const data = await Fetcher('/cgi/getapp.sh', 'GET');
    return data;
}

export default TelemetryPage;