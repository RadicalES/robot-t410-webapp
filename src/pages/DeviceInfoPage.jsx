/* (C) 2020 - 2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useLoaderData } from 'react-router-dom';
import { Card, Form, Row, Col } from 'react-bootstrap';
import Fetcher from '../utils/fetcher';

const DeviceInfoPage = () => {
    const resp = useLoaderData()
    const { data } = resp; 

    console.log(" DEVICE INFO: ", resp)

    return (

        <Card className="content">
            <Card.Body>
                <Card.Title>Device Information</Card.Title>
                <div className="content-body">
                    <Form.Group as={Row}>
                        <Form.Label column sm="4" className='ms-auto'>Operating System:</Form.Label>
                        <Col sm="8">
                            <Form.Control 
                                plaintext
                                defaultValue={data.operatingsystem}
                                readOnly
                                />
                        </Col>
                    </Form.Group>       
                    <Form.Group as={Row}>
                        <Form.Label column sm="4">Distribution:</Form.Label>
                        <Col sm="8">
                            <Form.Control 
                                plaintext
                                defaultValue={data.distro}
                                readOnly
                                />
                        </Col>
                    </Form.Group>       
                    <Form.Group as={Row}>
                        <Form.Label column sm="4">Linux Kernel:</Form.Label>
                        <Col sm="8">
                            <Form.Control 
                                plaintext
                                defaultValue={data.kernel}
                                readOnly
                                />
                        </Col>
                    </Form.Group>       
                    <Form.Group as={Row}>
                        <Form.Label column sm="4">MAC Address:</Form.Label>
                        <Col sm="8">
                            <Form.Control 
                                plaintext
                                defaultValue={data.macaddress}
                                readOnly
                                />
                        </Col>
                    </Form.Group>            
                </div>
                
            </Card.Body>
        </Card>
    )
}

export default DeviceInfoPage;


// loader function
export const deviceInfoLoader = async () => {
    const data = await Fetcher('/cgi/getinfo.sh');
    return data;
}

