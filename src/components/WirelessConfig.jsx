/* (C) 2020-2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { useEffect, useRef } from 'react';
import { Form, Row, Col } from 'react-bootstrap';

const WirelessConfig = ({ config, apData, handleChange }) => {

    const freq = useRef();
    const mac = useRef();
    const bitrate = useRef();
    const signal = useRef();

  //  console.log("Wireless ", config)
  //  console.log("Ap ", apData)

    useEffect(() => {
        freq.current.value = apData.frequency + " MHz";
        mac.current.value = apData.accessPoint;
        bitrate.current.value = apData.bitRate + " Mbps";
        signal.current.value = apData.signalLevel + "%";
    }, [apData])

    return (
        <div className="content-body">

            <Row className='mt-2 mb-2'>
                <Form.Group as={Col}>
                    <Form.Check 
                        type="checkbox" 
                        label="Enabled" 
                        checked={config.enabled === "true"}
                        onChange={(e) => { 
                            handleChange({"name" : "enabled", "value" : e.currentTarget.checked ? "true" : "false"})
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
                        defaultValue={config.macaddr}
                        readOnly
                        />
                </Form.Group>

            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Ip Address</Form.Label>
                    <Form.Control 
                        type="input" 
                        placeholder='Ip Address'
                        value={config.ipaddr}
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
                <Form.Group>
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

            <Row className='mb-3'>
                <Form.Group as={Col} controlId="SSID">
                    <Form.Label>SSID</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='SSID'
                        value={config.ssid}
                        onChange={(e) => { 
                            handleChange({"name" : "ssid", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter AP SSID
                    </Form.Text>
                </Form.Group>

                <Form.Group as={Col} controlId="passkey">
                    <Form.Label>Wifi Passkey</Form.Label>
                    <Form.Control 
                        type="password" 
                        placeholder='password'
                        value={config.passkey}
                        onChange={(e) => { 
                            handleChange({"name" : "passkey", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter Wifi Passkey
                    </Form.Text>
                </Form.Group>
            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>AP MAC Address</Form.Label>
                    <Form.Control 
                        ref={mac}
                        type="text"
                        readOnly
                        />
                </Form.Group>               

                <Form.Group as={Col}>
                    <Form.Label>Bite Rate</Form.Label>
                    <Form.Control 
                    ref={bitrate}
                        type="text"                         
                        readOnly
                        />
                </Form.Group>
            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Frequency</Form.Label>
                    <Form.Control 
                        ref={freq}
                        type="text" 
                        readOnly
                        />
                </Form.Group>               

                <Form.Group as={Col}>
                    <Form.Label>Signal Quality</Form.Label>
                    <Form.Control 
                        ref={signal}
                        type="text" 
                        readOnly
                        />
                </Form.Group>
            </Row>



        </div>
    );


}

export default WirelessConfig;