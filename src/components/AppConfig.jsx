/* (C) 2020-2024, Radical Electronic Systems CC - info@radicalsystems.co.za
 * Written by Jan Zwiegers, jan@radicalsystems.co.za
 * Robot-T420 UX
 */
import { Form, Row, Col } from 'react-bootstrap';

const AppConfiguration = ({ config, handleChange }) => {

    console.log("App config: ", config)

    return ( 
        <div className="content-body">
            <Row className='mt-2 mb-2'>
                <Form.Group as={Col}>
                    <Form.Label>Configuration URL</Form.Label>
                    <Form.Control 
                        type="text" 
                        placeholder='Configuration URL'
                        value={config.serverUrl}
                        onChange={(e) => { 
                            handleChange({"name" : "serverUrl", "value" : e.currentTarget.value})
                        }}  
                        />
                    <Form.Text muted>
                        Enter Configuration Server URL
                    </Form.Text>
                </Form.Group>    
            </Row>      
        </div>
    )
}

export default AppConfiguration;

