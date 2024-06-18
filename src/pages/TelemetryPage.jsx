
import { useLoaderData } from 'react-router-dom';
import useFormData from '../hooks/useFormData';
import { Button, Card, Form } from 'react-bootstrap';
import TelemetryConfig from '../components/TelemetryConfig';
import Fetcher from '../utils/fetcher';

const TelemetryPage = () => {
    const data = useLoaderData()
    const status = data?.data?.status === 'OK' || false
    const [ config, setConfig, handleConfigChange ] = useFormData(data?.data || {
        enabled: "false",
        broker: "Waiting...",
        port: 1883,
        pubtopic: "",
        username: "",
        password: ""
    })

    const handleSubmit = (e) => {
        e.preventDefault();

        const payload = 'enabled=' + config.enabled + 
        '&broker=' + config.broker + 
        '&port=' + config.port + 
        '&user=' + config.username + 
        '&passwd=' + config.password + 
        '&pubtopic=' + config.pubtopic;

        Fetcher('cgi/settelemetry.sh', 'POST', payload)
        .then((resp) => {
            const { status } = resp;

            if(status === 'OK') {
                alert("Telemetry settings saved!");
            }
            else {
                alert("Failed to save telemetry settings!");
            }

        })
        
        return true;
    }

    return (
        <Card className="content">
            <Card.Body>
                <Card.Title>Telemetry Settings</Card.Title>
                <Form noValidate onSubmit={handleSubmit} className='mt-2 mb-2'>
                    <TelemetryConfig config={config} handleChange={handleConfigChange} />            
                    <Button variant="outline-primary" type="submit" size="sm" className='me-2'>Save</Button>
                </Form>
            </Card.Body>
        </Card>
    );

}

// loader function
export const telemetryLoader = async () => {
    const data = await Fetcher('/cgi/gettelemetry.sh', 'GET');
    return data;
}

export default TelemetryPage;