/* (C) 2020, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T410 UX
 */
import { Form, Row, Col } from 'react-bootstrap';

const EthernetConfig = ({ config, handleChange }) => {

    console.log("Ethernet config: ", config)



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

                <Form.Group as={Col}>
                    <Form.Check 
                        type="checkbox" 
                        label="DHCP" 
                        checked={config.dhcp === "auto"}
                        onChange={(e) => { 
                            handleChange({"name" : "dhcp", "value" : e.currentTarget.checked ? "auto" : "manual"})
                        }}  
                        
                        />
                </Form.Group>                          
            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Interface</Form.Label>
                    <Form.Control 
                        type="text" 
                        defaultValue={config.name}
                        readOnly
                        />
                </Form.Group>               

                <Form.Group as={Col}>
                    <Form.Label>MAC Address</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Mac Address'
                        defaultValue={config.macAddress}
                        readOnly
                        />
                </Form.Group>

            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Ip Address</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Ip Address'
                        value={config.ipAddress}
                        onChange={(e) => { 
                            handleChange({"name" : "ipAddress", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter Ip Address
                    </Form.Text>
                </Form.Group>

                <Form.Group as={Col}>
                    <Form.Label>Gateway Address</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Gateway Address' 
                        value={config.gateway}
                        onChange={(e) => { 
                            handleChange({"name" : "gateway", "value" : e.currentTarget.value})
                        }} 
                        />
                    <Form.Text muted>
                        Enter Gateway Address
                    </Form.Text>
                </Form.Group>
            </Row>

            <Row className='mb-3'>

                <Form.Group className='mb-3'>
                    <Form.Label>DNS Server Address</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='DNS Address' 
                        value={config.dns}
                        onChange={(e) => { 
                            handleChange({"name" : "dns", "value" : e.currentTarget.value})
                        }} 
                        />
                    <Form.Text muted>
                        Enter DNS Address
                    </Form.Text>
                </Form.Group>

            </Row>



        </div>
    );


}

export default EthernetConfig;