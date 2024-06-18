/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import { Form, Row, Col } from 'react-bootstrap';

const TelemetryConfiguration = ({ config, handleChange }) => {

    console.log("Telemetry config: ", config)


    return (
        <div className="tab-content-app">

            <Row className='mt-2 mb-2'>
                <Form.Group as={Col}>
                    <Form.Check 
                        type="checkbox" 
                        label="Enabled" 
                        checked={config.dhcp === "auto"}
                        onChange={(e) => { 
                            handleChange({"name" : "enabled", "value" : e.currentTarget.checked ? "auto" : "manual"})
                        }}  
                        
                        />
                </Form.Group>                
            </Row>


            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Broker URL</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Broker URL / Address'
                        value={config.telemetry?.broker}
                        onChange={(e) => { 
                            handleChange({"name" : "telemetry.broker", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter Broker URL or IP Address
                    </Form.Text>
                </Form.Group>

                <Form.Group as={Col}>
                    <Form.Label>Broker Port</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Broker Port' 
                        value={config.gateway}
                        onChange={(e) => { 
                            handleChange({"name" : "telemetry.port", "value" : e.currentTarget.value})
                        }} 
                        />
                    <Form.Text muted>
                        Enter Broker Port Number
                    </Form.Text>
                </Form.Group>

            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Publish Topic</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Publish Topic'
                        value={config.telemetry?.pubtopic}
                        onChange={(e) => { 
                            handleChange({"name" : "telemetry.pubtopic", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter Broker Publish Topic
                    </Form.Text>
                </Form.Group>
            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Username</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Broker username'
                        value={config.telemetry?.username}
                        onChange={(e) => { 
                            handleChange({"name" : "telemetry.username", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter Broker Username
                    </Form.Text>
                </Form.Group>

                <Form.Group as={Col}>
                    <Form.Label>Password</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Broker Password' 
                        value={config.gateway}
                        onChange={(e) => { 
                            handleChange({"name" : "telemetry.password", "value" : e.currentTarget.value})
                        }} 
                        />
                    <Form.Text muted>
                        Enter Broker Password
                    </Form.Text>
                </Form.Group>

            </Row>



        </div>

    );


}

export default TelemetryConfiguration;