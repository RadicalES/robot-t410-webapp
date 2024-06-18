import { Button, Card, Col, Form, Row } from "react-bootstrap";
import useFormData from '../hooks/useFormData';
import Fetcher from '../utils/fetcher';

const AdminPage = () => {

    const [ config, setConfig, handleConfigChange ] = useFormData({
        current: "",
        password: "",
        repeat: ""
    })

    const setResult = (result) => {
        
    }

    const handleSubmit = (e) => {
        e.preventDefault();
        
        if(config.password === config.repeat) { 
            const cfg = 'password=' + config.current + 
                    '&newPassword=' + config.password;

            Fetcher('/cgi/setpasswd.sh', 'POST', cfg, setResult );
        }
        else {
            alert("Passwords do not match!")
        }
        return true;
    }

    return (
        <Card className="content">
            <Card.Body>
                <Card.Title>Administrative Tasks</Card.Title>
                <Form noValidate onSubmit={handleSubmit} className='mt-2 mb-2'>
                    <div className="content-body">
                        <Row className="mt-2">
                            <Form.Group as={Col}>
                                <Form.Label>Current Password</Form.Label>
                                <Form.Control 
                                    type="password" 
                                    placeholder='Current Password'
                                    value={config.current}
                                    onChange={(e) => { 
                                        handleConfigChange({"name" : "current", "value" : e.currentTarget.value})
                                    }}  
                                    />
                                <Form.Text muted>
                                    Enter Current Device Password
                                </Form.Text>
                            </Form.Group>
                        </Row>

                        <Row className="mt-2">
                            <Form.Group as={Col}>
                                <Form.Label>New Password</Form.Label>
                                <Form.Control 
                                    type="password" 
                                    placeholder='New Password'
                                    value={config.password}
                                    onChange={(e) => { 
                                        handleConfigChange({"name" : "password", "value" : e.currentTarget.value})
                                    }}  
                                    />
                                <Form.Text muted>
                                    Enter New Device Password
                                </Form.Text>
                            </Form.Group>
                        </Row>

                        <Row className="mt-2 mb-2">
                            <Form.Group as={Col}>
                                <Form.Label>New Password</Form.Label>
                                <Form.Control 
                                    type="password" 
                                    placeholder='Repeat Password'
                                    value={config.repeat}
                                    onChange={(e) => { 
                                        handleConfigChange({"name" : "repeat", "value" : e.currentTarget.value})
                                    }}  
                                    />
                                <Form.Text muted>
                                    Repeat New Device Password
                                </Form.Text>
                            </Form.Group>
                        </Row>

                    </div>
                    <Button variant="outline-primary" type="submit" size="sm" className='me-2'>Update</Button>
                </Form>
            </Card.Body>
        </Card>
    );
}

export default AdminPage;