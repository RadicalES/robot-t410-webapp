/* (C) 2020-2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import React, { useState, useEffect, useRef } from 'react';
import useInterval from '../utils/interval'
import { Col, Form, Row } from 'react-bootstrap';

const NetworkWireless = ( { config, handleChange } ) => {

    const DataWs = useRef(null);
    const [ WifiApData, setWifiApData] = useState({
        wifiConfig : {
            accessPoint : "Not set",
            frequency : ""
        },
        wifiLinkStatistics : {
            quality : "",
            signalLevel : ""
        }
    });

    console.log("NET WIRELESS CONFIG:", config)

    const connectWifiData = () => {
        let { hostname } = window.location;   

        if (process.env.NODE_ENV === 'development' && process.env.REACT_APP_WSPROXYIP) {
            hostname = process.env.REACT_APP_WSPROXYIP;
            if (process.env.REACT_APP_WSPROXYPORT) {
                hostname += `:${process.env.REACT_APP_WSPROXYPORT}`;
            }
        }

        const url = 'ws://' + hostname + ':7000/';        
        DataWs.current = new WebSocket(url);
        
        DataWs.current.onopen = () => {
        }

        DataWs.current.onclose = e => {
        }

        DataWs.current.onerror = err => {
            DataWs.current.close();
        }

        DataWs.current.onmessage = evt => {

            console.log("WRL SKT DATA", evt.data)

            const d = JSON.parse(evt.data);            
            if ('wifiData' in d) {
                setWifiApData(d);         
            }
        }
    }

    useEffect(() => {
        connectWifiData()
        return () => {
           // setInView(false);
            const ws = DataWs.current;                        
            if(ws && ws.readyState != WebSocket.CLOSED ) {
                ws.close();
            }
        }
     }, [])

   
    return ( 

        <div className="tab-content-app"> 

            <Row className='mt-2 mb-2'>
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

            <Row className='mb-3'>
                <Form.Group as={Col} controlId="SSID">
                    <Form.Label>SSID</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='SSID'
                        value={config.ssid}
                        onChange={(e) => { 
                            handleChange({"name" : "SSID", "value" : e.currentTarget.value})
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
                        placeholder='passkey'
                        value={""}
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
                        type="text" 
                        defaultValue={WifiApData.wifiConfig.accessPoint}
                        readOnly
                        />
                </Form.Group>               

                <Form.Group as={Col}>
                    <Form.Label>Bite Rate</Form.Label>
                    <Form.Control 
                        type="text" 
                        defaultValue={WifiApData.wifiLinkStatistics.quality}
                        readOnly
                        />
                </Form.Group>
            </Row>

            <Row className='mb-3'>
                <Form.Group as={Col}>
                    <Form.Label>Frequency</Form.Label>
                    <Form.Control 
                        type="text" 
                        defaultValue={WifiApData.wifiConfig.frequency}
                        readOnly
                        />
                </Form.Group>               

                <Form.Group as={Col}>
                    <Form.Label>Signal Level</Form.Label>
                    <Form.Control 
                        type="text" 
                        defaultValue={WifiApData.wifiLinkStatistics.signalLevel}
                        readOnly
                        />
                </Form.Group>
            </Row>
        </div>
   )
}

export default NetworkWireless;